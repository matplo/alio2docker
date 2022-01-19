#!/bin/bash

# docker rm $(docker ps --filter status=exited -q)

# or

docker ps --filter status=exited -q | xargs docker rm
