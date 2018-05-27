#!/bin/sh
TOKEN=eexpgzz5x15wxfjo8jdi5wnqjbgrp7tp
ADMIN_USER=admin
ADMIN_PASSWORD=Ausias123@@

docker network create -d overlay proxy
docker stack deploy -c docker-compose.traefik.yml traefik
docker stack deploy -c docker-compose.yml wordpress-mysql
docker stack deploy -c ./swarmprom/weave-compose.yml mon
