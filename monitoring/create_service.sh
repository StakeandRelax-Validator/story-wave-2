#!/bin/bash
echo "Create monitoring.service"
sudo systemctl disable montoring.service
sudo rm /etc/systemd/system/monitoring.service
MONITORING_PATH=$(pwd)

sudo tee /etc/systemd/system/monitoring.service > /dev/null <<EOF
[Unit]
Description=Docker monitoring containers
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c "docker-compose -f $MONITORING_PATH/docker-compose.yaml up --detach"
ExecStop=/bin/bash -c "docker-compose -f $MONITORING_PATH/docker-compose.yaml stop"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable monitoring
