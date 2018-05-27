#!/bin/sh
docker network create -d overlay proxy
docker stack deploy -c docker-compose.traefik.yml traefik
docker stack deploy -c docker-compose.webapps.yml dns-jenkins
docker stack deploy -c ./swarmprom/docker-compose.yml mon
