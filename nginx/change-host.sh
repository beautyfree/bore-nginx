#!/bin/sh

echo "Configuring nginx with BORE_HOST=${BORE_HOST:-bore-server} and DNS_RESOLVER=${DNS_RESOLVER:-8.8.8.8}"

# Generate configs first
dockerize -template /etc/nginx/conf.d/default.tpl:/etc/nginx/conf.d/default.conf \
          -template /etc/nginx/bore-server.tpl:/etc/nginx/bore-server.conf

# Wait for bore-server without DNS lookup (try multiple times)
echo "Waiting for bore-server to be ready..."
for i in $(seq 1 30); do
    if nc -z ${BORE_HOST:-bore-server} 7835 2>/dev/null; then
        echo "bore-server is ready!"
        break
    fi
    echo "Attempt $i: bore-server not ready, waiting 2s..."
    sleep 2
done