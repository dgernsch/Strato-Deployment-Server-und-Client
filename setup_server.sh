#!/bin/bash

# Prüfen ob Root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Bitte als root ausführen."
  exit 1
fi

echo "🔧 [1/3] Installiere Apache & Tools..."
apt-get update -q
apt-get install -y apache2 nano -q

echo "🔑 [2/3] Erlaube SSH Root-Login..."
# Erlaubt Root-Login und Passwort-Login für SCP
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

echo "🛠️ [3/3] Erstelle Befehl 'create_site'..."
# Wir erstellen ein globales Script, damit du später einfach 'create_site name' tippen kannst
cat << 'EOF' > /usr/local/bin/create_site
#!/bin/bash
if [ -z "$1" ]; then
    echo "Benutzung: create_site [NAME_DER_SEITE]"
    exit 1
fi
NAME=$1
WEB_ROOT="/var/www/html/$NAME"
CONF="/etc/apache2/sites-available/$NAME.conf"

echo "⚙️ Erstelle Seite: $NAME"
mkdir -p "$WEB_ROOT"

# Dummy Index, falls Ordner leer
if [ ! -f "$WEB_ROOT/index.html" ]; then
    echo "<h1>$NAME wartet auf Upload</h1>" > "$WEB_ROOT/index.html"
fi

# Apache Config (für alles: Vue, React, Rust/WASM)
cat <<CONFIG > "$CONF"
<VirtualHost *:80>
    DocumentRoot $WEB_ROOT
    ErrorLog \${APACHE_LOG_DIR}/${NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${NAME}_access.log combined
    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        # Wichtig für Rust Apps
        AddType application/wasm .wasm
        # Wichtig für Vue/React Router (History Mode)
        FallbackResource /index.html
    </Directory>
</VirtualHost>
CONFIG

chown -R www-data:www-data "$WEB_ROOT"
a2ensite "$NAME.conf" > /dev/null
systemctl reload apache2
echo "✅ Fertig! Zielordner: $WEB_ROOT"
EOF

chmod +x /usr/local/bin/create_site

echo "✅ SERVER FERTIG EINGERICHTET!"
echo "👉 Du kannst jetzt z.B. 'create_site portfolio' eingeben."
