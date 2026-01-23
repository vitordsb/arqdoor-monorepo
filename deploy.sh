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

# Garantir que o script execute a partir do diretório onde ele está
cd "$(dirname "$0")"

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

# 3. Build do Frontend (Para Hostinger Web Hosting)
echo -e "\n${YELLOW}>>> 2. Build do Frontend para Hostinger Web Hosting...${NC}"
cd frontend

echo "Instalando dependências..."
npm install

echo "Gerando build de produção..."
# Garantir que a URL da API esteja correta no build
export VITE_API_URL="https://api.arqdoor.com"
npm run build

echo -e "${GREEN}>>> Build Concluído!${NC}"
echo -e "Os arquivos estão na pasta: ${BLUE}frontend/dist${NC}"

echo -e "\n${YELLOW}>>> INSTRUÇÕES PARA HOSTINGER WEB HOSTING: <<<${NC}"
echo "1. Acesse o Gerenciador de Arquivos da Hostinger"
echo "2. Vá para public_html"
echo "3. Faça upload do conteúdo da pasta 'frontend/dist'"
echo "   (index.html, assets/, etc)"

echo -e "\n${BLUE}>>> DEPLOY BACKEND COMPLETO! <<<${NC}"
echo -e "Backend: https://api.arqdoor.com/doc"
