#!/bin/bash

# List all .cfg files in the current directory and add "-c" before each one
BACKEND_FLAGS=$(ls -1 backend/*.cfg | awk '{print "-c " $0}')

/usr/local/bin/dataplaneapi --host 0.0.0.0 --port 5555 --haproxy-bin /usr/local/sbin/haproxy -f dataplaneapi.yml -c haproxy.cfg $BACKEND_FLAGS --reload-cmd "kill -SIGUSR2 1" --reload-delay 5 --restart-cmd "kill -SIGUSR2 1" --userlist haproxy-dataplaneapi
