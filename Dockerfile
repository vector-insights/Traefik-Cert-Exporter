# Base image
FROM alpine:3.20

# Install necessary tools
RUN apk add --no-cache jq bash inotify-tools

# Create directory for scripts and certificates
RUN mkdir -p /scripts /certs

# Copy the certificate extraction script
COPY update-certs.sh /scripts/update-certs.sh

# Give execute permission to the script
RUN chmod +x /scripts/update-certs.sh

# Command to run the script
CMD ["/scripts/update-certs.sh"]
