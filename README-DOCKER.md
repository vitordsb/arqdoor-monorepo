# 🐳 ArqDoor - Docker Guide

## Quick Start

### Development
```bash
# 1. Copy environment file
cp .env.docker.example .env.docker

# 2. Edit .env.docker with your values
nano .env.docker

# 3. Start all services
docker-compose up -d

# 4. View logs
docker-compose logs -f backend

# 5. Access application
# Frontend: http://localhost:5173
# Backend API: http://localhost:8080
# Swagger Docs: http://localhost:8080/doc
```

### Production
```bash
# 1. Set production environment variables in .env.docker

# 2. Deploy
docker-compose -f docker-compose.prod.yml up -d --build

# 3. Scale backend (optional)
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

---

## 📦 Services

| Service | Port | Description |
|---------|------|-------------|
| **MySQL** | 3306 | Database |
| **Backend** | 8080, 8081 | Node.js API |
| **Frontend** | 5173 (dev), 80 (prod) | React App |
| **Nginx** | 80, 443 | Reverse Proxy (prod only) |

---

## 🛠️ Common Commands

### Container Management
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart a service
docker-compose restart backend

# View running containers
docker-compose ps

# View logs
docker-compose logs -f backend
docker-compose logs -f mysql
docker-compose logs --tail=100 backend
```

### Database Operations
```bash
# Access MySQL shell
docker-compose exec mysql mysql -u arqdoor -p arqdoor_dev

# Backup database
docker-compose exec mysql mysqldump -u root -p arqdoor_dev > backup_$(date +%Y%m%d).sql

# Restore database
docker-compose exec -T mysql mysql -u root -p arqdoor_dev < backup.sql

# View databases
docker-compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### Backend Commands
```bash
# Run tests
docker-compose exec backend npm test

# Install new package
docker-compose exec backend npm install package-name

# Access backend shell
docker-compose exec backend sh

# View environment variables
docker-compose exec backend env
```

### Rebuild & Clean
```bash
# Rebuild specific service
docker-compose up -d --build backend

# Rebuild without cache
docker-compose build --no-cache backend

# Remove all containers and volumes
docker-compose down -v

# Clean everything (CAUTION: deletes data!)
docker-compose down -v --rmi all
```

---

## 📁 Volume Management

### List Volumes
```bash
docker volume ls
```

### Inspect Volume
```bash
docker volume inspect arqdoorapp_mysql_data
docker volume inspect arqdoorapp_uploads_data
```

### Backup Volumes
```bash
# Backup uploads
docker run --rm -v arqdoorapp_uploads_data:/data -v $(pwd):/backup alpine tar czf /backup/uploads_backup.tar.gz /data

# Restore uploads
docker run --rm -v arqdoorapp_uploads_data:/data -v $(pwd):/backup alpine tar xzf /backup/uploads_backup.tar.gz -C /
```

---

## 🔍 Debugging

### Check Service Health
```bash
docker-compose ps
# Look for "Up (healthy)" status
```

### View Detailed Logs
```bash
# All services
docker-compose logs

# Specific service with timestamps
docker-compose logs -f --timestamps backend

# Last 100 lines
docker-compose logs --tail=100 mysql
```

### Inspect Container
```bash
docker inspect arqdoor-backend-dev
```

### Network Debugging
```bash
# List networks
docker network ls

# Inspect network
docker network inspect arqdoorapp_arqdoor-network

# Test connectivity
docker-compose exec backend ping mysql
docker-compose exec backend wget -O- http://mysql:3306
```

---

## 🚀 Production Deployment

### Pre-deployment Checklist
- [ ] Update `.env.docker` with production values
- [ ] Set `NODE_ENV=production`
- [ ] Set strong `SECRET` and `DB_PASSWORD`
- [ ] Configure `CORS_ORIGINS` with production domains
- [ ] Set `ENABLE_DB_SYNC=false`
- [ ] Review resource limits in `docker-compose.prod.yml`

### Deploy Steps
```bash
# 1. Pull latest code
git pull origin main

# 2. Build images
docker-compose -f docker-compose.prod.yml build

# 3. Stop old containers
docker-compose -f docker-compose.prod.yml down

# 4. Start new containers
docker-compose -f docker-compose.prod.yml up -d

# 5. Verify health
docker-compose -f docker-compose.prod.yml ps
```

### Zero-Downtime Deployment
```bash
# 1. Build new images
docker-compose -f docker-compose.prod.yml build backend

# 2. Scale up
docker-compose -f docker-compose.prod.yml up -d --scale backend=4 --no-recreate

# 3. Wait for health checks
sleep 30

# 4. Scale down old instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=2
```

---

## 🔐 SSL Configuration

### Using Let's Encrypt (Certbot)
```bash
# 1. Install certbot
sudo apt-get install certbot

# 2. Generate certificates
sudo certbot certonly --standalone -d arqdoor.com -d www.arqdoor.com

# 3. Copy certificates
sudo cp /etc/letsencrypt/live/arqdoor.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/arqdoor.com/privkey.pem nginx/ssl/

# 4. Uncomment SSL configuration in nginx/nginx.conf

# 5. Restart nginx
docker-compose -f docker-compose.prod.yml restart nginx
```

---

## 📊 Monitoring

### Resource Usage
```bash
# Real-time stats
docker stats

# Specific container
docker stats arqdoor-backend-prod
```

### Health Checks
```bash
# Backend
curl http://localhost:8080/doc

# Frontend
curl http://localhost:5173

# Nginx
curl http://localhost/health
```

---

## 🐛 Troubleshooting

### Problem: Port already in use
```bash
# Find process using port
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8081:8080"
```

### Problem: Container keeps restarting
```bash
# Check logs
docker-compose logs backend

# Check health
docker-compose ps

# Inspect container
docker inspect arqdoor-backend-dev
```

### Problem: Database connection failed
```bash
# Verify MySQL is healthy
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection
docker-compose exec backend ping mysql

# Verify environment variables
docker-compose exec backend env | grep DB_
```

### Problem: Hot reload not working
```bash
# Ensure volumes are mounted correctly
docker-compose config

# Restart with rebuild
docker-compose up -d --build backend
```

### Problem: Out of disk space
```bash
# Clean unused images
docker image prune -a

# Clean unused volumes
docker volume prune

# Clean everything
docker system prune -a --volumes
```

---

## 📝 Environment Variables

See `.env.docker.example` for all available variables.

**Required**:
- `DB_ROOT_PASSWORD`
- `DB_PASSWORD`
- `SECRET`
- `ASAAS_API_KEY`

**Optional**:
- `CORS_ORIGINS`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

---

## 🔄 Backup & Restore

### Full Backup Script
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T mysql mysqldump -u root -p$DB_ROOT_PASSWORD arqdoor_dev > $BACKUP_DIR/database.sql

# Backup uploads
docker run --rm -v arqdoorapp_uploads_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/uploads.tar.gz /data

echo "Backup completed: $BACKUP_DIR"
```

### Restore Script
```bash
#!/bin/bash
BACKUP_DIR=$1

# Restore database
docker-compose exec -T mysql mysql -u root -p$DB_ROOT_PASSWORD arqdoor_dev < $BACKUP_DIR/database.sql

# Restore uploads
docker run --rm -v arqdoorapp_uploads_data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/uploads.tar.gz -C /

echo "Restore completed from: $BACKUP_DIR"
```

---

## 🎯 Best Practices

1. **Always use `.env.docker` for sensitive data**
2. **Never commit `.env.docker` to git**
3. **Use named volumes for persistence**
4. **Set resource limits in production**
5. **Enable health checks for all services**
6. **Use multi-stage builds to reduce image size**
7. **Run containers as non-root user**
8. **Regularly backup database and uploads**
9. **Monitor container logs and metrics**
10. **Test in development before deploying to production**

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MySQL Docker Image](https://hub.docker.com/_/mysql)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
- [Nginx Docker Image](https://hub.docker.com/_/nginx)

---

## 🆘 Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Verify health: `docker-compose ps`
3. Review this documentation
4. Check GitHub issues
5. Contact the development team
