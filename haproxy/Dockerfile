# HAProxy Dockerfile for ISMS development environment
FROM haproxy:2.8-alpine

# Copy HAProxy configuration
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Create necessary directories with proper permissions
RUN mkdir -p /var/lib/haproxy && \
    chown haproxy:haproxy /var/lib/haproxy

# Expose ports
EXPOSE 80 8404

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg || exit 1

# Start HAProxy
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
