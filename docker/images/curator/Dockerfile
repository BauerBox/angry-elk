FROM phusion/baseimage:0.9.22

RUN apt-get update -y && \
    apt-get install python python-pip -y && \
    pip install --quiet elasticsearch-curator && \
    rm -rf /var/lib/apt/lists/*

COPY etc/cron.d/* /etc/cron.d
COPY etc/curator /etc/curator

RUN chmod 644 /etc/cron.d/*