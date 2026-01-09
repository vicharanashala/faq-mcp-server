# FAQ MCP Server

[![Docker Hub Publish](https://github.com/kshitijpandey3h/faq-mcp-server/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/kshitijpandey3h/faq-mcp-server/actions/workflows/docker-publish.yml)
[![Docker Hub](https://img.shields.io/docker/v/kshitijpandey3h/faq-mcp-server?label=Docker%20Hub)](https://hub.docker.com/r/kshitijpandey3h/faq-mcp-server)

Intelligent FAQ search system using FastMCP framework with hybrid TF-IDF and semantic embeddings.

## Features

- 🔍 **Hybrid Search**: TF-IDF + semantic embeddings
- 🤖 **BGE Embeddings**: BAAI/bge-large-en-v1.5 (1024 dimensions)
- 📊 **54 FAQs**: Bootcamp, ViBe platform, attendance, certification
- ⚡ **FastMCP**: Clean architecture with HTTP API
- 🐳 **Dockerized**: Easy deployment with Docker Compose
- 🔌 **Port 9010**: FAQ Search Server
- 🛠️ **Port 9011**: Admin Server (File management & uploads)

## Project Structure

```
faq-mcp-server/
├── src/
│   ├── faq.py                   # FAQ Search MCP Server
│   └── admin_server.py          # Admin MCP Server (Add/Download Data)
├── scripts/
│   ├── regenerate_embeddings.py # Embedding generation script
│   ├── add_new_faq.py           # Manual FAQ addition tool
│   └── deploy.sh                # Deployment utility
├── FAQ_Data/                    # Source data
├── Dockerfile                   # FAQ Server Image
├── Dockerfile.admin             # Admin Server Image
├── docker-compose.yml           # FAQ Server Compose
├── docker-compose-admin.yml     # Admin Server Compose
└── README.md                    # Documentation
```

## Quick Start

### Using Docker (Recommended)

```bash
# Start the servers
docker compose up -d

# View logs
docker logs faq-mcp-server -f
```

### Manual Setup

```bash
# Install dependencies
pip install -r requirements.txt sentence-transformers

# Configure environment
cp .env.example .env
# Edit .env with your MongoDB URI

# Run the FAQ server
python src/faq.py

# Run the Admin server
python src/admin_server.py
```

## Usage

### MCP Tools

1. **`search_faq`** (Port 9010):
   - Search specifically for relevant FAQs.
   - Example: "How do I register?"

2. **`add_faq`** (Port 9011):
   - Add new QA pairs to the database.

3. **`download_data`** (Port 9011):
   - Download all FAQ data as a CSV file.

4. **`last_n`** (Port 9011):
   - Download the last N added FAQs.

### LibreChat Configuration

Add the following to your `librechat.yaml`:

```yaml
mcpServers:
  faq-server:
    type: streamable-http
    url: http://host.docker.internal:9010/mcp
  admin-server:
    type: streamable-http
    url: http://host.docker.internal:9011/mcp
    headers:
      X-User-Name: "{{LIBRECHAT_USER_NAME}}"
      X-User-Email: "{{LIBRECHAT_USER_EMAIL}}"
      X-User-Id: "{{LIBRECHAT_USER_ID}}"
```

## Deployment

### Docker Hub

Images are automatically built and pushed to Docker Hub via GitHub Actions.

- **Repository**: `kshitijpandey3h/faq-mcp-server`
- **Tags**: `latest`, `v*.*.*`, `main-<sha>`

### GitHub Actions Setup

To enable automated deployment:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**.
2. Add the following secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username.
   - `DOCKERHUB_TOKEN`: Docker Hub Access Token (Read & Write).

### Triggering a Release

Push a tag to trigger a build and release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Tech Stack

- **Framework**: FastMCP 2.14.2
- **Database**: MongoDB
- **Embeddings**: BAAI/bge-large-en-v1.5
- **Search**: Hybrid TF-IDF + Semantic
- **Language**: Python 3.12+
