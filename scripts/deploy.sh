#!/bin/bash

# Spring Legacy + Vue.js Blue-Green 무중단 배포 스크립트
set -e

IMAGE_TAG=$1
DOCKER_USERNAME=${DOCKER_USERNAME:-"ozea"}

echo "🚀 Starting Blue-Green deployment for Spring Legacy + Vue.js"
echo "📦 Image tag: $IMAGE_TAG"

# 프로덕션 프로파일 설정
export COMPOSE_PROFILES=production

# 현재 활성 환경 확인
if docker ps --format "table {{.Names}}" | grep -q "ozea-backend-blue"; then
    CURRENT_ENV="blue"
    NEW_ENV="green"
    CURRENT_CONTAINER="ozea-backend-blue"
    NEW_CONTAINER="ozea-backend-green"
else
    CURRENT_ENV="green"
    NEW_ENV="blue"
    CURRENT_CONTAINER="ozea-backend-green"
    NEW_CONTAINER="ozea-backend-blue"
fi

echo "📊 Current environment: $CURRENT_ENV"
echo "🔄 Deploying to: $NEW_ENV"

# 새 환경 배포
echo "🔨 Building new Spring Legacy container: $NEW_CONTAINER"
docker-compose --profile production up -d --build backend-${NEW_ENV}

# 새 환경 헬스체크 (Spring Legacy용)
echo "🏥 Health checking new Spring Legacy environment..."
for i in {1..30}; do
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        echo "✅ New Spring Legacy environment is healthy!"
        break
    fi
    echo "⏳ Waiting for new Spring Legacy environment to be ready... ($i/30)"
    sleep 10
done

# 새 환경이 정상이면 트래픽 전환
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "🔄 Switching traffic to new environment..."
    
    # Nginx 설정 업데이트 (새 환경에 더 많은 트래픽 할당)
    docker exec ozea-frontend sed -i "s/weight=1/weight=3/g" /etc/nginx/nginx.conf
    docker exec ozea-frontend nginx -s reload
    
    # 잠시 대기 후 기존 환경 중지
    echo "⏳ Waiting for traffic to stabilize..."
    sleep 30
    
    # 기존 환경 중지
    echo "🛑 Stopping old environment: $CURRENT_CONTAINER"
    docker-compose --profile production stop backend-${CURRENT_ENV}
    
    echo "🎉 Blue-Green deployment completed successfully!"
    echo "📈 New environment: $NEW_ENV is now active"
    echo "🔗 Frontend: http://localhost"
    echo "🔗 Backend Health: http://localhost:8080/health"
    echo "📊 Prometheus: http://localhost:9090"
    echo "📈 Grafana: http://localhost:3000 (admin/admin)"
else
    echo "❌ New environment failed health check. Rolling back..."
    docker-compose --profile production stop backend-${NEW_ENV}
    exit 1
fi

# 배포 완료 알림
echo "📧 Sending deployment notification..."
curl -X POST -H "Content-Type: application/json" \
  -d "{\"text\":\"🚀 OZEA Spring Legacy + Vue.js deployment completed successfully! New version: $IMAGE_TAG\"}" \
  $SLACK_WEBHOOK_URL || true

echo "✅ Deployment script completed!" 