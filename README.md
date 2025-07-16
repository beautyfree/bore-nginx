# Bore Server with HTTPS and Subdomains

A production-ready HTTP tunnel service using [bore](https://github.com/ekzhang/bore) with nginx reverse proxy, automatic HTTPS certificates, and subdomain-based routing.

## Features

✅ **Subdomain routing** - Access tunnels via `https://7999.your-domain.com`
✅ **Automatic HTTPS** - Let's Encrypt SSL certificates for wildcard domains  
✅ **Traefik integration** - Works seamlessly with Dokploy and other Traefik setups  
✅ **Docker Compose** - Easy deployment and configuration  
✅ **Environment-based config** - Fully configurable via environment variables  
✅ **Production ready** - Optimized for performance and reliability  

## Quick Start

1. **Clone and configure**:
   ```bash
   git clone <repository>
   cd bore-server
   cp .env.example .env
   ```

2. **Edit `.env` file**:
   ```env
   BORE_DOMAIN=your-domain.com
   BORE_SECRET=your-secret-key
   ```

3. **Setup DNS wildcard**:
   Add DNS record: `*.your-domain.com` → `your-server-ip`

4. **Deploy**:
   ```bash
   docker-compose up -d
   ```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BORE_DOMAIN` | `bore.tacticlaunch.com` | Base domain for subdomains |
| `BORE_SECRET` | - | Secret key for bore server authentication |
| `BORE_MIN_PORT` | `7000` | Minimum port for tunnels |
| `BORE_MAX_PORT` | `8000` | Maximum port for tunnels |
| `NGINX_PORT` | `8081` | External nginx port |
| `BORE_PORT` | `7835` | Bore control port |
| `BORE_SERVER_HOST` | `bore-server` | Internal bore server hostname |
| `DNS_RESOLVER` | `127.0.0.11` | DNS resolver for nginx |

## Usage

1. **Start your local service**:
   ```bash
   # Example: Python HTTP server
   python3 -m http.server 3000
   
   # Or Node.js app
   npm start # running on port 3000
   ```

2. **Create tunnel**:
   ```bash
   bore local 3000 --to https://7999.your-domain.com --port 7999
   ```

3. **Access via subdomain**:
   Open `https://7999.your-domain.com` in your browser

## How It Works

```
Client Request → Traefik → Nginx → Bore Server → Your Local Service
https://7999.your-domain.com → nginx extracts port 7999 → proxies to bore-server:7999 → your localhost:3000
```

## Advantages of Subdomain Approach

(subdomain-based): `https://7999.your-domain.com/api/users`
- ✅ Clean URLs that work with any application
- ✅ Proper relative path resolution
- ✅ No URL rewriting required
- ✅ Works with React, Vue, Angular, etc.

## Deployment Options

### Dokploy
1. Create new Docker Compose application
2. Paste `docker-compose.yaml` content
3. Set environment variables in Dokploy UI
4. Deploy

### Standalone Docker
```bash
docker-compose up -d
```

### Development
```bash
# Build and run locally
docker-compose up --build
```

## DNS Configuration

For wildcard subdomains, add DNS record:
```
Type: A
Name: *.your-domain.com
Value: your-server-ip
```

Or for specific subdomains:
```
7999.your-domain.com → your-server-ip
8000.your-domain.com → your-server-ip
```

## Security

- Set strong `BORE_SECRET` in production
- Configure firewall to restrict access to bore ports
- Use HTTPS only (HTTP redirects to HTTPS automatically)
- Regularly update Docker images

## Troubleshooting

**DNS not resolving**:
```bash
nslookup 7999.your-domain.com
```

**Check nginx config**:
```bash
docker exec <nginx-container> cat /etc/nginx/conf.d/default.conf
```

**View logs**:
```bash
docker-compose logs bore-nginx
docker-compose logs bore-server
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

MIT License - see LICENSE file for details.

## Credits

Built on top of the excellent [bore](https://github.com/ekzhang/bore) project by [@ekzhang](https://github.com/ekzhang).
