#!/bin/sh

echo "Configuring nginx with BORE_HOST=${BORE_HOST:-bore-server} and DNS_RESOLVER=${DNS_RESOLVER:-127.0.0.11}"

dockerize -template /etc/nginx/conf.d/default.tpl:/etc/nginx/conf.d/default.conf \
          -template /etc/nginx/bore-server.tpl:/etc/nginx/bore-server.conf \
          -wait tcp://${BORE_HOST:-bore-server}:7835 -timeout 60s