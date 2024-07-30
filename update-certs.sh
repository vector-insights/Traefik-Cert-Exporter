#!/bin/bash

# Path to the acme.json file
ACME_JSON_PATH="${ACME_JSON_PATH:-/acme.json}"

# Destination directory for certificates
CERTS_DIR="${CERTS_DIR:-/certs}"

# Function to extract certificates
extract_certs() {
    certificate=$(cat "$ACME_JSON_PATH" | jq -r --arg DOMAIN "$DOMAIN" '.["dns-cloudflare"].Certificates[] | select(.domain.main==$DOMAIN) | .certificate')
    key=$(cat "$ACME_JSON_PATH" | jq -r --arg DOMAIN "$DOMAIN" '.["dns-cloudflare"].Certificates[] | select(.domain.main==$DOMAIN) | .key')
    ca=$(cat "$ACME_JSON_PATH" | jq -r --arg DOMAIN "$DOMAIN" '.["dns-cloudflare"].Certificates[] | select(.domain.main==$DOMAIN) | .issuerCertificate')
    if [[ -n "$certificate" && -n "$key" ]]; then
        echo "$certificate" | base64 -d > "$CERTS_DIR/fullchain.pem"
        echo "$key" | base64 -d > "$CERTS_DIR/privkey.pem"
        echo "$ca" | base64 -d > "$CERTS_DIR/ca.pem"
    else
        echo "Failed to find certificates for domain $DOMAIN"
        exit 1
    fi
}

# Initial extraction of certificates
extract_certs

# Check if the certificates are successfully extracted
if [[ -f "$CERTS_DIR/fullchain.pem" && -f "$CERTS_DIR/privkey.pem" && -f "$CERTS_DIR/ca.pem" ]]; then
    echo "Certificates extracted successfully"
else
    echo "Failed to extract certificates"
    exit 1
fi

# Monitor the acme.json file for changes
echo "Monitoring $ACME_JSON_PATH for changes..."

while true; do
    inotifywait -e close_write $ACME_JSON_PATH
    echo "Detected change in $ACME_JSON_PATH. Extracting certificates..."
    extract_certs

    # Check if the certificates are successfully extracted
    if [[ -f "$CERTS_DIR/fullchain.pem" && -f "$CERTS_DIR/privkey.pem" && -f "$CERTS_DIR/ca.pem" ]]; then
        echo "Certificates updated successfully"
    else
        echo "Failed to update certificates"
    fi
done
