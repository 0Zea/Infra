#!/bin/bash

echo "🚀 OZEA 개발 환경 시작 (Docker)"

# 환경 변수 설정
export COMPOSE_PROFILES=dev

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리..."
docker-compose down

# 개발 환경 시작
echo "📦 개발 환경 시작..."
docker-compose up -d mysql

# MySQL 준비 대기
echo "⏳ MySQL 준비 대기..."
sleep 10

# 백엔드 시작
echo "🔧 Spring Legacy 백엔드 시작..."
docker-compose up -d backend-blue

# 백엔드 준비 대기
echo "⏳ 백엔드 준비 대기..."
sleep 15

# 프론트엔드 시작
echo "🎨 Vue.js 프론트엔드 시작..."
docker-compose up -d frontend

echo ""
echo "✅ 개발 환경이 시작되었습니다!"
echo "🔗 프론트엔드: http://localhost:5173"
echo "🔗 백엔드: http://localhost:8080"
echo "🔗 MySQL: localhost:3307"
echo "🏥 헬스체크: http://localhost:8080/health"
echo ""
echo "로그 확인: docker-compose logs -f"
echo "종료: docker-compose down" 