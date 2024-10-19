#!/bin/bash
echo "Delete containers"
sudo docker-compose down
sudo docker rm -f $(sudo docker ps -a -q)
sudo docker volume rm $(sudo docker volume ls -q)
sudo docker rmi $(sudo docker image ls -q)
