#!/bin/bash

echo "🛑 OZEA 로컬 개발 환경 종료"

# PID 파일에서 프로세스 ID 읽기
if [ -f .backend.pid ]; then
    BACKEND_PID=$(cat .backend.pid)
    echo "Backend PID: $BACKEND_PID 종료 중..."
    kill $BACKEND_PID 2>/dev/null || echo "Backend 프로세스가 이미 종료되었습니다."
    rm .backend.pid
fi

if [ -f .frontend.pid ]; then
    FRONTEND_PID=$(cat .frontend.pid)
    echo "Frontend PID: $FRONTEND_PID 종료 중..."
    kill $FRONTEND_PID 2>/dev/null || echo "Frontend 프로세스가 이미 종료되었습니다."
    rm .frontend.pid
fi

# Gradle 데몬 종료
cd Back/back
./gradlew --stop

echo "✅ 모든 서비스가 종료되었습니다."