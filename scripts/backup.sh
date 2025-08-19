#!/bin/bash

# OZEA 데이터베이스 백업 스크립트
# 사용법: ./backup.sh [백업_이름]

set -e

# 설정
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-kongzea}
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-12341234}
BACKUP_DIR=${BACKUP_DIR:-./backups}
RETENTION_DAYS=${RETENTION_DAYS:-30}

# 백업 이름 설정
if [ -z "$1" ]; then
    BACKUP_NAME="ozea_backup_$(date +%Y%m%d_%H%M%S)"
else
    BACKUP_NAME="$1"
fi

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

echo "🚀 OZEA 데이터베이스 백업 시작..."
echo "📅 백업 시간: $(date)"
echo "🗄️  데이터베이스: $DB_NAME"
echo "📁 백업 위치: $BACKUP_DIR/$BACKUP_NAME.sql"

# 데이터베이스 백업
mysqldump \
    --host="$DB_HOST" \
    --port="$DB_PORT" \
    --user="$DB_USER" \
    --password="$DB_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    "$DB_NAME" > "$BACKUP_DIR/$BACKUP_NAME.sql"

# 백업 파일 압축
gzip "$BACKUP_DIR/$BACKUP_NAME.sql"

echo "✅ 백업 완료: $BACKUP_DIR/$BACKUP_NAME.sql.gz"

# 백업 파일 크기 확인
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME.sql.gz" | cut -f1)
echo "📊 백업 파일 크기: $BACKUP_SIZE"

# 오래된 백업 파일 정리
echo "🧹 오래된 백업 파일 정리 중..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# 백업 상태 확인
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.sql.gz" | wc -l)
echo "📈 총 백업 파일 수: $BACKUP_COUNT"

# 백업 완료 알림
echo "🎉 백업이 성공적으로 완료되었습니다!"
echo "📅 다음 백업: $(date -d '+1 day' '+%Y-%m-%d %H:%M')"

# 백업 로그 기록
echo "$(date): 백업 완료 - $BACKUP_NAME.sql.gz ($BACKUP_SIZE)" >> "$BACKUP_DIR/backup.log" 