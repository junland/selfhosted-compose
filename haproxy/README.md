# HAProxy Service

This service provides the reverse proxy and TLS termination for the stack. The container is built from `Containerfile` on top of `haproxy:latest`, and the runtime configuration is loaded from the `conf/` directory mounted into the container.

## How it runs

- **Image/build**: `Containerfile` installs HAProxy dependencies and the HAProxy Data Plane API binary (not started by default).
- **Command**: `haproxy -f haproxy.cfg -f backend` loads the main config plus all backend snippets from the `backend/` directory.
- **Config location**: `./conf` is mounted to `/var/lib/haproxy`, so the service reads:
  - `/var/lib/haproxy/haproxy.cfg`
  - `/var/lib/haproxy/backend/*.cfg`
- **Sockets**: `/var/run/haproxy` is mounted from the host so the admin socket is available at `/var/run/haproxy/admin.sock`.

## Ports and TLS

- **80**: HTTP listener that redirects all traffic to HTTPS.
- **443**: HTTPS listener with `ssl crt /etc/ssl/certs/external`.
- **8080**: HAProxy stats page (no auth configured).

TLS certificates are loaded from the host path in `SELFHOSTED_HAPROXY_EXTERNAL_CERTS_DIR` (default `/etc/ssl/certs`). That directory is mounted into the container at `/etc/ssl/certs/external`. Provide PEM bundles there so HAProxy can serve the matching SNI certificate.

## Routing behavior

The HTTPS frontend applies HSTS, enables compression, captures selected headers, and uses a small response cache (`default_cache` with 30s max-age). Routing is based on the **hostname prefix** (`hdr_beg(host)`), so any domain that starts with the following prefixes will be routed to the matching backend:

| Hostname prefix | Backend | Target service |
| --- | --- | --- |
| `ci` | `ci` | `jenkins:8080` |
| `git` | `git` | `gitd:3000` |
| `graphs` | `grafana` | `grafana-app-service:3000` |
| `hoarder` | `hoarder` | `hoarder:3000` |
| `home` | `home` | `hass:8123` |
| `jellyfin` | `jellyfin` | `jellyfin:8096` |
| `ollama` | `ollama` | `ollama-app-service:11434` |
| `tavern` | `tavern` | `tavern-app-service:8000` |

Any request that does not match one of these ACLs is sent to `deny_403`, which denies the request (see `haproxy.cfg` for the configured status code).

## Data Plane API (optional)

The image includes the HAProxy Data Plane API and a helper script at `scripts/run-dataplaneapi.sh`, but the Compose service does **not** start it. If you need to manage HAProxy dynamically, run the script in the container to expose the API on port 5555.
