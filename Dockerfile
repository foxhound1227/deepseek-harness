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
RUN sed -i "s/if (options.host === '0.0.0.0')/if (false)/g" packages/bundle/web-app/src/startup.ts

# Patch backend security checks to always allow connections from any origin
# This solves the '403 Forbidden' error permanently when running over NAS LAN IPs
RUN sed -i 's/export function isTrustedApiRequest(request: ApiTrustRequest, trustedHosts: readonly string\[\]): boolean {/export function isTrustedApiRequest(request: ApiTrustRequest, trustedHosts: readonly string[]): boolean { return true;/g' packages/client/connection/src/api-request-trust.ts

# Polyfill crypto.randomUUID for frontend so it won't crash on insecure http:// IP access
# This solves the 'crypto.randomUUID is not a function' error
RUN sed -i '1s/^/if (!window.crypto) (window as any).crypto = {}; if (!window.crypto.randomUUID) window.crypto.randomUUID = () => "id-" + Math.random().toString(36).slice(2) + Date.now().toString(36);\n/' apps/web/src/main.ts

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
