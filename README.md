# 🏗️ ArqDoor Monorepo

Repositório principal do projeto ArqDoor contendo configuração Docker e referências aos repositórios backend e frontend como submodules.

## 📦 Estrutura

```
arqdoor-monorepo/
├── backend/          # Submodule: API Node.js
├── frontend/         # Submodule: App React
├── mysql/            # Configuração MySQL
├── nginx/            # Reverse proxy (produção)
├── docker-compose.yml         # Desenvolvimento
├── docker-compose.prod.yml    # Produção
├── .env.docker.example        # Template de variáveis
└── README-DOCKER.md           # Documentação Docker
```

## 🚀 Quick Start

### 1. Clonar com Submodules

```bash
# Clone o repositório com submodules
git clone --recursive https://github.com/SEU_USUARIO/arqdoor-monorepo.git

# Ou se já clonou sem --recursive:
git submodule update --init --recursive
```

### 2. Configurar Ambiente

```bash
# Copiar template de variáveis
cp .env.docker.example .env.docker

# Editar com suas credenciais
nano .env.docker
```

### 3. Iniciar com Docker

```bash
# Desenvolvimento (com hot-reload)
docker compose up -d

# Ver logs
docker compose logs -f backend

# Parar
docker compose down
```

### 4. Acessar Aplicação

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Swagger Docs**: http://localhost:8080/doc
- **MySQL**: localhost:3307 (porta alterada para evitar conflito)

## 📝 Comandos Úteis

### Atualizar Submodules

```bash
# Atualizar todos os submodules para última versão
git submodule update --remote

# Atualizar apenas backend
git submodule update --remote backend

# Atualizar apenas frontend
git submodule update --remote frontend
```

### Docker

```bash
# Rebuild após mudanças
docker compose up -d --build

# Ver status
docker compose ps

# Acessar container
docker compose exec backend sh
docker compose exec mysql mysql -u arqdoor -p

# Limpar tudo
docker compose down -v
```

## 🔧 Desenvolvimento

### Trabalhar em um Submodule

```bash
# Entrar no submodule
cd backend  # ou frontend

# Criar branch
git checkout -b feature/nova-funcionalidade

# Fazer commits normalmente
git add .
git commit -m "feat: nova funcionalidade"

# Push para o repositório do submodule
git push origin feature/nova-funcionalidade

# Voltar para o monorepo
cd ..

# Commit da referência atualizada do submodule
git add backend
git commit -m "chore: update backend submodule"
git push
```

## 🚀 Deploy Produção

```bash
# Build e iniciar em produção
docker compose -f docker-compose.prod.yml up -d --build

# Escalar backend (2 réplicas)
docker compose -f docker-compose.prod.yml up -d --scale backend=2
```

## 📚 Documentação

- [README-DOCKER.md](./README-DOCKER.md) - Guia completo Docker
- [Backend README](./backend/README.md) - Documentação da API
- [Frontend README](./frontend/README.md) - Documentação do App

## 🤝 Contribuindo

1. Clone com submodules
2. Crie uma branch no submodule apropriado
3. Faça suas alterações
4. Teste com Docker
5. Commit e push no submodule
6. Atualize referência no monorepo

## 📄 Licença

Este projeto está sob a licença MIT.
