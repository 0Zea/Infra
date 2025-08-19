#!/bin/bash
# Simple local environment checker for OZEA

set -euo pipefail

BLUE="\033[34m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; NC="\033[0m"

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail() { echo -e "${RED}[FAIL]${NC} $*"; }

# 1) Check MySQL port
info "Checking MySQL on 3306..."
if lsof -i :3306 >/dev/null 2>&1; then
  success "MySQL port 3306 is in use."
else
  warn "MySQL port 3306 not in use. Is MySQL running?"
fi

# 2) Check DB connectivity if mysql client exists
if command -v mysql >/dev/null 2>&1; then
  DB_NAME=${JDBC_DBNAME:-kongzea}
  DB_USER=${JDBC_USERNAME:-root}
  DB_PASS=${JDBC_PASSWORD:-}
  info "Trying to connect to MySQL (db=${DB_NAME}, user=${DB_USER})..."
  if mysql -u"${DB_USER}" -p"${DB_PASS}" -e "SHOW DATABASES LIKE '${DB_NAME}';" 2>/dev/null | grep -q "${DB_NAME}"; then
    success "Database ${DB_NAME} exists."
  else
    warn "Database ${DB_NAME} not found or cannot connect."
  fi
else
  warn "mysql client not found. Skipping DB connectivity test."
fi

# 3) Check backend port
info "Checking Backend on 8080..."
if lsof -i :8080 >/dev/null 2>&1; then
  success "Backend port 8080 is in use."
else
  warn "Backend port 8080 not in use. Start backend with: cd Back/back && ./gradlew appRun"
fi

# 4) Health endpoint
if command -v curl >/dev/null 2>&1; then
  info "Checking health endpoint..."
  if curl -fsS http://localhost:8080/api/monitoring/health >/dev/null; then
    success "Health endpoint OK."
  else
    warn "Health endpoint not responding."
  fi
else
  warn "curl not found. Skipping health check."
fi

# 5) Frontend port
info "Checking Frontend on 5173..."
if lsof -i :5173 >/dev/null 2>&1; then
  success "Frontend port 5173 is in use."
else
  warn "Frontend port 5173 not in use. Start frontend with: cd Front/frontend && npm run dev"
fi

success "Local check completed."
