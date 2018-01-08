#!/usr/bin/env bash

# Where am I?
OWD="$( pwd )"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}

# Image Prefix
prefix="angry-elk"

# Iterate directory
for path in ./*; do
    # Skip if it's not a directory
    [ -d "${path}" ] || continue

    # Skip if there's no Dockerfile
    [ -f "${path}/Dockerfile" ] || continue

    # Declare the image
    image="${path:2}"

    # Announce
    echo "Building image: ${prefix}/${image}"

    # Run
    docker build -t "${prefix}/${image}" "${path}"
done

# All Done!
echo ""
echo "All angry ELK images have been built!"
echo "Go forth and take over the world!"
echo "#hugops #happyops"

# Back to Kansas
cd ${OWD}