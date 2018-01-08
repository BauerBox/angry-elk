FROM phusion/baseimage:0.9.22

RUN apt-get update -y && \
    apt-get install python python-pip git -y && \
    rm -rf /var/lib/apt/lists/*

# Get the project
RUN git clone https://github.com/kiritbasu/Fake-Apache-Log-Generator.git /opt/loggen && \
    cd /opt/loggen && \
    pip install -r requirements.txt && \
    ls -lah

ENTRYPOINT ["python", "/opt/loggen/apache-fake-log-gen.py", "-n", "0", "-o", "CONSOLE", "-s", "1"]