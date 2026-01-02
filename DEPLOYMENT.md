# FAQ MCP Server - Production Deployment Guide

Complete guide for deploying the FAQ MCP Server to production.

## Prerequisites

- Docker and Docker Compose installed (for Docker deployment)
- Python 3.12+ (for non-Docker deployment)
- MongoDB Atlas account with connection string
- API key for embedding provider (OpenAI, Anthropic, or use local)
- Linux server with systemd (for systemd deployment)

## Quick Start

### 1. Clone and Setup

```bash
cd /home/ubuntu/Kshitij/Bootcamp-mcp
```

### 2. Configure Environment

Copy the example environment file and edit with your credentials:

```bash
cp mcp-server/.env.example .env
nano .env
```

**Required variables:**
```bash
# MongoDB
MONGODB_URI=mongodb+srv://your_connection_string

# Embedding Provider (choose one)
EMBEDDING_PROVIDER=openai  # or anthropic, or local
OPENAI_API_KEY=your_openai_api_key_here

# Environment
ENVIRONMENT=production
LOG_LEVEL=INFO
```

### 3. Generate Embeddings

Before deploying, generate embeddings for all FAQs:

```bash
# Install dependencies
./venv/bin/pip install -r mcp-server/requirements.txt

# Generate embeddings
./venv/bin/python scripts/generate_embeddings.py
```

This will:
- Load all 54 FAQs from MongoDB
- Generate embeddings using your chosen provider
- Store embeddings back in MongoDB
- Take ~1-2 minutes depending on provider

## Deployment Options

### Option 1: Docker Deployment (Recommended)

#### Build and Run

```bash
# Build the Docker image
docker build -t faq-mcp-server .

# Run with Docker Compose
docker-compose up -d
```

#### Verify Deployment

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f faq-mcp-server

# Check health
docker-compose exec faq-mcp-server python -c "print('Server is healthy')"
```

#### Stop/Restart

```bash
# Stop
docker-compose down

# Restart
docker-compose restart

# Update and redeploy
docker-compose down
docker build -t faq-mcp-server .
docker-compose up -d
```

---

### Option 2: Systemd Service (Linux)

#### Install Service

```bash
# Copy service file
sudo cp faq-mcp.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable faq-mcp

# Start service
sudo systemctl start faq-mcp
```

#### Manage Service

```bash
# Check status
sudo systemctl status faq-mcp

# View logs
sudo journalctl -u faq-mcp -f

# Restart
sudo systemctl restart faq-mcp

# Stop
sudo systemctl stop faq-mcp
```

---

### Option 3: Manual Deployment

```bash
# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r mcp-server/requirements.txt

# Run server
python mcp-server/faq_server.py
```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MONGODB_URI` | Yes | - | MongoDB connection string |
| `MONGODB_DATABASE` | No | `faq_bootcamp` | Database name |
| `MONGODB_COLLECTION` | No | `questions` | Collection name |
| `EMBEDDING_PROVIDER` | No | `openai` | Provider: openai, anthropic, local |
| `OPENAI_API_KEY` | Conditional | - | Required if using OpenAI |
| `ANTHROPIC_API_KEY` | Conditional | - | Required if using Anthropic |
| `EMBEDDING_MODEL` | No | `text-embedding-3-small` | Embedding model |
| `TFIDF_WEIGHT` | No | `0.3` | TF-IDF weight in hybrid search |
| `EMBEDDING_WEIGHT` | No | `0.7` | Embedding weight in hybrid search |
| `ENVIRONMENT` | No | `development` | Environment: development, staging, production |
| `LOG_LEVEL` | No | `INFO` | Logging level: DEBUG, INFO, WARNING, ERROR |

### Search Weight Tuning

Adjust the balance between keyword matching (TF-IDF) and semantic understanding (embeddings):

```bash
# More keyword matching (better for exact terms)
TFIDF_WEIGHT=0.5
EMBEDDING_WEIGHT=0.5

# More semantic understanding (better for paraphrased questions)
TFIDF_WEIGHT=0.2
EMBEDDING_WEIGHT=0.8
```

## Monitoring

### Logs

**Docker:**
```bash
# Real-time logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Logs for specific time
docker-compose logs --since 1h
```

**Systemd:**
```bash
# Real-time logs
sudo journalctl -u faq-mcp -f

# Last 100 lines
sudo journalctl -u faq-mcp -n 100

# Logs for specific time
sudo journalctl -u faq-mcp --since "1 hour ago"
```

**File logs (production):**
```bash
# View logs
tail -f logs/faq_mcp.log

# Search logs
grep "ERROR" logs/faq_mcp.log
```

### Health Checks

```bash
# Docker
docker-compose exec faq-mcp-server python -c "import sys; sys.exit(0)"

# Direct
python -c "from mcp-server.config import get_settings; print(get_settings())"
```

## Troubleshooting

### Common Issues

#### 1. MongoDB Connection Failed

**Error:** `ConnectionFailure: could not connect to MongoDB`

**Solutions:**
- Verify `MONGODB_URI` is correct
- Check IP whitelist in MongoDB Atlas
- Test connection: `mongosh "your_connection_string"`

#### 2. Missing API Key

**Error:** `OPENAI_API_KEY is required when using OpenAI embeddings`

**Solutions:**
- Set API key in `.env` file
- Or switch to local embeddings: `EMBEDDING_PROVIDER=local`

#### 3. No Embeddings Found

**Warning:** `No embeddings found - using TF-IDF only`

**Solutions:**
- Run embedding generation: `python scripts/generate_embeddings.py`
- Or continue with TF-IDF only (still works, just less accurate)

#### 4. Docker Build Fails

**Error:** Various build errors

**Solutions:**
```bash
# Clean build
docker-compose down
docker system prune -a
docker build --no-cache -t faq-mcp-server .
```

#### 5. Permission Denied (Systemd)

**Error:** `Permission denied` when accessing files

**Solutions:**
```bash
# Fix ownership
sudo chown -R ubuntu:ubuntu /home/ubuntu/Kshitij/Bootcamp-mcp

# Fix permissions
chmod +x quick_start.sh
```

## Security Best Practices

### 1. Protect API Keys

```bash
# Never commit .env file
echo ".env" >> .gitignore

# Use environment-specific files
.env.development
.env.staging
.env.production
```

### 2. Use Non-Root User

Docker already uses non-root user (`faquser`). For manual deployment:

```bash
# Create service user
sudo useradd -r -s /bin/false faquser

# Update systemd service
User=faquser
```

### 3. Enable Firewall

```bash
# Allow only necessary ports
sudo ufw allow 22/tcp  # SSH
sudo ufw enable
```

### 4. Regular Updates

```bash
# Update dependencies
pip install --upgrade -r mcp-server/requirements.txt

# Rebuild Docker image
docker build -t faq-mcp-server .
```

## Performance Optimization

### 1. Resource Limits

Docker Compose already sets limits:
- CPU: 1.0 core max, 0.5 core reserved
- Memory: 1GB max, 512MB reserved

Adjust in `docker-compose.yml` if needed.

### 2. Caching

The server caches:
- All FAQs in memory
- TF-IDF matrix
- Embedding function

No additional caching needed.

### 3. Batch Processing

For embedding generation:
```bash
# Process in batches to avoid rate limits
# Already implemented in generate_embeddings.py
```

## Backup and Recovery

### Backup MongoDB Data

```bash
# Export FAQ data
mongoexport --uri="$MONGODB_URI" \
  --db=faq_bootcamp \
  --collection=questions \
  --out=backup_faqs.json

# With embeddings
mongoexport --uri="$MONGODB_URI" \
  --db=faq_bootcamp \
  --collection=questions \
  --jsonArray \
  --out=backup_faqs_with_embeddings.json
```

### Restore MongoDB Data

```bash
# Import FAQ data
mongoimport --uri="$MONGODB_URI" \
  --db=faq_bootcamp \
  --collection=questions \
  --file=backup_faqs.json \
  --jsonArray
```

## Scaling

### Horizontal Scaling

For multiple instances:

1. Use external MongoDB (already configured)
2. Deploy multiple containers with load balancer
3. Share `.env` configuration across instances

### Vertical Scaling

Increase resources in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
```

## Maintenance

### Regular Tasks

**Weekly:**
- Check logs for errors
- Monitor resource usage
- Review search metrics

**Monthly:**
- Update dependencies
- Regenerate embeddings if FAQs changed
- Review and optimize search weights

**Quarterly:**
- Security audit
- Performance benchmarking
- Backup verification

### Updating FAQs

When FAQ content changes:

```bash
# 1. Update FAQ file
nano "FAQ Data/Unified_FAQ.txt"

# 2. Re-parse
python scripts/parse_faq.py

# 3. Re-ingest
python scripts/ingest_to_mongodb.py

# 4. Regenerate embeddings
python scripts/generate_embeddings.py

# 5. Restart server
docker-compose restart  # or sudo systemctl restart faq-mcp
```

## Support

For issues or questions:
- **Email**: internship-support@vicharanashala.zohodesk.in
- **DLED Team**: dled@iitrpr.ac.in

**Organization**: VLED, Indian Institute of Technology, Ropar
