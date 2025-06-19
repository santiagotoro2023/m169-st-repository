#--⚠️  Dies ist der 'minimal' Branch! Hier ist NUR der NGINX-REVERSE-PROXY mit SCRIPT!  ⚠️ --

# 📁 project/ – Reverse Proxy Monitoring Stack

Willkommen im `project/` Ordner! 🎉  
Hier findest du alle Konfigurationsdateien, Skripte und Unterordner für den Betrieb eines Docker-basierten Reverse-Proxy-Stacks.

---

## 📦 Strukturübersicht

### 🔧 `nginx-image-config/`
Hier liegt alles rund um das custom NGINX-Image:

- **`Dockerfile`** 🐳 – Definiert, wie das NGINX-Image gebaut wird (basiert auf Debian Bookworm Slim).
- **`nginx.conf`** ⚙️ – Hauptkonfigurationsdatei für NGINX.
- **`reverse-proxy`** 🌐 – Enthält spezifische Reverse-Proxy Regeln.
- **`config_script.sh`** 🧠 – Interaktives Skript zur Verwaltung von Domain-Routen.
- **`ssl/`** 🔐 – Zentraler Ablageort für SSL-Zertifikate:
  - Pro Domain ein Unterordner (`example.com/`, `deinedomain.ch/`)
  - Enthält `cert.pem` und `key.pem` Dateien zur TLS-Verschlüsselung

> 💡 `config_script.sh` kann interaktiv (`-it`) oder mit Parametern ausgeführt werden:
> `docker exec -it nginx-reverse-proxy /etc/nginx/config_script`

---

## 🚀 Quickstart (TL;DR)
1. `git clone https://github.com/santiagotoro2023/m169-st-repository`
2. `cd project/`
3. Passe SSL-Zertifikate unter `nginx-image-config/ssl/` an
4. `docker compose up -d --build`
5. Nutze `config_script.sh` für Domains ✨

---

Made with ❤️ by Santiago Toro
