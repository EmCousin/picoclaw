#!/bin/sh
set -e

# Fix Docker socket permissions if mounted (allows picoclaw user to run docker commands)
if [ -S /var/run/docker.sock ]; then
    chgrp docker /var/run/docker.sock 2>/dev/null || true
fi

# First-run: neither config nor workspace exists for picoclaw user
if [ ! -d "/home/picoclaw/.picoclaw/workspace" ] && [ ! -f "/home/picoclaw/.picoclaw/config.json" ]; then
    su - picoclaw -c "picoclaw onboard"
    echo ""
    echo "First-run setup complete."
    echo "Edit /home/picoclaw/.picoclaw/config.json (add your API key, etc.) then restart the container."
    exit 0
fi

# Run picoclaw gateway as picoclaw user
exec su - picoclaw -c "picoclaw gateway"
