# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

Nginx acts as a reverse proxy sitting in front of the FastAPI backend. It is the only public entry point for API traffic.

## Files

```
nginx/
├── nginx.conf          # Main config: worker processes, events, mime types, logging
└── conf.d/
    └── default.conf    # Server block and proxy rules
```

## Configuration Overview

### Ports (docker-compose)

| External | Internal | Status |
|----------|----------|--------|
| `8000` | `80` | Active — all API traffic |
| `443` | `443` | Mapped but unused — no SSL configured |

### Proxy Rule

The only location block proxies all `/api` requests to the FastAPI backend:

```nginx
location /api {
    proxy_pass http://backend:8888/api;
    proxy_set_header X-Forwarded-Host   $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
}
```

`backend` resolves via Docker's internal DNS (the service name in `docker-compose.yml`).

### Key Settings

- `client_max_body_size 50M` — Allows image/video uploads up to 50MB. Raise this if upload size limits need to increase.
- `worker_processes auto` — Scales to available CPU cores.
- `worker_connections 1024`
- `keepalive_timeout 65`
- Access logs written to `/var/log/nginx/` (volume-mounted to `./logs/` on host).
- Error log level: `warn`.

### What Is Not Configured

- **No SSL/HTTPS** — Port 443 is mapped in docker-compose but no certificate or `ssl_certificate` directive exists.
- **No rate limiting** — No `limit_req_zone` or `limit_req` directives.
- **No security headers** — No `X-Frame-Options`, `Content-Security-Policy`, etc.
- **No static file serving** — No `root` or `alias` blocks; everything goes to the backend.
- **No upstream block** — Direct `proxy_pass` to `http://backend:8888`.

## Making Changes

- Edit `conf.d/default.conf` for routing and proxy rules.
- Edit `nginx.conf` for global settings (worker count, log format, body size).
- After editing, restart the nginx container: `docker-compose restart nginx`.
- Test config before restarting: `docker-compose exec nginx nginx -t`.
