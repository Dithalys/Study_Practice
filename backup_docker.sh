CONTAINER_NAME="" # данные в .env
DB_USER="" # данные в .env
DB_NAME="" # данные в .env
DB_PASS="" # данные в .env
BACKUP_DIR="/var/backups/postgres_docker"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="${BACKUP_DIR}/${DB_NAME}_docker_backup_${DATE}.sql"

mkdir -p "$BACKUP_DIR"

docker exec -i -e PGPASSWORD="$DB_PASS" "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" -F p > "$FILENAME"

if [ $? -eq 0 ]; then
    echo "[$(date)] Бэкап контейнера успешно создан: $FILENAME"
else
    echo "[$(date)] Ошибка при бэкапе контейнера!"
fi

find "$BACKUP_DIR" -type f -name "${DB_NAME}_docker_backup_*.sql" -mtime +7 -delete
