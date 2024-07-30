# Traefik Cert Exporter

This project provides a script and Docker setup to extract and monitor certificates from `acme.json` for Traefik. The script handles graceful shutdowns, supports multiple domains, and includes debug logging.

## Features

- Extracts certificates from `acme.json` for specified domains.
- Supports multiple domains.
- Monitors `acme.json` for changes and updates certificates accordingly.
- Handles SIGTERM for graceful shutdown.
- Includes debug logging.

## Prerequisites

- Docker
- Docker Compose (if using `docker-compose.yml`)

## Usage

### Environment Variables

The following environment variables can be configured:

- `ACME_JSON_PATH` (default: `/acme.json`): Path to the `acme.json` file.
- `CERTS_DIR` (default: `/certs`): Destination directory for certificates.
- `DOMAINS` (default: `example.com`): Comma-separated list of domains.
- `DEBUG` (default: `false`): Enable debug logging.
- `LOG_FILE` (default: `/var/log/extract_certs.log`): Path to the log file.

### Output Filenames

For each domain, the extracted certificate and key will be saved as:
- `fullchain.pem`: Full chain certificate
- `privkey.pem`: Private key

These filenames will be prefixed with the domain name, for example:
- `example.com_fullchain.pem`
- `example.com_privkey.pem`

### Build and Run with Docker

1. **Build the Docker image:**

    ```bash
    docker build -t traefik-cert-exporter .
    ```

2. **Run the Docker container:**

    ```bash
    docker run -d \
        -e ACME_JSON_PATH=/path/to/acme.json \
        -e CERTS_DIR=/path/to/certs \
        -e DOMAINS=example.com,anotherdomain.com \
        -e DEBUG=true \
        -e LOG_FILE=/var/log/extract_certs.log \
        -v /path/to/acme.json:/acme.json \
        -v /path/to/certs:/certs \
        -v /path/to/logs:/var/log \
        --name traefik-cert-exporter \
        traefik-cert-exporter
    ```

### Using Docker Compose

1. **Update `docker-compose.yml` with the correct paths and domains:**

    ```yaml
    version: '3.8'
    services:
      cert_exporter:
        build: .
        environment:
          - ACME_JSON_PATH=/acme.json
          - CERTS_DIR=/certs
          - DOMAINS=example.com,anotherdomain.com
          - DEBUG=true
          - LOG_FILE=/var/log/extract_certs.log
        volumes:
          - ./acme.json:/acme.json
          - ./certs:/certs
          - ./logs:/var/log
        stop_grace_period: 5s
    ```

2. **Run Docker Compose:**

    ```bash
    docker-compose up -d
    ```

## File Structure

- `Dockerfile`: Defines the Docker image.
- `update-certs.sh`: Script to extract and monitor certificates.
- `docker-compose.yml`: Docker Compose configuration file.
- `README.md`: Project documentation.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License.
