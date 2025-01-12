# Dockerfile
FROM caddy:builder AS builder

# Install the Cloudflare DNS module
RUN xcaddy build --with github.com/caddy-dns/cloudflare

FROM caddy:latest

# Copy the custom-built binary into the final image
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
