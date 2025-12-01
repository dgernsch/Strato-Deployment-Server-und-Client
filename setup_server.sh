#!/bin/bash

# --- BENUTZUNG ---
# ./deploy.sh [LOKALER_ORDNER] [ZIEL_NAME] [SERVER_IP]

LOCAL_DIST=$1
REMOTE_NAME=$2
SERVER_IP=$3
USER="root"

# 1. Parameter prüfen
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "❌ Fehler: Fehlende Parameter."
    echo "-------------------------------------------------------"
    echo "Benutzung: ./deploy.sh [DIST_ORDNER] [NAME] [IP]"
    echo "Beispiel:  ./deploy.sh ./dist tetris 192.168.178.34"
    echo "-------------------------------------------------------"
    exit 1
fi

# 2. Prüfen ob lokaler Ordner existiert
if [ ! -d "$LOCAL_DIST" ]; then
    echo "❌ Fehler: Ordner '$LOCAL_DIST' nicht gefunden."
    exit 1
fi

TARGET_DIR="/var/www/html/$REMOTE_NAME"

echo "🚀 Lade '$LOCAL_DIST' auf $SERVER_IP ($REMOTE_NAME) hoch..."

# 3. Upload
# Der Stern * sorgt dafür, dass der INHALT hochgeladen wird, nicht der Ordner selbst.
scp -r "$LOCAL_DIST/"* $USER@$SERVER_IP:$TARGET_DIR/

if [ $? -eq 0 ]; then
    echo "🧹 Berechtigungen reparieren..."
    ssh $USER@$SERVER_IP "chown -R www-data:www-data $TARGET_DIR"
    echo "✅ FERTIG! Online unter: http://$SERVER_IP/$REMOTE_NAME"
else
    echo "❌ Upload fehlgeschlagen."
fi
