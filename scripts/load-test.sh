#!/usr/bin/env bash
# Simula conexiones y requests concurrentes contra la API para generar carga
# de prueba (por ejemplo, para ver los paneles de Prometheus/Grafana moverse).
#
# Pide la URL base al ejecutarse. El resto de los parametros tiene defaults
# razonables y tambien se pueden pasar por variables de entorno.
#
# Uso:
#   ./scripts/load-test.sh
#   CONCURRENCY=20 DURATION=120 ./scripts/load-test.sh
#
# Requiere: bash, curl. No requiere jq (el token se extrae con grep/sed).

set -uo pipefail

# --- Parametros (con defaults, override por variable de entorno) ---

CONCURRENCY="${CONCURRENCY:-10}"          # workers concurrentes (conexiones simultaneas)
DURATION="${DURATION:-60}"                # duracion total en segundos
MIN_DELAY="${MIN_DELAY:-0.1}"             # espera minima entre requests de un worker (s)
MAX_DELAY="${MAX_DELAY:-0.6}"             # espera maxima entre requests de un worker (s)
LOGIN_EMAIL="${LOGIN_EMAIL:-admin@admin.com}"
LOGIN_PASSWORD="${LOGIN_PASSWORD:-123456}"
CURL_MAX_TIME="${CURL_MAX_TIME:-5}"       # timeout por request (s)

# --- Pedir la URL base ---

if [ -z "${BASE_URL:-}" ]; then
    read -r -p "URL base de la API (ej: http://localhost:3000/api): " BASE_URL
fi

BASE_URL="${BASE_URL%/}"

if [ -z "$BASE_URL" ]; then
    echo "Error: la URL base no puede estar vacia." >&2
    exit 1
fi

echo "==================================================================="
echo " Simulacion de carga"
echo "==================================================================="
echo " URL base:     $BASE_URL"
echo " Concurrencia: $CONCURRENCY workers"
echo " Duracion:     ${DURATION}s"
echo " Delay/req:    ${MIN_DELAY}s - ${MAX_DELAY}s por worker"
echo "==================================================================="

command -v curl >/dev/null 2>&1 || { echo "Error: se necesita curl instalado." >&2; exit 1; }

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# --- Funcion que corre cada worker en background ---

worker() {

    local worker_id="$1"
    local log_file="$WORKDIR/worker_${worker_id}.log"
    local end_ts=$(( $(date +%s) + DURATION ))
    local token=""

    login() {

        local response
        response=$(curl -s -o /tmp/.loadtest_login_$$_${worker_id}.json -w '%{http_code}' \
            --max-time "$CURL_MAX_TIME" \
            -X POST "$BASE_URL/auth/login" \
            -H "Content-Type: application/json" \
            -d "{\"email\":\"$LOGIN_EMAIL\",\"password\":\"$LOGIN_PASSWORD\"}")

        echo "$(date +%s) POST /auth/login $response" >> "$log_file"

        token=$(grep -o '"token":"[^"]*"' "/tmp/.loadtest_login_$$_${worker_id}.json" 2>/dev/null | cut -d'"' -f4)
        rm -f "/tmp/.loadtest_login_$$_${worker_id}.json"

    }

    login

    while [ "$(date +%s)" -lt "$end_ts" ]; do

        # Mezcla de endpoints: publicos, autenticados y algun re-login ocasional
        local roll=$(( RANDOM % 100 ))
        local code

        if [ "$roll" -lt 15 ]; then
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_MAX_TIME" "$BASE_URL/health")
            echo "$(date +%s) GET /health $code" >> "$log_file"

        elif [ "$roll" -lt 25 ]; then
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_MAX_TIME" "$BASE_URL/info")
            echo "$(date +%s) GET /info $code" >> "$log_file"

        elif [ "$roll" -lt 35 ]; then
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_MAX_TIME" "$BASE_URL/")
            echo "$(date +%s) GET / $code" >> "$log_file"

        elif [ "$roll" -lt 45 ]; then
            login

        elif [ "$roll" -lt 70 ]; then
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_MAX_TIME" \
                -H "Authorization: Bearer $token" "$BASE_URL/users")
            echo "$(date +%s) GET /users $code" >> "$log_file"

        else
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_MAX_TIME" \
                -H "Authorization: Bearer $token" "$BASE_URL/profile")
            echo "$(date +%s) GET /profile $code" >> "$log_file"
        fi

        sleep "$(awk -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN { srand(); print min + rand() * (max - min) }')"

    done

}

# --- Lanzar workers en paralelo ---

echo "Arrancando $CONCURRENCY workers..."
start_ts=$(date +%s)

pids=()
for i in $(seq 1 "$CONCURRENCY"); do
    worker "$i" &
    pids+=("$!")
done

for pid in "${pids[@]}"; do
    wait "$pid"
done

end_ts=$(date +%s)
elapsed=$(( end_ts - start_ts ))

# --- Resumen ---

echo "==================================================================="
echo " Resumen"
echo "==================================================================="

total=$(cat "$WORKDIR"/worker_*.log 2>/dev/null | wc -l | tr -d ' ')
echo " Requests totales: $total"
echo " Duracion real:     ${elapsed}s"

if [ "$elapsed" -gt 0 ] && [ "$total" -gt 0 ]; then
    rps=$(awk -v t="$total" -v s="$elapsed" 'BEGIN { printf "%.2f", t / s }')
    echo " Requests/seg:      $rps"
fi

echo ""
echo " Por endpoint y codigo HTTP:"
cat "$WORKDIR"/worker_*.log 2>/dev/null | awk '{print $2, $3, $4}' | sort | uniq -c | sort -rn

echo "==================================================================="
