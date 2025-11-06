# Cronicle Docker

A containerized deployment solution for [Cronicle](https://github.com/jhuckaby/Cronicle), a distributed task scheduler and runner with a web-based UI.

## Features

- 🐳 **Single-container deployment** - Easy setup for single server Cronicle instances
- 🔐 **Customizable admin credentials** - Set admin username, password, and email via environment variables
- ⚙️ **Flexible configuration** - Support for custom Cronicle configuration via JSON templates
- 📦 **Pre-built images** - Ready-to-use images available on Docker Hub
- 🔒 **Secure password hashing** - Automatic bcrypt password hashing with salt generation
- 📊 **Persistent data** - Support for volume mounting to preserve jobs and logs

Developed for [OpsBay](https://opsbay.com)


## Environment Variables

The Docker entrypoint script validates and uses the following environment variables:

### Required Variables

- **`ADMIN_USERNAME`**: Administrator username (alphanumeric characters only)
- **`ADMIN_PASSWORD`**: Administrator password (alphanumeric characters only)  
- **`ADMIN_EMAIL`**: Administrator email address (must be valid email format)

### Optional Variables

- **`HOSTNAME`**: ⚠️ **Important for upgrades/migrations** - Set a consistent hostname to avoid issues during Cronicle upgrades and data migrations. If not set, Docker will generate random hostnames which can cause problems with server identification.

- **`SETUP_JSON`**: Custom setup template for Cronicle initialization. When provided, the following placeholders will be automatically replaced:
  - `__ADMIN_USERNAME__` - Replaced with the admin username
  - `__ADMIN_HASHED_PASSWORD__` - Replaced with bcrypt-hashed password
  - `__ADMIN_SALT__` - Replaced with generated salt for password hashing
  - `__ADMIN_EMAIL__` - Replaced with the admin email address

- **`CONFIG_JSON`**: Custom configuration for Cronicle server settings (ports, logging, job limits, etc.)

## How It Works

The Docker entrypoint script performs the following operations:

1. **🔍 Validation**: Validates that admin username, password, and email meet the required format constraints
2. **⚙️ Setup** (first run only): If `config.json` doesn't exist:
   - Processes the `SETUP_JSON` template by replacing placeholders with actual values
   - Generates a secure salt and hashes the admin password using bcrypt
   - Writes processed setup and configuration templates to sample config files
   - Runs Cronicle's build process and initial setup
3. **🚀 Start**: Launches Cronicle server in the foreground with proper logging

## Building the Image

### Build Arguments

- **`CRONICLE_VERSION`**: Specify the Cronicle version to build (default: `v0.9.100`)

### Build Command

```bash
docker build --build-arg CRONICLE_VERSION=v0.9.100 -t my-cronicle:v0.9.100 .
```

### Pre-built Images

Ready-to-use Docker images are available at [Docker Hub](https://hub.docker.com/repository/docker/itefixnet/cronicle)

```bash
docker pull itefixnet/cronicle:latest
# or specific version
docker pull itefixnet/cronicle:v0.9.100
```

## Usage

### Quick Start

1. **Create persistent volumes** for data and logs:
```bash
docker volume create cronicle-data
docker volume create cronicle-logs
```

2. **Run the container** with required environment variables:
```bash
docker run -d \
    --name cronicle \
    --hostname cronicle-server \
    -p 3012:3012 \
    -v cronicle-data:/opt/cronicle/data \
    -v cronicle-logs:/opt/cronicle/logs \
    -e HOSTNAME=cronicle-server \
    -e ADMIN_USERNAME="admin" \
    -e ADMIN_PASSWORD="password123" \
    -e ADMIN_EMAIL="admin@example.com" \
    itefixnet/cronicle:latest
```

3. **Access the web interface** at `http://localhost:3012`

### Advanced Usage with Custom Configuration

For production deployments, you can provide custom setup and configuration:

```bash
docker run -d \
    --name cronicle \
    --hostname cronicle-prod \
    -p 3012:3012 \
    -v cronicle-data:/opt/cronicle/data \
    -v cronicle-logs:/opt/cronicle/logs \
    -e HOSTNAME=cronicle-prod \
    -e ADMIN_USERNAME="$(pass cronicle/admin/username)" \
    -e ADMIN_PASSWORD="$(pass cronicle/admin/password)" \
    -e ADMIN_EMAIL="$(pass cronicle/admin/email)" \
    -e SETUP_JSON="$(cat setup.json)" \
    -e CONFIG_JSON="$(cat config.json)" \
    itefixnet/cronicle:latest
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  cronicle:
    image: itefixnet/cronicle:latest
    container_name: cronicle
    hostname: cronicle-server
    ports:
      - "3012:3012"
    volumes:
      - cronicle-data:/opt/cronicle/data
      - cronicle-logs:/opt/cronicle/logs
    environment:
      - HOSTNAME=cronicle-server
      - ADMIN_USERNAME=admin
      - ADMIN_PASSWORD=securepassword123
      - ADMIN_EMAIL=admin@yourcompany.com
    restart: unless-stopped

volumes:
  cronicle-data:
  cronicle-logs:
```

Then run:
```bash
docker-compose up -d
```

## Configuration Files

This repository includes template files that can be customized:

- **`setup.json`**: Defines initial user setup, plugins, and categories
- **`config.json`**: Contains server configuration (ports, logging, job limits, webhooks, etc.)

## Security Considerations

- Change default admin credentials before production use
- Use strong passwords with alphanumeric characters
- **Set a consistent HOSTNAME** to ensure proper server identification during upgrades and migrations
- Consider using Docker secrets or external secret management for credentials
- Regularly update to the latest Cronicle version for security patches

## Troubleshooting

### Container Fails to Start
- Check that all required environment variables are set
- Verify admin credentials meet validation requirements (alphanumeric only)
- **Ensure HOSTNAME is set** to avoid server identification issues
- Check container logs: `docker logs cronicle`

### Upgrade/Migration Issues
- **Always set a consistent HOSTNAME** environment variable to maintain server identity across container restarts
- Missing hostname can cause Cronicle to treat the container as a new server during upgrades
- Use the same hostname value in both `--hostname` Docker flag and `HOSTNAME` environment variable

### Cannot Access Web Interface
- Ensure port 3012 is properly exposed and not blocked by firewall
- Verify container is running: `docker ps`
- Check if another service is using port 3012

### Data Persistence Issues
- Ensure volumes are properly mounted to `/opt/cronicle/data` and `/opt/cronicle/logs`
- Check volume permissions and ownership

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different Cronicle versions
5. Submit a pull request

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [Cronicle](https://github.com/jhuckaby/Cronicle) - The original Cronicle project
- [OpsBay](https://opsbay.com) - DevOps automation platform
