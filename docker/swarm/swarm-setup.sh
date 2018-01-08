#!/usr/bin/env bash

set -e

# Function for checking docker machines
checkMachine() {
    machine=$1
    echo "Checking for docker-machine ${machine}..."

    # Make sure machine exists
    if ! `docker-machine status ${machine} > /dev/null`; then
        echo "> Could not find machine ${machine}...  Creating now..."
        docker-machine create --virtualbox-memory 4096 --virtualbox-memory "2" --driver virtualbox ${machine}
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

# Ensure Portainer directory exists
docker-machine ssh manager1 '[ -d /opt/portainer ] || sudo mkdir /opt/portainer'

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

    # Ensure log driver
    docker-machine ssh ${node} 'echo "{\"log-driver\":\"json-file\"}" > /home/docker/daemon.json && sudo cp /home/docker/daemon.json /etc/docker/daemon.json && sudo /etc/init.d/docker restart'

    # Ensure max_map_count setting
    docker-machine ssh ${node} sudo sysctl -w vm.max_map_count=262144
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
network=$(docker-machine ssh manager1 docker network ls -f name=elk -q)
if [ "${network}" == "" ]; then
    echo "> Creating network..."
    docker-machine ssh manager1 docker network create --driver overlay --attachable --scope swarm elk
fi

# Deploy services
services=( elasticsearch logstash kibana logspout loggen )
for service in "${services[@]}"; do
    echo "Deploying service: ${service}"
    docker-machine ssh manager1 docker stack deploy -c /home/docker/angry-elk/docker/swarm/${service}/swarm.yml elk
done

# Announce the status
echo "Your swarm is setup and ready! Here's your node list:"
echo "########################################################################################################"
docker-machine ssh manager1 docker node ls
echo "########################################################################################################"
echo "Manager IP Address: ${ip}"