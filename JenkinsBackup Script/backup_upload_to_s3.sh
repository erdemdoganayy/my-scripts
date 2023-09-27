#!/bin/bash

# S3 bucket adı
S3_BUCKET="mikrotestbackup"

# Yedek klasörü
BACKUP_DIR="/var/lib/jenkins/backup/"

# En son oluşturulan yedek dosyalarını bulma komutu
BACKUP_FILES=($(ls -t /var/lib/jenkins/backup/ | grep "\.zip$"))

# En son yüklenen 5 yedeği hariç tutma
NUM_TO_KEEP=5
count=0
for file in "${BACKUP_FILES[@]}"; do
    if [ $count -ge $NUM_TO_KEEP ]; then
        echo "Siliniyor: $file"
        # Dosyayı silmek istiyorsanız, aşağıdaki satırın başındaki "#" işaretini kaldırın
         rm "$BACKUP_DIR$file"
    fi
    ((count++))
done

# En son yedek dosyasının adını bulma
LATEST_BACKUP="${BACKUP_FILES[0]}"

if [ -z "$LATEST_BACKUP" ]; then
    echo "Bulunamadı: Yedek dosyası yok."
    exit 1
fi

echo "Yedek dosyası: $LATEST_BACKUP"

# AWS CLI ile S3'e yedekleme işlemi
aws s3 cp "$BACKUP_DIR$LATEST_BACKUP" "s3://$S3_BUCKET/$LATEST_BACKUP"

echo "Yedekleme işlemi tamamlandı: $LATEST_BACKUP"

# ZIP dosyasını silme
if [ -f "$BACKUP_DIR$LATEST_BACKUP" ]; then
    rm "$BACKUP_DIR$LATEST_BACKUP"
    echo "ZIP dosyası silindi: $BACKUP_DIR$LATEST_BACKUP"
else
    echo "ZIP dosyası bulunamadı: $BACKUP_DIR$LATEST_BACKUP"
fi
