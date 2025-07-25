FROM nginx:alpine

# Install curl for health check
RUN apk add --no-cache curl

# Optimize nginx for high performance and multiple connections
RUN sed -i '/worker_processes/c\worker_processes auto;' /etc/nginx/nginx.conf && \
    sed -i '/events {/a\    worker_connections 4096;\n    use epoll;\n    multi_accept on;' /etc/nginx/nginx.conf && \
    sed -i '/http {/a\    sendfile on;\n    tcp_nopush on;\n    tcp_nodelay on;\n    keepalive_timeout 65;\n    keepalive_requests 1000;\n    client_max_body_size 100m;\n    client_body_buffer_size 128k;\n    client_header_buffer_size 32k;\n    large_client_header_buffers 4 32k;' /etc/nginx/nginx.conf

# Create optimized nginx configuration for dev server
RUN cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name ~^(?<port>\d+)\.(?<domain>.+)$;
    
    # DNS resolver for dynamic upstream
    resolver 127.0.0.11 valid=30s ipv6=off;
    resolver_timeout 2s;

    location / {
        set $upstream_host bore-server;
        set $upstream_port $port;
        proxy_pass http://$upstream_host:$upstream_port;
        
        # Optimized for multiple concurrent requests (no caching for dev)
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 8 128k;
        proxy_busy_buffers_size 256k;
        
        # Fast connection settings
        proxy_connect_timeout 3s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # HTTP/1.1 keep-alive for connection reuse
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Disable caching for dev environment
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Performance tweaks for multiple requests
        proxy_request_buffering off;
        proxy_intercept_errors off;
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