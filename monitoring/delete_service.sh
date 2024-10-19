#!/bin/bash
echo "Delete monitoring.service"
sudo systemctl disable montoring.service
sudo rm /etc/systemd/system/monitoring.service
