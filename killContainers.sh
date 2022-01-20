#!/bin/bash

containers=$(docker ps -q)
if [ ! -z "${containers}" ]; then
  docker kill $containers;
fi
