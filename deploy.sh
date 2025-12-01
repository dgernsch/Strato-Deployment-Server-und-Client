#!/bin/bash

# --- DEINE SERVER DATEN ---
SERVER_IP="192.168.178.34"
USER="root"
# --------------------------

# Projektname (wie auf dem Server mit create_site angelegt)
SITE_NAME=$1

if [ -z "$SITE_NAME" ]; then
    echo "❌ Fehler: Bitte Namen der Seite angeben."
    echo "Beispiel: ./deploy.sh tetris"
    exit 1
fi

TARGET_DIR="/var/www/html/$SITE_NAME"

echo "🚀 Starte Deployment für '$SITE_NAME'..."

# 1. Bauen (Trunk)
# Wir wechseln kurz in den Client Ordner, bauen und gehen zurück
if [ -d "web_client" ]; then
    cd web_client
    echo "🔨 Baue Rust/WASM Project..."
    trunk build --release --public-url "/"
    if [ $? -ne 0 ]; then
        echo "❌ Build fehlgeschlagen."
        exit 1
    fi
    SOURCE_DIR="dist"
    cd ..
else
    # Fallback, falls man schon im web_client ordner steht
    echo "⚠️ 'web_client' Ordner nicht gefunden, suche hier nach dist..."
    SOURCE_DIR="dist"
fi

if [ ! -d "web_client/$SOURCE_DIR" ] && [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Kein 'dist' Ordner gefunden. Build prüfen!"
    exit 1
fi

# Pfad korrigieren für SCP
UPLOAD_SRC="web_client/$SOURCE_DIR/*"
if [ -d "$SOURCE_DIR" ]; then UPLOAD_SRC="$SOURCE_DIR/*"; fi

# 2. Upload
echo "📦 Lade Dateien hoch..."
scp -r $UPLOAD_SRC $USER@$SERVER_IP:$TARGET_DIR/

# 3. Rechte fixen
echo "🧹 Räume auf..."
ssh $USER@$SERVER_IP "chown -R www-data:www-data $TARGET_DIR"

echo "✅ FERTIG! Spiel ist online."
