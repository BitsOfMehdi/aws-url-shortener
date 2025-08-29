#!/usr/bin/env bash
set -euo pipefail

ENDPOINT=${DDB_ENDPOINT:-http://127.0.0.1:8000}
aws dynamodb create-table \
  --cli-input-json file://infra/dynamodb/urls-table.json \
  --endpoint-url "$ENDPOINT"

aws dynamodb wait table-exists \
  --table-name UrlsTable \
  --endpoint-url "$ENDPOINT"

echo "✅ UrlsTable created at $ENDPOINT"
