#!/bin/bash

DKR_REDIS_IMAGE=redis:2.8.9
DKR_REDIS_CONTAINER=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

redis-setup() {
  docker run --name $DKR_REDIS_CONTAINER -d -p $REDIS_HOST:$REDIS_PORT:$REDIS_PORT $DKR_REDIS_IMAGE
}

redis-start() {
  redis-stop
  docker start $DKR_REDIS_CONTAINER
}

redis-restart() {
  redis-start
}

redis-stop() {
  docker stop $DKR_REDIS_CONTAINER
}

redis-cli() {
  docker run -it --link $DKR_REDIS_CONTAINER:$DKR_REDIS_CONTAINER --rm $DKR_REDIS_IMAGE sh -c 'exec redis-cli -h "$REDIS_PORT_6379_TCP_ADDR" -p "$REDIS_PORT_6379_TCP_PORT"'
}

alias redis-setup=redis-setup
alias redis-start=redis-start
alias redis-stop=redis-stop
alias redis-restart=redis-restart
alias redis-cli=redis-cli
