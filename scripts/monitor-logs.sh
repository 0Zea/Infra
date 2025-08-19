#!/bin/bash

# 실시간 로그 모니터링 스크립트
echo "🔍 OZEA 실시간 로그 모니터링 시작..."
echo ""

# 로그 디렉토리 생성
mkdir -p logs

# 로그 파일이 없으면 생성
if [ ! -f logs/application.log ]; then
    echo "# OZEA Application Log" > logs/application.log
    echo "# Created: $(date)" >> logs/application.log
    echo "" >> logs/application.log
fi

echo "📁 로그 파일 위치: $(pwd)/logs/application.log"
echo "🔄 실시간 모니터링 시작 (Ctrl+C로 종료)..."
echo ""

# 실시간 로그 모니터링
tail -f logs/application.log | while read line; do
    timestamp=$(date '+%H:%M:%S')
    echo "[$timestamp] $line"
done 