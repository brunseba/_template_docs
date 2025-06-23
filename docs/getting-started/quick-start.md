# Quick Start Guide

Get the system up and running in just a few minutes with this quick start guide.

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/your-project.git
cd your-project
```

## Step 2: Start the Services

```bash
docker-compose up -d
```

This will start all required services:
- Main application
- Database
- Cache layer
- Monitoring stack

## Step 3: Verify Installation

Wait for all services to start (usually 1-2 minutes), then test:

```bash
# Check service health
curl http://localhost:8080/health

# Expected response
{
  "status": "healthy",
  "version": "1.0.0",
  "services": {
    "database": "connected",
    "cache": "connected"
  }
}
```

## Step 4: Access the Application

Open your browser and navigate to:

- **Application**: http://localhost:8080
- **Monitoring Dashboard**: http://localhost:3000 (admin/admin)
- **API Documentation**: http://localhost:8080/docs

## What's Running?

After the quick start, you'll have:

| Service | Port | Purpose |
|---------|------|---------|
| Main App | 8080 | Core application |
| Database | 5432 | PostgreSQL database |
| Cache | 6379 | Redis cache |
| Monitoring | 3000 | Grafana dashboard |

## Next Steps

!!! success "You're Ready!"
    Your system is now running! Here's what to do next:

1. **Explore the UI** - Browse the web interface
2. **Try the API** - Make some API calls
3. **Check Monitoring** - View the Grafana dashboard
4. **Read the User Guide** - Learn about features

## Stopping the Services

When you're done:

```bash
docker-compose down
```

To remove all data:

```bash
docker-compose down -v
```

## Troubleshooting

### Port Already in Use

If you get port conflicts:

```bash
# Check what's using the port
lsof -i :8080

# Stop the conflicting service or change ports in docker-compose.yml
```

### Services Won't Start

Check the logs:

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs app
```

### Database Connection Issues

Wait longer for services to initialize:

```bash
# Check service status
docker-compose ps

# Restart if needed
docker-compose restart
```

## Common Commands

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Update images
docker-compose pull && docker-compose up -d
```

!!! tip "Need More Control?"
    For production deployments or custom configurations, check out the [Installation Guide](installation.md).
