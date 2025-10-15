FROM node:18-alpine

# Install required tools
RUN apk add --no-cache curl tar bash procps

# Install convenient tools
RUN apk add --no-cache git jq openssh-client pass gpg

# Cronicle version
ARG CRONICLE_VERSION=v0.9.97
ENV CRONICLE_VERSION=${CRONICLE_VERSION}

# Set working directory
WORKDIR /opt/cronicle

# Download and extract Cronicle
RUN curl -L https://github.com/jhuckaby/Cronicle/archive/tags/${CRONICLE_VERSION}.tar.gz | tar zxvf - --strip-components 1

# Install dependencies and build
RUN npm install bcrypt
RUN npm install

# Expose default ports
# 3012 - Web UI
EXPOSE 3012

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
