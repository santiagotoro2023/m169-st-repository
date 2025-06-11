FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY reverse-proxy /etc/nginx/sites-enabled/reverse-proxy
COPY ssl /etc/nginx/ssl

CMD ["nginx", "-g", "daemon off;"]
