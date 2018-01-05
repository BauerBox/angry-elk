FROM docker.elastic.co/logstash/logstash:6.1.1

# Install Custom Logstash Plugins
RUN cd /usr/share/logstash \
    && bin/logstash-plugin install logstash-output-syslog \
    && bin/logstash-plugin install logstash-filter-aggregate \
    && bin/logstash-plugin install logstash-filter-kv \
    && bin/logstash-plugin install logstash-filter-json \
    && bin/logstash-plugin install logstash-filter-useragent

# Ensure default config file is removed
RUN rm -f /usr/share/logstash/pipeline/logstash.conf

# Copy Custom Config Files
COPY logstash.yml /usr/share/logstash/config/logstash.yml
COPY pipeline /usr/share/logstash/pipeline
COPY patterns /usr/share/logstash/patterns
COPY data /usr/share/logstash/data

# Add Ports to EXPOSE
EXPOSE 5000 5000/udp 51415

# HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s \
    CMD curl -f localhost:9600/_node/stats/process || exit 1

# Test Config File
# This will prevent the image from building in the event any of the logstash pipeline configuration files contain errors
RUN logstash -t
