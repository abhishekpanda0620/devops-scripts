#!/bin/bash

SERVICES=("nginx" "mysql" "docker" "ssh","pgsql")

for service in "${SERVICES[@]}"; do
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "$service is running"
    else
        echo "$service is stopped"
        # Attempt to restart
        systemctl start "$service"
        # Send alert if failed
        if ! systemctl is-active "$service" >/dev/null 2>&1; then
            echo "Failed to start $service"
            # mail -s "Service Down Alert" admin@example.com
        fi
    fi
done
