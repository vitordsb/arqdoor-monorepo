#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
VPS_IP="89.116.225.129"
VPS_USER="root"
REMOTE_DIR="/var/www/arqdoor-monorepo"

echo -e "${BLUE}>>> Iniciando Deploy Automatizado do ArqDoor <<<${NC}"

# 1. Verificar Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo -e "${RED}Erro: Vercel CLI não encontrado.${NC}"
    echo "Instale com: npm i -g vercel"
    exit 1
fi

# 2. Deploy Backend (VPS)
echo -e "\n${YELLOW}>>> 1. Deploy do Backend na VPS ($VPS_IP)...${NC}"
echo "Enviando alterações para o Git..."
git add .
git commit -m "deploy: update backend and frontend"
git push origin main

echo "Conectando na VPS para atualizar..."
ssh $VPS_USER@$VPS_IP << EOF
    cd $REMOTE_DIR
    echo "Puxando atualizações..."
    git pull origin main
    
    echo "Reconstruindo Backend..."
    # Parar backend antigo
    docker compose -f docker-compose.backend-only.yml down
    
    # Subir novo backend (com build)
    docker compose -f docker-compose.backend-only.yml up -d --build backend
    
    # Verificar status
    docker compose -f docker-compose.backend-only.yml ps
EOF

echo -e "${GREEN}>>> Backend Deployed com Sucesso!${NC}"

# 3. Deploy Frontend (Vercel)
echo -e "\n${YELLOW}>>> 2. Deploy do Frontend na Vercel...${NC}"
cd frontend

# Deploy para produção
echo "Enviando para Vercel (Produção)..."
vercel --prod

echo -e "${GREEN}>>> Frontend Deployed com Sucesso!${NC}"

echo -e "\n${BLUE}>>> DEPLOY COMPLETO! <<<${NC}"
echo -e "Backend: https://api.arqdoor.com/doc"
echo -e "Frontend: https://arqdoor.com (ou URL da Vercel)"
