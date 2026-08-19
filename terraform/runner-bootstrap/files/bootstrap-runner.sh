#!/usr/bin/env bash
# Se copia a la VM y se ejecuta como root via SSH (remote-exec de Terraform).
# Deja la VM lista para correr el proyecto (Docker, Docker Compose, git, etc.)
# y la registra como self-hosted runner de GitHub Actions.
#
# Uso: bootstrap-runner.sh <github_owner> <github_repo> <runner_name> <runner_labels> <runner_work_dir> <runner_version>
# Requiere la variable de entorno GITHUB_PAT.

set -euo pipefail

DEBUG_LOG="/var/log/bootstrap-runner-debug.log"
trap 'echo "[$(date -Is)] FALLO en linea $LINENO (exit $?)" >> "$DEBUG_LOG"' ERR

GITHUB_OWNER="$1"
GITHUB_REPO="$2"
RUNNER_NAME="$3"
RUNNER_LABELS="$4"
RUNNER_WORK_DIR="$5"
RUNNER_VERSION="$6"

if [ -z "${GITHUB_PAT:-}" ]; then
  echo "GITHUB_PAT env var is required" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-$(logname)}"
echo "[$(date -Is)] inicio bootstrap. target_user=${TARGET_USER} owner=${GITHUB_OWNER} repo=${GITHUB_REPO} runner_name=${RUNNER_NAME}" >> "$DEBUG_LOG"

# --- 1. Prerequisitos del sistema ---
export DEBIAN_FRONTEND=noninteractive
# Si un intento previo dejo un repo de Docker roto (ej: codename/distro mal
# resuelto), lo quitamos antes de actualizar para no romper este apt-get update.
rm -f /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release git jq unzip

# --- 2. Docker Engine + docker compose plugin ---
if ! command -v docker >/dev/null 2>&1; then
  DOCKER_OS_ID="$(. /etc/os-release && echo "$ID")"
  case "$DOCKER_OS_ID" in
    ubuntu) DOCKER_APT_PATH="ubuntu" ;;
    debian) DOCKER_APT_PATH="debian" ;;
    *) echo "Distro no soportada para el repo de Docker: $DOCKER_OS_ID" >&2; exit 1 ;;
  esac

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/${DOCKER_APT_PATH}/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DOCKER_APT_PATH} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Binario clasico `docker-compose` (ademas del plugin `docker compose`)
if ! command -v docker-compose >/dev/null 2>&1; then
  curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

systemctl enable --now docker
usermod -aG docker "$TARGET_USER" || true

# --- 3. Registro como GitHub Actions self-hosted runner ---
echo "[$(date -Is)] docker listo, solicitando registration-token" >> "$DEBUG_LOG"
REG_HTTP_CODE=$(curl -s -o /tmp/reg-token-response.json -w '%{http_code}' -X POST \
  -H "Authorization: Bearer ${GITHUB_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token")
echo "[$(date -Is)] registration-token HTTP $REG_HTTP_CODE, body:" >> "$DEBUG_LOG"
cat /tmp/reg-token-response.json >> "$DEBUG_LOG" 2>/dev/null || true
echo >> "$DEBUG_LOG"
REG_TOKEN=$(jq -r .token /tmp/reg-token-response.json 2>/dev/null || true)

if [ -z "$REG_TOKEN" ] || [ "$REG_TOKEN" == "null" ]; then
  echo "No se pudo obtener el registration token (HTTP $REG_HTTP_CODE). Revisa /var/log/bootstrap-runner-debug.log y los permisos del GITHUB_PAT." >&2
  exit 1
fi

RUNNER_HOME="/opt/actions-runner"
mkdir -p "$RUNNER_HOME"
cd "$RUNNER_HOME"

if [ ! -f "./config.sh" ]; then
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64) RUNNER_ARCH="x64" ;;
    aarch64) RUNNER_ARCH="arm64" ;;
    *) echo "Arquitectura no soportada: $ARCH" >&2; exit 1 ;;
  esac
  curl -fsSL -o runner.tar.gz \
    "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"
  tar xzf runner.tar.gz
  rm -f runner.tar.gz
fi

# Se corre siempre (no solo en la descarga inicial): installdependencies.sh no
# reconoce distros/versiones muy nuevas (ej. Debian trixie) y puede omitir
# libicu sin avisar, dejando el runner instalado pero sin poder ejecutar
# config.sh/run.sh hasta que se instale a mano.
./bin/installdependencies.sh

if ! ldconfig -p | grep -q 'libicu'; then
  ICU_PKG="$(apt-cache search --names-only '^libicu[0-9]+$' | sort -V | tail -n1 | awk '{print $1}')"
  if [ -n "$ICU_PKG" ]; then
    apt-get install -y "$ICU_PKG"
  else
    echo "No se encontro un paquete libicu disponible en los repos." >&2
    exit 1
  fi
fi

chown -R "$TARGET_USER":"$TARGET_USER" "$RUNNER_HOME"

# Firma de la configuracion deseada (nombre, labels, work dir, repo). Si la VM
# ya tiene un runner registrado con una firma distinta (por ejemplo cambio de
# runner_name o runner_labels en tfvars), lo desregistramos de GitHub antes de
# volver a configurarlo, para no dejar runners huerfanos ni config desactualizada.
SIGNATURE_FILE="${RUNNER_HOME}/.bootstrap-signature"
DESIRED_SIGNATURE=$(printf '%s' "${GITHUB_OWNER}/${GITHUB_REPO}|${RUNNER_NAME}|${RUNNER_LABELS}|${RUNNER_WORK_DIR}" | sha1sum | awk '{print $1}')

NEEDS_RECONFIG=false
if [ -f "./.runner" ]; then
  if [ ! -f "$SIGNATURE_FILE" ] || [ "$(cat "$SIGNATURE_FILE")" != "$DESIRED_SIGNATURE" ]; then
    NEEDS_RECONFIG=true
  fi
fi

if [ "$NEEDS_RECONFIG" = true ]; then
  echo "La configuracion del runner cambio (nombre/labels/work dir). Desregistrando la config anterior..."
  ./svc.sh stop || true
  ./svc.sh uninstall || true

  REMOVE_TOKEN=$(curl -fsSL -X POST \
    -H "Authorization: Bearer ${GITHUB_PAT}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/remove-token" \
    | jq -r .token)

  if [ -z "$REMOVE_TOKEN" ] || [ "$REMOVE_TOKEN" == "null" ]; then
    echo "No se pudo obtener el remove-token. Revisa los permisos del GITHUB_PAT." >&2
    exit 1
  fi

  sudo -u "$TARGET_USER" ./config.sh remove --token "$REMOVE_TOKEN"
  rm -f "$SIGNATURE_FILE"
fi

if [ -f "./.runner" ]; then
  echo "El runner ya estaba configurado con la configuracion deseada, se omite ./config.sh"
else
  sudo -u "$TARGET_USER" ./config.sh \
    --url "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}" \
    --token "$REG_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK_DIR" \
    --unattended \
    --replace
  echo "$DESIRED_SIGNATURE" > "$SIGNATURE_FILE"
  chown "$TARGET_USER":"$TARGET_USER" "$SIGNATURE_FILE"
fi

if [ ! -f "/etc/systemd/system/actions.runner.${GITHUB_OWNER}-${GITHUB_REPO}.${RUNNER_NAME}.service" ]; then
  ./svc.sh install "$TARGET_USER"
fi
./svc.sh start

echo "Bootstrap completo. Runner '${RUNNER_NAME}' registrado en ${GITHUB_OWNER}/${GITHUB_REPO}."
