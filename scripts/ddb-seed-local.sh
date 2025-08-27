#!/usr/bin/env bash
set -euo pipefail

ENDPOINT=${DDB_ENDPOINT:-http://127.0.0.1:8000}
aws dynamodb batch-write-item \
  --request-items file://infra/dynamodb/seed-data.json \
  --endpoint-url "$ENDPOINT"

echo "✅ Seed data loaded into UrlsTable at $ENDPOINT"
