#!/bin/bash
if [ ! "$(sudo docker ps | grep atd-postgrest_haproxy_1)" ]; then
    # container is not running - prune all stopped containers
    sudo docker container prune --force
    # stop docker-compose (in case postgrest services are running)
    sudo docker-compose --file /home/ec2-user/atd-postgrest/docker-compose.yaml --env-file /home/ec2-user/atd-postgrest/env down
    # start docker-compose
    sudo docker-compose --file /home/ec2-user/atd-postgrest/docker-compose.yaml --env-file /home/ec2-user/atd-postgrest/env up -d
fi
