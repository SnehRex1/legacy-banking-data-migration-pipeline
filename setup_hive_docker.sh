#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# ONE-SHOT HIVE 4 DOCKER SETUP
# Uses the official Apache Hive Docker image.
# Does NOT touch the existing /opt/hive or /opt/hadoop setup.
# Runs HiveServer2 with the official embedded Derby metastore.
# Persists the Hive warehouse in ./hive-docker-data.
# Creates the banking_legacy database and project tables.
#
# Run:
#   chmod +x setup_hive_docker.sh
#   ./setup_hive_docker.sh
# ============================================================

CONTAINER="hive4"
IMAGE="apache/hive:4.0.0"
HOST_PORT="${HIVE_HOST_PORT:-10000}"
DATA_DIR="$(pwd)/hive-docker-data"
SQL_FILE="$(pwd)/hive-init.sql"

echo "============================================================"
echo " Hive Docker one-shot setup"
echo "============================================================"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed/in PATH."
  echo "Install/start Docker Desktop with WSL integration, then rerun."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running."
  echo "Start Docker Desktop, wait until Docker is ready, then rerun."
  exit 1
fi

mkdir -p "$DATA_DIR"

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "[1/6] Removing previous $CONTAINER container..."
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
else
  echo "[1/6] No previous Hive container found."
fi

echo "[2/6] Pulling official Apache Hive image..."
docker pull "$IMAGE"

echo "[3/6] Starting HiveServer2..."
docker run -d \
  --name "$CONTAINER" \
  -p "${HOST_PORT}:10000" \
  -p 10002:10002 \
  -e SERVICE_NAME=hiveserver2 \
  -e IS_RESUME=true \
  -v "$DATA_DIR:/opt/hive/data/warehouse" \
  "$IMAGE" >/dev/null

echo "[4/6] Waiting for HiveServer2 on localhost:${HOST_PORT}..."

for i in $(seq 1 60); do
  if (echo >/dev/tcp/127.0.0.1/"$HOST_PORT") >/dev/null 2>&1; then
    echo "HiveServer2 is accepting TCP connections."
    break
  fi

  if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo
    echo "ERROR: Hive container stopped unexpectedly."
    docker logs --tail 120 "$CONTAINER" || true
    exit 1
  fi

  if [ "$i" -eq 60 ]; then
    echo
    echo "ERROR: HiveServer2 did not open port ${HOST_PORT} within 120 seconds."
    docker logs --tail 150 "$CONTAINER" || true
    exit 1
  fi

  sleep 2
done

echo "[5/6] Creating banking_legacy database and tables..."

cat > "$SQL_FILE" <<'SQL'
CREATE DATABASE IF NOT EXISTS banking_legacy;

USE banking_legacy;

CREATE TABLE IF NOT EXISTS customers (
    customer_id STRING,
    customer_name STRING,
    city STRING,
    segment STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS accounts (
    account_id STRING,
    customer_id STRING,
    account_type STRING,
    balance DECIMAL(15,2),
    status STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id STRING,
    account_id STRING,
    transaction_date STRING,
    transaction_type STRING,
    amount DECIMAL(15,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

SHOW DATABASES;
SHOW TABLES;
SQL

docker cp "$SQL_FILE" "$CONTAINER:/tmp/hive-init.sql"

docker exec "$CONTAINER" beeline \
  -u 'jdbc:hive2://localhost:10000/default' \
  --silent=true \
  --showHeader=true \
  -f /tmp/hive-init.sql

echo "[6/6] Checking for project CSV files..."

load_csv() {
  local table="$1"
  local filename="$2"
  local found=""

  found="$(find . -type f -iname "$filename" -print -quit 2>/dev/null || true)"

  if [ -z "$found" ]; then
    echo "  Not found: $filename — $table table remains empty."
    return
  fi

  echo "  Found: $found"
  echo "  Loading into banking_legacy.$table..."

  docker cp "$found" "$CONTAINER:/tmp/${filename}"

  docker exec "$CONTAINER" sh -c \
    "mkdir -p /opt/hive/data/warehouse/banking_legacy.db/${table} && \
     tail -n +2 /tmp/${filename} > /opt/hive/data/warehouse/banking_legacy.db/${table}/${filename}"

  docker exec "$CONTAINER" beeline \
    -u 'jdbc:hive2://localhost:10000/default' \
    --silent=true \
    -e "USE banking_legacy; MSCK REPAIR TABLE ${table};" >/dev/null 2>&1 || true
}

load_csv "customers" "customers.csv"
load_csv "accounts" "accounts.csv"
load_csv "transactions" "transactions.csv"

echo
echo "============================================================"
echo " SUCCESS — Hive is running in Docker"
echo "============================================================"
echo
echo "Beeline:"
echo "  docker exec -it ${CONTAINER} beeline -u 'jdbc:hive2://localhost:10000/default'"
echo
echo "Then:"
echo "  USE banking_legacy;"
echo "  SHOW TABLES;"
echo "  SELECT COUNT(*) FROM customers;"
echo "  SELECT COUNT(*) FROM accounts;"
echo "  SELECT COUNT(*) FROM transactions;"
echo
echo "Hive Web UI:"
echo "  http://localhost:10002/"
echo
echo "Persistent warehouse:"
echo "  ${DATA_DIR}"
echo
echo "Stop:"
echo "  docker stop ${CONTAINER}"
echo
echo "Start again:"
echo "  docker start ${CONTAINER}"
echo "============================================================"
