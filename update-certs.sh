
#!/bin/bash

# Default configurations
ACME_JSON_PATH="${ACME_JSON_PATH:-/acme.json}"
CERTS_DIR="${CERTS_DIR:-/certs}"
DOMAINS="${DOMAINS:-example.com}"  # Comma-separated list of domains
DEBUG="${DEBUG:-false}"
LOG_FILE="${LOG_FILE:-/var/log/extract_certs.log}"

# Function to log messages
log() {
    local message="$1"
    if [[ "$DEBUG" == "true" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $message" | tee -a "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') $message" >> "$LOG_FILE"
    fi
}

# Function to handle SIGTERM and exit gracefully
cleanup() {
    log "Received SIGTERM, exiting..."
    exit 0
}

# Trap SIGTERM signal
trap cleanup SIGTERM

# Function to extract certificates for a given domain
extract_cert_for_domain() {
    local domain="$1"
    log "Extracting certificates for domain: $domain"

    certificate=$(cat "$ACME_JSON_PATH" | jq -r --arg DOMAIN "$domain" '.["dns-cloudflare"].Certificates[] | select(.domain.main==$DOMAIN) | .certificate')
    key=$(cat "$ACME_JSON_PATH" | jq -r --arg DOMAIN "$domain" '.["dns-cloudflare"].Certificates[] | select(.domain.main==$DOMAIN) | .key')

    if [[ -n "$certificate" && -n "$key" ]]; then
        echo "$certificate" | base64 -d > "$CERTS_DIR/${domain}_fullchain.pem"
        echo "$key" | base64 -d > "$CERTS_DIR/${domain}_privkey.pem"
        log "Certificates extracted successfully for domain: $domain"
    else
        log "Failed to find certificates for domain: $domain"
    fi
}

# Initial extraction of certificates for all domains
IFS=',' read -ra ADDR <<< "$DOMAINS"
for domain in "${ADDR[@]}"; do
    extract_cert_for_domain "$domain"
done

# Check if the certificates are successfully extracted
if [[ -f "$CERTS_DIR/${ADDR[0]}_fullchain.pem" && -f "$CERTS_DIR/${ADDR[0]}_privkey.pem" ]]; then
    log "Certificates extracted successfully"
else
    log "Failed to extract certificates"
    exit 1
fi

# Monitor the acme.json file for changes
log "Monitoring $ACME_JSON_PATH for changes..."

while true; do
    inotifywait -e close_write $ACME_JSON_PATH
    log "Detected change in $ACME_JSON_PATH. Extracting certificates..."
    for domain in "${ADDR[@]}"; do
        extract_cert_for_domain "$domain"
    done

    # Check if the certificates are successfully extracted
    if [[ -f "$CERTS_DIR/${ADDR[0]}_fullchain.pem" && -f "$CERTS_DIR/${ADDR[0]}_privkey.pem" ]]; then
        log "Certificates updated successfully"
    else
        log "Failed to update certificates"
    fi
done
