FROM docker.elastic.co/elasticsearch/elasticsearch:6.1.1

# Copy Custom YML Config
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/

# Snapshots Config
RUN mkdir -p /usr/share/elasticsearch/snapshots && \
    chown elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots

# Expose Snapshots Volume
VOLUME "/usr/share/elasticsearch/snapshots"
