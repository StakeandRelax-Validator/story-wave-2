#!/bin/bash
echo "Installing Docker"
sudo apt install docker -y
sudo apt install docker-compose -y

echo "Do you want to delete ALL the container in the system? y/N"
read -r DELETE
if [ "$DELETE" == "Y" ]; then
./delete_containers.sh
fi

./delete_service.sh

./create_service.sh

echo "Starting monitoring.service"
sudo systemctl start monitoring

echo "Grafana should be avaiable at http://localhost:3000"
