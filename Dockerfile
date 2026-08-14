FROM node:22-bookworm-slim

# Install required tools for native modules (if any) and python for build scripts
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@11.7.0

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Patch the source code to allow binding to 0.0.0.0 natively
# This prevents the 403 Forbidden errors that occur when using a reverse proxy or socat
RUN sed -i "s/if (options.host === '0.0.0.0')/if (false)/g" packages/bundle/web-app/src/startup.ts

# Install dependencies
RUN pnpm install

# Build the project
RUN pnpm run build

# Expose Web UI default port
EXPOSE 3080

# Start command: natively bind to 0.0.0.0
# If you are accessing via a domain, you can pass TRUSTED_HOST env variable when running the container
# e.g., -e TRUSTED_HOST=http://your-nas-ip:3080
CMD sh -c "pnpm dsh web --host 0.0.0.0 ${TRUSTED_HOST:+--trusted-host $TRUSTED_HOST}"
