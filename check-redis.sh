#!/bin/bash

echo "🔍 JWT 블랙리스트 확인 스크립트"
echo "=================================="

# Redis 컨테이너가 실행 중인지 확인
if ! docker ps | grep -q ozea-redis; then
    echo "❌ Redis 컨테이너가 실행되지 않았습니다."
    exit 1
fi

echo "✅ Redis 컨테이너 실행 중"

echo ""
echo "📋 모든 JWT 관련 키:"
docker exec -it ozea-redis redis-cli KEYS "jwt:*"

echo ""
echo "🚫 블랙리스트된 토큰들:"
docker exec -it ozea-redis redis-cli KEYS "jwt:blacklist:*"

echo ""
echo "👥 사용자 토큰 목록:"
docker exec -it ozea-redis redis-cli KEYS "jwt:user:*"

echo ""
echo "📊 상세 정보:"
echo "블랙리스트 토큰 1:"
docker exec -it ozea-redis redis-cli GET "jwt:blacklist:test-token-1"

echo ""
echo "블랙리스트 토큰 2 (TTL):"
docker exec -it ozea-redis redis-cli TTL "jwt:blacklist:test-token-2"

echo ""
echo "사용자 토큰 목록:"
docker exec -it ozea-redis redis-cli SMEMBERS "jwt:user:tokens:testuser"

echo ""
echo "✅ 확인 완료!" 