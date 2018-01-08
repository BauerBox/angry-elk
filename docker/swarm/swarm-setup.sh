#!/usr/bin/env bash

set -e

# Function for checking docker machines
checkMachine() {
    machine=$1
    echo "Checking for docker-machine ${machine}..."

    # Make sure machine exists
    if ! `docker-machine status ${machine} > /dev/null`; then
        echo "> Could not find machine ${machine}...  Creating now..."
        docker-machine create --driver virtualbox ${machine}
    fi

    # Make sure machine is running
    status=$(docker-machine status ${machine})
    echo "> Machine status: ${status}"
    if [ "${status}" != "Running" ]; then
        echo "> Starting machine ${machine}..."
        docker-machine start ${machine}
    fi
}

# Check for Docker Machine
if ! `which docker-machine > /dev/null`; then
    echo "Installing Docker Machine..."
    curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
    chmod +x /tmp/docker-machine && \
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

    echo "Installing Docker Machine Bash Completion Scripts..."
    scripts=( docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash )
    for i in "${scripts[@]}"; do
        sudo wget https://raw.githubusercontent.com/docker/machine/v0.13.0/contrib/completion/bash/${i} -P /etc/bash_completion.d;
    done
else
    echo "Docker machine already installed!"
fi

# Check for nodes
machines=( manager1 worker1 worker2 worker3 )
for machine in "${machines[@]}"; do
    checkMachine ${machine}
done

# Get Manager IP
ip=$(docker-machine ip manager1)

# Check manager
echo "Checking Manager Node"
echo "> Manager IP: ${ip}"
status=$(docker-machine ssh manager1 docker info | grep Swarm)
status="${status:7}"

if [ "${status}" != "active" ]; then
    echo "> Initializing swarm on manager node..."
    docker-machine ssh manager1 docker swarm init --advertise-addr ${ip}
fi

# Check workers
nodes=( worker1 worker2 worker3 )
for node in "${nodes[@]}"; do
    echo "Checking worker node: ${node}"
    status=$(docker-machine ssh ${node} docker info | grep Swarm)
    status="${status:7}"

    if [ "${status}" != "active" ]; then
        echo "> Adding node ${node} to swarm"

        # Get Join Token
        token=$(docker-machine ssh manager1 docker swarm join-token worker -q)

        # Join
        docker-machine ssh ${node} docker swarm join --token ${token} ${ip}:2377
    fi

    # Ensure labels
    docker-machine ssh manager1 docker node update --label-add name=${node} $(docker-machine ssh manager1 docker node ls -f name=${node} -q)
done

# Check Repo
for machine in "${machines[@]}"; do
    echo "Checking repo for node: ${machine}"
    docker-machine ssh ${machine} "[ -d ~/angry-elk ] || git clone https://github.com/BauerBox/angry-elk.git ~/angry-elk"
    docker-machine ssh ${machine} "cd ~/angry-elk && git pull origin master"
    docker-machine ssh ${machine} "cd ~/angry-elk/docker/images && ./build-all.sh"
done

# Check network
echo "Checking network 'elk'..."
network=$(docker-machine ssh manager1 docker network ls -f name=elk)
if [ "${network}" == "" ]; then
    echo "> Creating network..."
    docker-machine ssh manager1 docker network create --attachable --scope swarm elk
fi

# Announce the status
echo "Your swarm is setup and ready! Here's your node list:"
echo "########################################################################################################"
docker-machine ssh manager1 docker node ls
echo "########################################################################################################"
echo "Manager IP Address: ${ip}"