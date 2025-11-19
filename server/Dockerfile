# Use Node.js LTS as base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install OpenCode globally
RUN npm install -g opencode-ai

# Set environment variables
ENV PORT=4096
ENV HOSTNAME=0.0.0.0
ENV NODE_ENV=production

# Expose the default OpenCode server port
EXPOSE 4096

# Health check to ensure the server is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=5 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:4096/doc || exit 1

# Create a non-root user for security
RUN addgroup -g 1001 -S opencode && \
    adduser -S opencode -u 1001

# Switch to non-root user
USER opencode

# Create OpenCode config directory and config file
RUN mkdir -p /home/opencode/.config/opencode && \
    echo '{"$schema":"https://opencode.ai/config.json","model":"opencode/big-pickle"}' > /home/opencode/.config/opencode/opencode.json

# Start the OpenCode server
CMD ["/bin/sh", "-c", "/usr/local/lib/node_modules/opencode-ai/node_modules/opencode-linux-x64-musl/bin/opencode serve --port ${PORT:-4096} --hostname 0.0.0.0"]
