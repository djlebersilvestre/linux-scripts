#!/bin/bash

DKR_REDIS_IMAGE=redis:2.8.9
DKR_REDIS_CONTAINER=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

redis_setup() {
  if ! docker ps -a | grep -q " $DKR_REDIS_CONTAINER "; then   
    docker run --name $DKR_REDIS_CONTAINER -d -p $REDIS_HOST:$REDIS_PORT:$REDIS_PORT $DKR_REDIS_IMAGE
  fi
}

redis_start() {
  redis_stop
  docker start $DKR_REDIS_CONTAINER
}

redis_restart() {
  redis_start
}

redis_stop() {
  docker stop $DKR_REDIS_CONTAINER
}

redis_cli() {
  docker run -it --link $DKR_REDIS_CONTAINER:$DKR_REDIS_CONTAINER --rm $DKR_REDIS_IMAGE sh -c 'exec redis-cli -h "$REDIS_PORT_6379_TCP_ADDR" -p "$REDIS_PORT_6379_TCP_PORT"'
}
