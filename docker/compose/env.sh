#!/usr/bin/env bash

# For everything except Kibana
export ELASTIC_PASSWORD="angry-elk"

# For Kibana
export ELASTICSEARCH_PASSWORD="angry-elk"

# For Elastic's Stack Packages
export ELASTIC_VERSION=6.1.1
export TAG=6.1.1