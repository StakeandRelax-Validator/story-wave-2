#!/bin/bash
echo "Do you want to delete ALL the containers in the system? y/N"
read -r DELETE
if [ "$DELETE" == "Y" ]; then
    sudo docker-compose down
    sudo docker rm -f $(sudo docker ps -a -q)
    sudo docker volume rm $(sudo docker volume ls -q)
    sudo docker rmi $(sudo docker image ls -q)
fi
