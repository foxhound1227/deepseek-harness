FROM node:22-bookworm-slim

# Install required tools for native modules (if any) and python for build scripts
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@11.7.0

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install dependencies
RUN pnpm install

# Build the project
RUN pnpm run build

# Expose Web UI default port
EXPOSE 3080

# Start command
CMD socat TCP-LISTEN:3080,fork,bind=0.0.0.0 TCP:127.0.0.1:3081 & pnpm dsh web --port 3081
