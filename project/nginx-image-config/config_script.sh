#!/bin/bash

CONFIG_FILE="/etc/nginx/sites-available/reverse-proxy"

# Check prerequisites
check_environment() {
    if [[ $EUID -ne 0 ]]; then
        echo "⚠️ Please run this script as root."
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

add_domain() {
    DOMAIN="$1"
    IP="$2"

    if grep -q "server_name $DOMAIN;" "$CONFIG_FILE"; then
        echo "❌ Domain $DOMAIN already exists in config."
        exit 1
    fi

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

    echo "✅ Added reverse proxy for $DOMAIN → $IP"

    if nginx -t; then
        systemctl reload nginx
        echo "🔄 NGINX reloaded successfully."
    else
        echo "❌ NGINX config test failed. Please check manually."
        exit 1
    fi
}

remove_domain() {
    DOMAIN="$1"

    if ! grep -q "server_name $DOMAIN;" "$CONFIG_FILE"; then
        echo "❌ Domain $DOMAIN not found in config."
        exit 1
    fi

    sed -i "/server_name $DOMAIN;/{
        :a
        N
        /}/!ba
        d
    }" "$CONFIG_FILE"

    echo "🗑️ Removed reverse proxy for $DOMAIN"

    if nginx -t; then
        systemctl reload nginx
        echo "🔄 NGINX reloaded successfully."
    else
        echo "❌ NGINX config test failed. Please check manually."
        exit 1
    fi
}

show_usage() {
    echo "Usage: $0 [add|remove] domain.com [IP]"
    echo "  add    domain.com 192.168.1.100"
    echo "  remove domain.com"
}

# Entry point
check_environment

if [[ "$1" == "add" && -n "$2" && -n "$3" ]]; then
    add_domain "$2" "$3"
elif [[ "$1" == "remove" && -n "$2" ]]; then
    remove_domain "$2"
else
    show_usage
    exit 1
fi
