# Installation Guide

This guide provides detailed installation instructions for production and development environments.

## Prerequisites

Before installing, ensure you meet all [requirements](../requirements.md):

- System requirements (CPU, memory, storage)
- Required software dependencies
- Network configuration
- Security requirements

## Installation Methods

Choose the installation method that best fits your needs:

=== "Docker Compose"
    **Best for:** Development, small deployments, testing
    
    Simple deployment using Docker Compose with minimal configuration.

=== "Kubernetes"
    **Best for:** Production, scalable deployments, enterprise
    
    Production-ready deployment with high availability and scaling.

=== "Manual Installation"
    **Best for:** Custom environments, specific requirements
    
    Direct installation on the host system without containers.

## Docker Compose Installation

### 1. Download and Configure

```bash
# Clone the repository
git clone https://github.com/your-org/your-project.git
cd your-project

# Copy environment template
cp .env.example .env
```

### 2. Configure Environment

Edit the `.env` file with your settings:

```bash
# Application settings
APP_NAME=your-project
APP_ENV=production
APP_DEBUG=false

# Database configuration
DB_HOST=db
DB_PORT=5432
DB_NAME=your_project
DB_USER=app_user
DB_PASSWORD=secure_password

# Redis configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=redis_password

# Security settings
JWT_SECRET=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key
```

### 3. SSL Configuration (Production)

For HTTPS, place your certificates in the `ssl/` directory:

```bash
mkdir ssl
# Copy your certificates
cp /path/to/your/cert.pem ssl/
cp /path/to/your/key.pem ssl/
```

Update `docker-compose.prod.yml` with your certificate paths.

### 4. Deploy

```bash
# For development
docker-compose up -d

# For production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Kubernetes Installation

### 1. Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- Helm 3.x installed
- Ingress controller (nginx, traefik)

### 2. Add Helm Repository

```bash
helm repo add your-project https://charts.your-org.com/
helm repo update
```

### 3. Create Namespace

```bash
kubectl create namespace your-project
```

### 4. Configure Values

Create `values.yaml`:

```yaml
# Application configuration
app:
  image:
    repository: your-org/your-project
    tag: "1.0.0"
  replicas: 3
  
# Database configuration
database:
  enabled: true
  type: postgresql
  host: ""
  port: 5432
  name: your_project
  
# Ingress configuration
ingress:
  enabled: true
  className: nginx
  host: your-project.example.com
  tls:
    enabled: true
    secretName: your-project-tls
    
# Monitoring
monitoring:
  enabled: true
  prometheus:
    enabled: true
  grafana:
    enabled: true
```

### 5. Install

```bash
helm install your-project your-project/your-project \
  --namespace your-project \
  --values values.yaml
```

## Manual Installation

### 1. System Dependencies

Install required packages:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip postgresql redis-server nginx

# CentOS/RHEL
sudo yum install -y python3 python3-pip postgresql-server redis nginx
```

### 2. Application Setup

```bash
# Create application user
sudo useradd -m -s /bin/bash your-project

# Clone and setup application
sudo -u your-project git clone https://github.com/your-org/your-project.git /opt/your-project
cd /opt/your-project

# Install dependencies
sudo -u your-project pip3 install -r requirements.txt
```

### 3. Database Setup

```bash
# Initialize PostgreSQL
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE your_project;
CREATE USER your_project_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE your_project TO your_project_user;
\q
EOF
```

### 4. Configuration

Create configuration file:

```bash
sudo -u your-project cat > /opt/your-project/config.yaml << EOF
database:
  host: localhost
  port: 5432
  name: your_project
  user: your_project_user
  password: secure_password

redis:
  host: localhost
  port: 6379

security:
  jwt_secret: your-jwt-secret
  encryption_key: your-encryption-key
EOF
```

### 5. Systemd Service

Create service file:

```bash
sudo cat > /etc/systemd/system/your-project.service << EOF
[Unit]
Description=Your Project Application
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=your-project
WorkingDirectory=/opt/your-project
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable your-project
sudo systemctl start your-project
```

## Post-Installation

### 1. Verify Installation

```bash
# Check service status
curl http://localhost:8080/health

# Check database connection
curl http://localhost:8080/api/status
```

### 2. Initial Configuration

```bash
# Create admin user
curl -X POST http://localhost:8080/api/admin/init \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "secure_password", "email": "admin@example.com"}'
```

### 3. Setup Monitoring

Configure monitoring tools:

```bash
# Import Grafana dashboards
curl -X POST http://localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @monitoring/grafana-dashboard.json
```

## Security Hardening

### 1. Firewall Configuration

```bash
# Allow only necessary ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. SSL/TLS Setup

```bash
# Generate SSL certificate (Let's Encrypt)
sudo certbot --nginx -d your-project.example.com
```

### 3. Database Security

```bash
# Secure PostgreSQL
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'strong_password';"
```

## Backup Configuration

### 1. Database Backup

```bash
# Create backup script
cat > /opt/backup-db.sh << EOF
#!/bin/bash
pg_dump -h localhost -U your_project_user your_project | gzip > /backup/db-$(date +%Y%m%d).sql.gz
find /backup -name "db-*.sql.gz" -mtime +30 -delete
EOF

chmod +x /opt/backup-db.sh

# Add to crontab
echo "0 2 * * * /opt/backup-db.sh" | sudo crontab -
```

### 2. Application Backup

```bash
# Backup configuration and data
tar -czf /backup/app-$(date +%Y%m%d).tar.gz /opt/your-project/config /opt/your-project/data
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports are already in use
2. **Database connection**: Verify credentials and network access
3. **Permission errors**: Check file and directory permissions
4. **Memory issues**: Monitor resource usage

### Log Locations

- Application logs: `/var/log/your-project/`
- System logs: `journalctl -u your-project`
- Database logs: `/var/log/postgresql/`

### Support

If you encounter issues:

- Check the [Troubleshooting Guide](../troubleshooting/common-issues.md)
- Review logs for error messages
- Verify all prerequisites are met
- Contact support with detailed error information

!!! tip "Production Ready"
    After installation, review the [Configuration Guide](../configuration/basic-config.md) for optimization and tuning.
