#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 John Unland

# Exit immediately if a command exits with a non-zero status
set -e

# Define configuration flags
DATAPLANE_API_CONF_FLAGS=(
    --host "0.0.0.0"
    --port "5555"
    --socket-path "/var/run/data-plane.sock"
    --haproxy-bin "/usr/local/sbin/haproxy"
    -f "dataplaneapi.yml"
    -c "haproxy.cfg"
)

# Define lifecycle flags using an array to safely handle internal quotes
DATAPLANE_API_LIFECYCLE_FLAGS=(
    --reload-cmd "kill -SIGUSR2 1"
    --reload-delay 5
    --restart-cmd "kill -SIGUSR2 1"
)

# Execute dataplaneapi using array expansion
exec /usr/local/sbin/dataplaneapi "${DATAPLANE_API_CONF_FLAGS[@]}" "${DATAPLANE_API_LIFECYCLE_FLAGS[@]}"
