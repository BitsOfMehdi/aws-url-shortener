#!/usr/bin/env bash
set -euo pipefail
# Default port 8000; change mapping if busy (e.g., -p 8001:8000)
docker run --rm -p 8000:8000 amazon/dynamodb-local
