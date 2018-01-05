FROM alpine:3.7

# Upgrade (just in case there are security updates)
RUN apk update -v \
    && apk upgrade -v --no-cache

# Install Build Deps
RUN apk add \
        ca-certificates \
        openssl \
        libffi-dev \
        python2 \
        py2-pip \
        py2-yaml \
        tzdata \
        wget \
        git \
        bash \
    && mkdir -p /opt/loggen
# gcc alpine-sdk build-base

# Get the project
RUN git clone https://github.com/kiritbasu/Fake-Apache-Log-Generator.git /opt/loggen && \
    cd /opt/loggen && \
    pip install -r requirements.txt

