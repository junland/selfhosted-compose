# HAProxy

This service provides the reverse proxy and TLS termination for the stack. It routes incoming HTTP/HTTPS traffic to the other Compose services based on the request host header and applies common security and performance settings.

## How the service runs

- **Image build:** `haproxy/Containerfile` builds on `haproxy:latest` and installs the HAProxy Data Plane API binary.
- **Compose service:** `haproxy/Composefile` builds the image, names the container `haproxy-web-service`, and publishes ports **80** and **443**.
- **Configuration mount:** `haproxy/conf` is mounted into the container (read by the `haproxy -f haproxy.cfg -f backend` command), and `/var/run/haproxy` is mounted for the admin socket.

## TLS and certificates

- HTTPS terminates at HAProxy on port **443**.
- Certificates are loaded from `/etc/ssl/certs/external` inside the container.
- The host path is controlled by `SELFHOSTED_HAPROXY_EXTERNAL_CERTS_DIR` (see `default.env`, defaulting to `/etc/ssl/certs`).
- HTTP on port **80** is redirected to HTTPS.
- HSTS is enabled for one year with subdomain coverage.

## Routing behavior

Host header prefixes determine the backend to use. Requests that do not match any rule are denied.

| Host prefix | Backend | Target container |
| --- | --- | --- |
| `ci` | `ci` | `jenkins:8080` |
| `git` | `git` | `gitd:3000` |
| `graphs` | `grafana` | `grafana-app-service:3000` |
| `hoarder` | `hoarder` | `hoarder:3000` |
| `home` | `home` | `hass:8123` |
| `jellyfin` | `jellyfin` | `jellyfin:8096` |
| `ollama` | `ollama` | `ollama-app-service:11434` |
| `tavern` | `tavern` | `tavern-app-service:8000` |

Unknown hosts are routed to the `deny_403` backend, which returns an HTTP 400 response (the backend name is legacy).

## Observability and health checks

- A stats page is configured on **:8080** inside the container (not exposed by default).
- The admin socket is available at `/run/haproxy/admin.sock`.
- Backends use container DNS resolution with health checks enabled (`check` and `resolvers container_dns`).

## Caching, compression, and headers

The HTTPS frontend enables gzip/deflate compression for common web content types, applies a shared response cache, and injects `X-Forwarded-Proto` and `X-Forwarded-For` headers where appropriate.

## Data Plane API (optional)

The image includes the HAProxy Data Plane API and a `conf/dataplaneapi.yml` configuration file. The Compose service does **not** start it by default. If you want to run it manually, use `scripts/run-dataplaneapi.sh` inside the container; it launches the API on port **5555** and reloads HAProxy via `SIGUSR2`.
