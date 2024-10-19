#!/bin/bash
echo "Installing Docker"
sudo apt install docker -y
sudo apt install docker-compose -y

./delete_containers.sh

./delete_service.sh

./create_service.sh

echo "Starting monitoring.service"
sudo systemctl start monitoring

echo "Grafana should be avaiable at http://localhost:3000"
