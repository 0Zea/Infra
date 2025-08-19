#!/bin/bash

echo "🚀 OZEA 로컬 개발 환경 시작"

# 백엔드 시작 (백그라운드)
echo "📦 Spring Legacy 백엔드 시작..."
cd Back/back
./gradlew appRun &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

# 잠시 대기 (백엔드 시작 시간)
sleep 15

# 프론트엔드 시작
echo "🎨 Vue.js 프론트엔드 시작..."
cd ../../Front/frontend
npm run dev &
FRONTEND_PID=$!
echo "Frontend PID: $FRONTEND_PID"

echo ""
echo "✅ 서비스가 시작되었습니다!"
echo "🔗 프론트엔드: http://localhost:5173"
echo "🔗 백엔드: http://localhost:8080"
echo "🏥 헬스체크: http://localhost:8080/health"
echo ""
echo "종료하려면 Ctrl+C를 누르세요"

# PID 저장
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid

# 사용자 입력 대기
wait