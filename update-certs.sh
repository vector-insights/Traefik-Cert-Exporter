#!/bin/bash

# Path to the acme.json file
ACME_JSON_PATH="/path/to/acme.json"

# Destination directory for certificates
CERTS_DIR="/certs"

# Function to extract certificates
extract_certs() {
    cat "$ACME_JSON_PATH" | jq -r '.letsencrypt.Certificates[] | select(.domain.main=="yourdomain.com") | .certificate' | base64 -d > "$CERTS_DIR/fullchain.pem"
    cat "$ACME_JSON_PATH" | jq -r '.letsencrypt.Certificates[] | select(.domain.main=="yourdomain.com") | .key' | base64 -d > "$CERTS_DIR/privkey.pem"
}

# Extract certificates
extract_certs

# Check if the certificates are successfully extracted
if [[ -f "$CERTS_DIR/fullchain.pem" && -f "$CERTS_DIR/privkey.pem" ]]; then
    echo "Certificates extracted successfully"
    exit 0
else
    echo "Failed to extract certificates"
    exit 1
fi
