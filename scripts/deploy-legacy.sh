#!/bin/bash

# Spring Legacy 배포 스크립트
set -e

echo "🚀 OZEA Spring Legacy 배포 시작..."

# 환경 변수 설정
APP_NAME="ozea"
VERSION=${1:-"1.0.0"}
DEPLOY_PATH="/opt/ozea"
BACKUP_PATH="/opt/ozea/backup"

# 백업 생성
echo "📦 기존 버전 백업 중..."
if [ -d "$DEPLOY_PATH" ]; then
    mkdir -p "$BACKUP_PATH"
    cp -r "$DEPLOY_PATH" "$BACKUP_PATH/$(date +%Y%m%d_%H%M%S)"
fi

# 새 버전 빌드
echo "🔨 애플리케이션 빌드 중..."
cd Back/back
./gradlew clean build -x test

# 배포 디렉토리 생성
echo "📁 배포 디렉토리 준비 중..."
mkdir -p "$DEPLOY_PATH"

# WAR 파일 복사
echo "📋 WAR 파일 배포 중..."
cp build/libs/*.war "$DEPLOY_PATH/ROOT.war"

# Tomcat 설정
echo "⚙️ Tomcat 설정 중..."
cat > "$DEPLOY_PATH/setenv.sh" << EOF
#!/bin/bash
export JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
export CATALINA_OPTS="-Dspring.profiles.active=production"
EOF

chmod +x "$DEPLOY_PATH/setenv.sh"

# 헬스체크
echo "🏥 헬스체크 중..."
sleep 10
for i in {1..30}; do
    if curl -f http://localhost:8080/api/monitoring/health > /dev/null 2>&1; then
        echo "✅ 배포 성공!"
        break
    fi
    echo "⏳ 애플리케이션 시작 대기 중... ($i/30)"
    sleep 2
done

# 메트릭 확인
echo "📊 메트릭 확인 중..."
curl -s http://localhost:8080/api/monitoring/metrics | jq '.'

echo "🎉 배포 완료!" 