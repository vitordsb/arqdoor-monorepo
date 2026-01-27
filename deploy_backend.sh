#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

VPS_IP="89.116.225.129"
VPS_USER="root"
VPS_PASS="7QSuvA8gt9MGms;yLnS."
REMOTE_DIR="/var/www/arqdoor-monorepo"

echo -e "${YELLOW}>>> 1. Enviando backend para o Git...${NC}"
git add .
git commit -m "deploy: update backend logic (unread messages)"
git push origin main

echo -e "\n${YELLOW}>>> 2. Deploy do Backend na VPS ($VPS_IP)...${NC}"
sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_IP << EOF
    cd $REMOTE_DIR
    echo "Puxando atualizações..."
    git pull origin main
    # git submodule update --init --recursive 
    
    echo "Reconstruindo Backend..."
    docker compose -f docker-compose.backend-only.yml down
    docker compose -f docker-compose.backend-only.yml up -d --build backend
    docker compose -f docker-compose.backend-only.yml ps
EOF

echo -e "${GREEN}>>> Backend Deployed com Sucesso!${NC}"
