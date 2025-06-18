#!/bin/bash

CONFIG_FILE="/etc/nginx/sites-enabled/reverse-proxy"
SSL_BASE_DIR="/etc/nginx/ssl"

check_environment() {
    if [[ $EUID -ne 0 ]]; then
        echo "⚠️  Please run this script as root."
        exit 1
    fi

    if ! command -v nginx >/dev/null 2>&1; then
        echo "❌ nginx command not found. Please install nginx first."
        exit 1
    fi

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "❌ Config file $CONFIG_FILE does not exist."
        exit 1
    fi
}

domain_exists() {
    local DOMAIN="$1"
    grep -vE '^\s*#' "$CONFIG_FILE" | grep -q "server_name $DOMAIN;"
}

add_domain() {
    local DOMAIN="$1"
    local IP="$2"
    local TYPE="$3"

    # Ask interactively if not provided
    if [[ -z "$DOMAIN" ]]; then
        read -p "🌐 Enter domain (e.g. example.com): " DOMAIN
    fi
    if [[ -z "$IP" ]]; then
        read -p "📡 Enter internal IP (e.g. 192.168.1.10): " IP
    fi
    if [[ -z "$TYPE" ]]; then
        read -p "🔐 Use http or https? [http/https]: " TYPE
    fi

    if domain_exists "$DOMAIN"; then
        echo "❌ Domain $DOMAIN already exists in config."
        exit 1
    fi

    if [[ "$TYPE" == "http" ]]; then
        cat <<EOF >> "$CONFIG_FILE"

server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://$IP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    elif [[ "$TYPE" == "https" ]]; then
        SSL_DIR="$SSL_BASE_DIR/$DOMAIN"

        if [[ ! -d "$SSL_DIR" ]]; then
            echo "❌ SSL directory $SSL_DIR not found."
            exit 1
        fi

        echo "📂 Available files in $SSL_DIR:"
        ls -1 "$SSL_DIR"

        read -p "🔐 Enter fullchain filename (e.g. fullchain.pem): " CERT_FILE
        read -p "🔐 Enter private key filename (e.g. privkey.pem): " KEY_FILE

        FULLCHAIN_PATH="$SSL_DIR/$CERT_FILE"
        PRIVKEY_PATH="$SSL_DIR/$KEY_FILE"

        if [[ ! -f "$FULLCHAIN_PATH" || ! -f "$PRIVKEY_PATH" ]]; then
            echo "❌ One or both SSL files not found:"
            echo " - $FULLCHAIN_PATH"
            echo " - $PRIVKEY_PATH"
            exit 1
        fi

        cat <<EOF >> "$CONFIG_FILE"

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate     $FULLCHAIN_PATH;
    ssl_certificate_key $PRIVKEY_PATH;

    location / {
        proxy_pass https://$IP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    else
        echo "❌ Unknown type: $TYPE (must be http or https)"
        exit 1
    fi

    echo "✅ Added reverse proxy for $DOMAIN → $IP ($TYPE)"

    if nginx -t; then
        nginx -s reload
        echo "🔄 NGINX reloaded successfully."
    else
        echo "❌ NGINX config test failed. Please check manually."
        exit 1
    fi
}

remove_domain() {
    local DOMAIN="$1"

    if [[ -z "$DOMAIN" ]]; then
        read -p "🗑️  Enter domain to remove: " DOMAIN
    fi

    if ! domain_exists "$DOMAIN"; then
        echo "❌ Domain $DOMAIN not found in config."
        exit 1
    fi

    sed -i "/server_name $DOMAIN;/{
        :a
        N
        /}/!ba
        d
    }" "$CONFIG_FILE"

    echo "🗑️  Removed reverse proxy for $DOMAIN"

    if nginx -t; then
        nginx -s reload
        echo "🔄 NGINX reloaded successfully."
    else
        echo "❌ NGINX config test failed. Please check manually."
        exit 1
    fi
}

show_usage() {
    echo "Usage: $0 [add|remove] [domain] [ip] [http|https]"
    echo "Examples:"
    echo "  $0 add example.com 192.168.1.10 http"
    echo "  $0 add blog.example.com 192.168.1.12 https"
    echo "  $0 remove example.com"
    echo ""
    echo "If parameters are missing, the script will ask you interactively."
}

# ---------- MAIN ----------

check_environment

ACTION="$1"
DOMAIN="$2"
IP="$3"
TYPE="$4"

if [[ -z "$ACTION" ]]; then
    show_usage
    read -p "➕ Do you want to add or remove a domain? (add/remove): " ACTION
fi

case "$ACTION" in
    add)
        add_domain "$DOMAIN" "$IP" "$TYPE"
        ;;
    remove)
        remove_domain "$DOMAIN"
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

