#!/bin/bash
# Patch 002: Diagnose and fix Portainer restart loop
# Issue: CHK092 - Portainer container in continuous restart loop (exit code 1)

set -e

echo "=========================================="
echo "Patch 002: Portainer Diagnostics & Fix"
echo "=========================================="
echo ""

# Check if running from project root
if [ ! -f "Makefile" ]; then
    echo "❌ Error: Must run from project root (where Makefile is located)"
    exit 1
fi

echo "Step 1: Checking container status..."
if docker ps -a --filter "name=portainer" | grep -q portainer; then
    CONTAINER_ID=$(docker ps -a --filter "name=portainer" --format "{{.ID}}")
    STATUS=$(docker ps -a --filter "name=portainer" --format "{{.Status}}")
    echo "✅ Portainer container found"
    echo "   Container ID: $CONTAINER_ID"
    echo "   Status: $STATUS"
else
    echo "❌ Portainer container not found"
    echo "   Run 'make up' first to start services"
    exit 1
fi
echo ""

echo "Step 2: Inspecting container logs (last 50 lines)..."
echo "----------------------------------------"
docker logs --tail 50 "$CONTAINER_ID" 2>&1
echo "----------------------------------------"
echo ""

echo "Step 3: Checking container configuration..."
echo "----------------------------------------"
docker inspect "$CONTAINER_ID" --format='
Image: {{.Config.Image}}
Command: {{.Config.Cmd}}
Entrypoint: {{.Config.Entrypoint}}
Working Dir: {{.Config.WorkingDir}}
Restart Policy: {{.HostConfig.RestartPolicy.Name}}
Exit Code: {{.State.ExitCode}}
Error: {{.State.Error}}
'
echo "----------------------------------------"
echo ""

echo "Step 4: Checking volume mounts..."
echo "----------------------------------------"
docker inspect "$CONTAINER_ID" --format='{{range .Mounts}}
Type: {{.Type}}
Source: {{.Source}}
Destination: {{.Destination}}
Mode: {{.Mode}}
{{end}}'
echo "----------------------------------------"
echo ""

echo "Step 5: Checking port mappings..."
echo "----------------------------------------"
docker inspect "$CONTAINER_ID" --format='{{range $p, $conf := .NetworkSettings.Ports}}
{{$p}} -> {{(index $conf 0).HostPort}}{{end}}'
echo "----------------------------------------"
echo ""

echo "Step 6: Analyzing common issues..."
echo ""

# Check for volume permission issues
VOLUME_SOURCE=$(docker inspect "$CONTAINER_ID" --format='{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}')
if [ -n "$VOLUME_SOURCE" ]; then
    echo "Checking volume permissions for: $VOLUME_SOURCE"
    if [ -d "$VOLUME_SOURCE" ]; then
        ls -ld "$VOLUME_SOURCE"
        echo ""
    else
        echo "⚠️  Volume directory does not exist: $VOLUME_SOURCE"
        echo ""
    fi
fi

# Check if port is already in use
PORTAINER_PORT=$(docker inspect "$CONTAINER_ID" --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if eq $p "9443/tcp"}}{{(index $conf 0).HostPort}}{{end}}{{end}}')
if [ -n "$PORTAINER_PORT" ]; then
    echo "Checking if port $PORTAINER_PORT is available..."
    if netstat -tuln 2>/dev/null | grep -q ":$PORTAINER_PORT "; then
        echo "⚠️  Port $PORTAINER_PORT is in use by another process"
        netstat -tuln | grep ":$PORTAINER_PORT "
    else
        echo "✅ Port $PORTAINER_PORT is available"
    fi
    echo ""
fi

echo "=========================================="
echo "Diagnostic Information Collected"
echo "=========================================="
echo ""
echo "Common Portainer Issues and Fixes:"
echo ""
echo "1. Volume Permission Issues:"
echo "   - Fix: chown -R root:root $VOLUME_SOURCE"
echo "   - Or: sudo chown -R \$USER:\$USER $VOLUME_SOURCE"
echo ""
echo "2. Port Conflict (9443 already in use):"
echo "   - Fix: Change port in docker-compose.yml"
echo "   - Example: '9444:9443' instead of '9443:9443'"
echo ""
echo "3. Missing TLS Certificates:"
echo "   - Check if Portainer expects certs in /data/certs/"
echo "   - Add volume or disable HTTPS in config"
echo ""
echo "4. Incorrect Command/Entrypoint:"
echo "   - Portainer expects no custom CMD in Dockerfile"
echo "   - Remove any CMD/ENTRYPOINT from Dockerfile if present"
echo ""
echo "5. Docker Socket Mount Missing:"
echo "   - Portainer needs: /var/run/docker.sock:/var/run/docker.sock"
echo "   - Check docker-compose.yml volumes section"
echo ""
echo "Suggested Actions:"
echo ""
echo "1. Review the logs above for specific error messages"
echo "2. Check srcs/requirements/bonus/portainer/Dockerfile"
echo "   - Ensure it's FROM portainer/portainer-ce:latest"
echo "   - Should have NO custom CMD or ENTRYPOINT"
echo ""
echo "3. Check docker-compose.yml portainer service:"
echo "   - Volume: /var/run/docker.sock:/var/run/docker.sock"
echo "   - Volume: portainer_data:/data"
echo "   - Ports: 9443:9443"
echo ""
echo "To fix, edit the relevant files and run:"
echo "  make down && make up"
