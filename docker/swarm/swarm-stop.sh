#!/usr/bin/env bash

machines=( manager1 worker1 worker2 worker3 )
for machine in "${machines[@]}"; do
    docker-machine stop ${machine}
done
