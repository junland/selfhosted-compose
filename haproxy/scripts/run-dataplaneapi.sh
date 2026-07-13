#!/bin/bash

/usr/local/sbin/dataplaneapi --host 0.0.0.0 --port 5555 --haproxy-bin /usr/local/sbin/haproxy -f dataplaneapi.yml -c haproxy.cfg --reload-cmd "kill -SIGUSR2 1" --reload-delay 5 --restart-cmd "kill -SIGUSR2 1"
