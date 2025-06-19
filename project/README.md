# 📁 project/ – Reverse Proxy Monitoring Stack

Willkommen im `project/` Ordner! 🎉  
Hier findest du alle Konfigurationsdateien, Skripte und Unterordner für den Betrieb eines Docker-basierten Reverse-Proxy-Stacks inklusive Monitoring mit Grafana & Prometheus.

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

### 📊 `grafana-config/`
Konfiguriert den Grafana Container:

- **`datasources/`** 🧩 – Verweist auf den Prometheus-Container als Datenquelle.
- **`dashboards/`** 📈 – JSON-Dateien mit vordefinierten Monitoring-Dashboards.

> 🗂 Wird beim Containerstart automatisch ins passende Verzeichnis gemountet.

---

### 📜 `prometheus.yml`
Konfiguriert den Prometheus-Container:

- 📅 Legt das Abfrageintervall fest (z. B. alle 15 Sekunden)
- 🎯 Definiert die zu überwachenden Targets:
  - `proxy-node-exporter`
  - `proxy-nginx-exporter`

> 🔓 Achtung: In `nginx.conf` muss `/status` öffentlich erreichbar sein, damit Prometheus vom Exporter lesen kann.

---

### 🐙 GitHub-Integration
Alle Dateien im `project/`-Ordner sind versioniert im Repository:  
🔗 [`https://github.com/santiagotoro2023/m169-st-repository`](https://github.com/santiagotoro2023/m169-st-repository)

---

## 🚀 Quickstart (TL;DR)
1. `git clone https://github.com/santiagotoro2023/m169-st-repository`
2. `cd project/`
3. Passe SSL-Zertifikate unter `nginx-image-config/ssl/` an
4. `docker compose up -d --build`
5. Nutze `config_script.sh` für Domains ✨

---

Made with ❤️ by LK - LS - ST
