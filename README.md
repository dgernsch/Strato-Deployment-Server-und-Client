# Strato-Deployment-Server-und-Client

1. Auf dem Server (Debian Container)
Hier musst du das setup_server.sh ausführen. Das machst du nur ein einziges Mal, um den Server vorzubereiten.

Schritt-für-Schritt:
## Server
Einloggen: Geh in deinen Container (über Proxmox Konsole oder lxc-attach).

``` Bash
    apt update
    apt install git 
    git clone https://github.com/dgernsch/Strato-Deployment-Server-und-Client
    git checkout client
```

Ausführbar machen (Wichtig!): Gib diesen Befehl ein, damit Linux weiß, dass es ein Programm ist:

chmod +x setup_server.sh
Starten:
./setup_server.sh

👉 Ergebnis: Der Server installiert jetzt Apache und richtet alles ein.

2. Auf deinem Mac (Client)
Hier nutzt du das deploy.sh. Das machst du jedes Mal, wenn du eine Webseite hochladen willst.

## Cliene
``` Bash
    git clone https://github.com/dgernsch/Strato-Deployment-Server-und-Client
    git checkout client
```

chmod +x deploy.sh
Starten (Beispiel): Angenommen, dein HTML-Code liegt im Ordner dist, du willst es shop nennen und die IP ist 192.168.178.34:


./deploy.sh ./dist $Name 192.x.x.x deine lokale IP adresse
👉 Ergebnis: Dein Mac lädt die Dateien hoch und die Webseite ist online.


## Strato
sub domain erstellen
A Record public IP
DYN dns einstellen

## Nginx Proxymanager
neues SSL Zertifikat erstellen

## Ergebnis
Öffne nun deine seite unter domain/$Name

Zusammenfassung der Befehle
Das Zauberwort ist chmod +x DATEINAME. Ohne das sagt das Terminal "Permission denied" (Zugriff verweigert).

Server Setup: ./setup_server.sh

Neue Seite vorbereiten (Server): create_site meinseite

Hochladen (Mac): ./deploy.sh ./meinordner meinseite 192.168.x.x
