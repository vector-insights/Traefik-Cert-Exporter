
FROM alpine:3.20

# Install necessary packages
RUN apk add --no-cache bash jq inotify-tools

# Copy the script into the container
COPY update-certs.sh /usr/local/bin/update-certs.sh
RUN chmod +x /usr/local/bin/update-certs.sh

# Default environment variables
ENV ACME_JSON_PATH="/acme.json" \
    CERTS_DIR="/certs" \
    DOMAINS="example.com" \
    DEBUG="false" \
    LOG_FILE="/var/log/extract_certs.log"

# Set the stop signal to SIGTERM
STOPSIGNAL SIGTERM

# Run the script
CMD ["/usr/local/bin/update-certs.sh"]
