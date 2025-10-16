# Cronicle Docker
- Docker setup for single server Cronicle
- Supports custom admin credentials/e-mail via a setup.json template file
- Supports configuration customizations via a config.json file

  Developed for [OpsBay](https://opsbay.com)


## Environment Variables

The entrypoint script validates and uses the following environment variables:

- `ADMIN_USERNAME`: Must contain only letters and numbers.
- `ADMIN_PASSWORD`: Must contain only letters and numbers.
- `ADMIN_EMAIL`: Must be a valid email address.
- `SETUP_JSON`: (Optional) Template for Cronicle setup. Placeholders:
  - `__ADMIN_USERNAME__`
  - `__ADMIN_HASHED_PASSWORD__`
  - `__ADMIN_SALT__`
  - `__ADMIN_EMAIL__`
- `CONFIG_JSON`: (Optional) Custom config for Cronicle.

## Entrypoint Logic

1. **Validation**: The script checks that admin username, password, and email are valid.
2. **Setup**: If `config.json` does not exist, it:
   - Replaces placeholders in `SETUP_JSON` with provided values.
   - Hashes the password with a random salt.
   - Writes `SETUP_JSON` and `CONFIG_JSON` to sample config files.
   - Runs Cronicle build and setup.
3. **Start**: Launches Cronicle in the foreground.

## Build

For Cronicle vN.N.NN

```bash
docker build --build-arg CRONICLE_VERSION=vN.N.NN -t my-cronicle:vN.N.NN .
```

Ready-to-use Docker images are available at [Docker Hub](https://hub.docker.com/repository/docker/itefixnet/cronicle)

## Usage

Set the required environment variables and run the container:

```bash
version=1.0
docker volume create cronicle-data
docker volume create cronicle-logs

docker run  -d \
    --name cronicle \
    -p 3012:3012 \
    -v cronicle-data:/opt/cronicle/data \
    -v cronicle-logs:/opt/cronicle/logs \
    -e ADMIN_USERNAME="$(pass cronicle/admin/username)" \
    -e ADMIN_PASSWORD="$(pass cronicle/admin/password)" \
    -e ADMIN_EMAIL="$(pass cronicle/admin/email)" \
    -e SETUP_JSON="$(cat setup.json)" \
    -e CONFIG_JSON="$(cat config.json)" \
    itefixnet/cronicle:$version
```
