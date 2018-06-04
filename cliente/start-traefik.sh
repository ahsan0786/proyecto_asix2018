#!/bin/sh
TOKEN=xn3bdyje5czp3i4xdb9tr53pgnfsw6me
ADMIN_USER=admin
ADMIN_PASSWORD=Ausias123@@

docker network create -d overlay proxy
docker stack deploy -c docker-compose.traefik.yml traefik
#docker stack deploy -c docker-compose.yml wordpress-mysql
docker stack deploy -c ./swarmprom/weave-compose.yml mon
