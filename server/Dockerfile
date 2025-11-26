# Use Node.js LTS as base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install OpenCode globally
RUN npm install -g opencode-ai

# Set environment variables
# Note: PORT will be injected by Cloud Run (default 8080), do not hardcode
ENV HOSTNAME=0.0.0.0
ENV NODE_ENV=production

# Expose the default OpenCode server port (8080 for Cloud Run)
EXPOSE 8080

# Health check to ensure the server is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=5 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:${PORT:-8080}/doc || exit 1

# Create a non-root user for security
RUN addgroup -g 1001 -S opencode && \
    adduser -S opencode -u 1001

# Switch to non-root user
USER opencode

# Ensure OpenCode config directory exists
RUN mkdir -p /home/opencode/.config/opencode

# Copy OpenCode config into the image
COPY opencode.json /home/opencode/.config/opencode/opencode.json

# Start the OpenCode server
CMD ["/bin/sh", "-c", "/usr/local/lib/node_modules/opencode-ai/node_modules/opencode-linux-x64-musl/bin/opencode serve --port ${PORT:-8080} --hostname 0.0.0.0"]
