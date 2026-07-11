# selfhosted-compose

A collection of Docker Compose files for managing self-hosted services. Each service is organized into its own directory with a dedicated `Composefile`, and a top-level `Composefile` ties them all together using the Compose `include` directive.

## Services

| Service | Description |
|:-------:|:-----------:|
| [gitd](gitd/) | Self-hosted Git forge (Forgejo) for repository management |
| [grafana](grafana/) | Monitoring and visualization platform for metrics and dashboards |
| [haproxy](haproxy/) | Reverse proxy and load balancer for routing HTTP/HTTPS traffic |
| [hass](hass/) | Home automation system with an MQTT broker (Mosquitto) |
| [hoarder](hoarder/) | Bookmark and web hoarding service with full-text search (MeiliSearch) |
| [jellyfin](jellyfin/) | Media server for streaming movies, TV shows, and music |
| [jenkins](jenkins/) | CI/CD server with build agent support |
| [ollama](ollama/) | Local LLM inference engine with GPU acceleration |
| [tavern](tavern/) | Interactive chat interface for conversational AI |

## Prerequisites

- Install `docker` or `podman`.
- Install `docker-compose`.

## Getting Started

1. **Clone the repository:**

   ```sh
   git clone https://github.com/junland/selfhosted-compose.git
   cd selfhosted-compose
   ```

2. **Configure environment variables:**

   Copy the default environment file and edit it with your own values:

   ```sh
   cp default.env .env
   ```

   See [`default.env`](default.env) for available configuration keys. All variables are prefixed with `SELFHOSTED_` and are organized by service.

3. **Start all services:**

   ```sh
   docker compose -f Composefile up -d
   ```

   To start a single service, use its Composefile directly:

   ```sh
   docker compose -f ollama/Composefile up -d
   ```

## Directory Structure

```
.
├── Composefile          # Top-level Compose include file
├── default.env          # Default environment variable definitions
├── gitd/                # Forgejo Git forge
├── grafana/             # Grafana dashboards
├── haproxy/             # HAProxy reverse proxy (includes Containerfile and config)
├── hass/                # Home Assistant with Mosquitto MQTT broker
├── hoarder/             # Karakeep bookmarking service
├── jellyfin/            # Jellyfin media server (includes Containerfile)
├── jenkins/             # Jenkins CI/CD with agent images
├── ollama/              # Ollama LLM inference engine
└── tavern/              # SillyTavern chat interface
```

## Example Systemd Service File

Below is a example of a systemd file if you want to put this as a service:

```
[Unit]
Description=Selfhosted Applications
Requires=docker.service
After=docker.service

[Service]
Type=simple
RemainAfterExit=true
WorkingDirectory=/etc/selfhosted-ng
ExecStartPre=/usr/bin/mkdir -p /var/run/haproxy
ExecStartPre=/usr/bin/docker compose -p selfhosted -f Composefile --env-file ./default_override.env build
ExecStart=/usr/bin/docker compose -p selfhosted -f Composefile --env-file ./default_override.env up --remove-orphans -d
ExecStopPost=/usr/bin/docker stop --filter 'name=-service$'
ExecStop=/usr/bin/ldocker compose -p selfhosted -f Composefile --env-file ./default_override.env down -t 120

[Install]
WantedBy=multi-user.target
```

## License

This project is licensed under the [MIT License](LICENSE).
