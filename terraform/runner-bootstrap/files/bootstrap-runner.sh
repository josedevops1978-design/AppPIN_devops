#!/usr/bin/env bash
# Se copia a la VM y se ejecuta como root via SSH (remote-exec de Terraform).
# Deja la VM lista para correr el proyecto (Docker, Docker Compose, git, etc.)
# y la registra como self-hosted runner de GitHub Actions.
#
# Uso: bootstrap-runner.sh <github_owner> <github_repo> <runner_name> <runner_labels> <runner_work_dir> <runner_version>
# Requiere la variable de entorno GITHUB_PAT.

set -euo pipefail

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

# --- 1. Prerequisitos del sistema ---
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release git jq unzip

# --- 2. Docker Engine + docker compose plugin ---
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
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
REG_TOKEN=$(curl -fsSL -X POST \
  -H "Authorization: Bearer ${GITHUB_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token" \
  | jq -r .token)

if [ -z "$REG_TOKEN" ] || [ "$REG_TOKEN" == "null" ]; then
  echo "No se pudo obtener el registration token. Revisa los permisos del GITHUB_PAT." >&2
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
  ./bin/installdependencies.sh
fi

chown -R "$TARGET_USER":"$TARGET_USER" "$RUNNER_HOME"

if [ -f "./.runner" ]; then
  echo "El runner ya estaba configurado, se omite ./config.sh"
else
  sudo -u "$TARGET_USER" ./config.sh \
    --url "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}" \
    --token "$REG_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK_DIR" \
    --unattended \
    --replace
fi

if [ ! -f "/etc/systemd/system/actions.runner.${GITHUB_OWNER}-${GITHUB_REPO}.${RUNNER_NAME}.service" ]; then
  ./svc.sh install "$TARGET_USER"
fi
./svc.sh start

echo "Bootstrap completo. Runner '${RUNNER_NAME}' registrado en ${GITHUB_OWNER}/${GITHUB_REPO}."
