#!/bin/bash
# Very simple end-to-end sanity check for local dev

set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}

echo "[1/4] Health check..."
curl -fsS "${BASE_URL}/api/monitoring/health" | jq . >/dev/null 2>&1 || curl -fsS "${BASE_URL}/api/monitoring/health" >/dev/null
echo "OK"

echo "[2/4] Product list (first page)..."
curl -fsS "${BASE_URL}/api/products?page=1&size=4" | jq . >/dev/null 2>&1 || curl -fsS "${BASE_URL}/api/products?page=1&size=4" >/dev/null
echo "OK"

echo "[3/4] Quiz list (sanity; if exists)..."
curl -fsS "${BASE_URL}/api/quiz/list" | jq . >/dev/null 2>&1 || true
echo "OK (optional)"

echo "[4/4] Notice list (sanity; if exists)..."
curl -fsS "${BASE_URL}/api/notice/list" | jq . >/dev/null 2>&1 || true
echo "OK (optional)"

echo "All checks done."
