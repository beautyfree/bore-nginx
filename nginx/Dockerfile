FROM nginx:alpine

# Install curl for health check
RUN apk add --no-cache curl

# Add WebSocket upgrade mapping to nginx.conf
RUN sed -i '/http {/a\    map $http_upgrade $connection_upgrade {\n        default upgrade;\n        '"'"''"'"' close;\n    }' /etc/nginx/nginx.conf

# Create universal nginx configuration
RUN cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name ~^(?<port>\d+)\.(?<domain>.+)$;
    
    # DNS resolver for dynamic upstream
    resolver 127.0.0.11 valid=30s ipv6=off;
    resolver_timeout 5s;

    location / {
        set $upstream_host bore-server;
        set $upstream_port $port;
        proxy_pass http://$upstream_host:$upstream_port;
        
        # Universal proxy settings
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Reasonable timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# Fallback server for debugging
server {
    listen 80 default_server;
    server_name _;

    location / {
        return 200 "Debug: Host=$host, Server=$server_name, URI=$request_uri\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Basic health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]