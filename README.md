# Angry ELK, Happy Ops
Source Repository for Meetup 1/8/2018 - Any Elk, Happy Ops

## How to use

### Compose
If you just wish to use the images and toy around with the stack on your own, you can use the `build-all.sh` script in the `docker/images` directory to build the images locally.  Once built, you can use the `docker-compose.yml` file in the `docker/compose` directory to stand up the services locally.

### Swarm
If you want to use the images in a (local) docker Swarm, you can use the `setup-swarm.sh` file in the `docker/swarm` directory to setup a local swarm

## Assumptions
It is assumed that docker is logging via the `json-file` driver...
This can be setup by applying the following setting to your `daemon.json` file (for singe instances).
See the official documentation here: https://docs.docker.com/engine/admin/logging/overview/ 
 
 ```json
{
  "log-driver": "json-file"
}
``` 

## Images (As tagged by `build.sh` Scripts)
* angry-elk/elasticsearch
* angry-elk/logstash

## Resources
Below you will find some general resource links that are helpful when standing up an ELK stack in Production.
All links are assuming version `6.1` for Elastic.co products.

### General
* Elastic.co Docker Images: https://www.docker.elastic.co/
* Elasticsearch Docker Source: https://github.com/elastic/elasticsearch-docker
* Logstash Docker Source: https://github.com/elastic/logstash-docker
* Phusion Base Image Info (used for curator): http://phusion.github.io/baseimage-docker


### Elasticsearch
* Elasticsearch in Docker: https://www.elastic.co/guide/en/elasticsearch/reference/6.1/docker.html
* Elasticsearch Configuration: https://www.elastic.co/guide/en/elasticsearch/reference/6.1/settings.html
* Important Settings: https://www.elastic.co/guide/en/elasticsearch/reference/6.1/important-settings.html
* Important System Settings: https://www.elastic.co/guide/en/elasticsearch/reference/6.1/system-config.html

### Logstash
* Logstash in Docker: https://www.elastic.co/guide/en/logstash/current/docker.html
* Logstash Configuration (Docker-specific): https://www.elastic.co/guide/en/logstash/current/_configuring_logstash_for_docker.html
* Logstash Configuration: https://www.elastic.co/guide/en/logstash/current/configuration.html

### Docker Swarm Testing
* Docker Machine: https://docs.docker.com/machine/install-machine/


### ELK Stack
* Elastic.co Docker Stack: https://github.com/elastic/stack-docker

## Best Practices (Assuming Linux)
* vm.max_map_count=262144
  * To Check: `grep vm.max_map_count /etc/sysctl.conf`
  * To Set (as root): `sysctl -w vm.max_map_count=262144`
    * Works on Mac and Linux

## Shout-outs
* Github User: kiritbasu
  * Provided source for the custom log generator
  * https://github.com/kiritbasu/Fake-Apache-Log-Generator
* Portainer: https://portainer.io