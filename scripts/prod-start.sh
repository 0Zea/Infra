#!/bin/bash

echo "🚀 OZEA 프로덕션 환경 시작"

# 환경 변수 설정
export COMPOSE_PROFILES=production

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리..."
docker-compose down

# 전체 시스템 시작
echo "📦 전체 시스템 시작..."
docker-compose --profile production up -d

# 헬스체크 대기
echo "⏳ 서비스 헬스체크 대기..."
sleep 30

echo ""
echo "✅ 프로덕션 환경이 시작되었습니다!"
echo "🔗 프론트엔드: http://localhost"
echo "🔗 백엔드: http://localhost:8080"
echo "🔗 MySQL: localhost:3307"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3000 (admin/admin)"
echo "🏥 헬스체크: http://localhost:8080/health"
echo ""
echo "로그 확인: docker-compose logs -f"
echo "종료: docker-compose down" 