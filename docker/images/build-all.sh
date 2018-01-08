#!/bin/sh

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
    if [ $? -ne 0 ]; then
        echo "> Image ${prefix}/${image} failed to build!"
    else
        echo "> Image built successfully!"
    fi
done

# All Done!
echo ""
echo "All angry ELK images have been built!"
echo "Go forth and take over the world!"
echo "#hugops #happyops"
