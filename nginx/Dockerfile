FROM nginx:alpine

ENV DOCKERIZE_VERSION v0.8.0
RUN apk update --no-cache \
    && apk add --no-cache wget openssl netcat-openbsd \
    && wget -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzf - -C /usr/local/bin \
    && apk del wget

COPY default.conf /etc/nginx/conf.d/default.tpl
COPY bore-server.conf /etc/nginx/bore-server.tpl
COPY change-host.sh /docker-entrypoint.d/00-change-host.sh
RUN chmod +x /docker-entrypoint.d/00-change-host.sh

RUN echo "include /etc/nginx/bore-server.conf;" >> /etc/nginx/nginx.conf

# Performance optimizations
RUN sed -i 's/worker_processes auto;/worker_processes auto;\nworker_rlimit_nofile 65535;/' /etc/nginx/nginx.conf && \
    sed -i '/events {/a \    worker_connections 4096;\n    use epoll;\n    multi_accept on;' /etc/nginx/nginx.conf && \
    sed -i '/http {/a \    sendfile on;\n    tcp_nopush on;\n    tcp_nodelay on;\n    keepalive_timeout 30;\n    keepalive_requests 1000;\n    reset_timedout_connection on;\n    client_body_timeout 10;\n    send_timeout 2;\n    client_header_timeout 10;\n    client_max_body_size 100m;' /etc/nginx/nginx.conf