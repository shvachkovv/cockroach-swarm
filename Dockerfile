FROM debian:8.11

# Install root CAs so we can make SSL connections to phone home and
# do backups to GCE/AWS/Azure.
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y ca-certificates dnsutils wget tar && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /cockroach
RUN wget -qO- https://binaries.cockroachdb.com/cockroach-v2.1.4.linux-amd64.tgz | tar  xvz && \
    cp cockroach-v2.1.4.linux-amd64/cockroach /cockroach/
COPY cockroach.sh /cockroach/
# Set working directory so that relative paths
# are resolved appropriately when passed as args.
WORKDIR /cockroach/

RUN chmod -R a+rx /cockroach/

ENV COCKROACH_CHANNEL=official-docker

EXPOSE 26257 8080
ENTRYPOINT ["/cockroach/cockroach.sh"]