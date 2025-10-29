#!/bin/bash
# RANSOMWARE SANDBOX v1.0 — ONE FILE, GITHUB GIST
# Paste this into https://gist.github.com → Click "Create secret gist"
# Then run: curl -sSL <your-gist-url> | bash

set -e

echo "Deploying SandBoxCode Ransomware Lab..."

PROJECT_DIR=$(mktemp -d)
cd "$PROJECT_DIR"

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: sandcode
      POSTGRES_USER: sandcode
      POSTGRES_PASSWORD: sandcode
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped

  api:
    image: sandboxcode/api:latest
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgresql://sandcode:sandcode@db:5432/sandcode
      SECRET_KEY: tempkey123
    restart: unless-stopped

  windows-agent:
    image: sandboxcode/windows-agent:latest
    privileged: true
    depends_on:
      - api
    volumes:
      - samples:/samples
    restart: unless-stopped

volumes:
  pgdata:
  samples:
EOF

echo "Starting services..."
docker compose up -d

echo "Waiting for API..."
until curl -s http://localhost:8000/api/status > /dev/null 2>&1; do sleep 2; done

echo "Creating admin user..."
curl -s -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin","is_admin":true}' > /dev/null

echo ""
echo "RANSOMWARE SANDBOX READY!"
echo "Web UI: http://localhost:8000"
echo "Login:  admin / admin"
echo ""
echo "Upload ransomware → Analyze → Get ransom note, C2, Bitcoin"
echo "Stop: docker compose down"
echo ""
echo "Sample:"
echo "  wget -O sample.exe 'https://bazaar.abuse.ch/sample/2f3c5a1b8e7d9f...babuk/'"
echo "  (Password: infected)"
