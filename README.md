# FAQ MCP Server

An intelligent FAQ search system using MCP (Model Context Protocol) with hybrid search combining TF-IDF and semantic embeddings.

## Features

- 🔍 **Hybrid Search**: Combines keyword matching (TF-IDF) with semantic understanding (embeddings)
- 🤖 **Multi-Provider Support**: OpenAI, Anthropic (Voyage AI), or local embeddings
- 📊 **54 FAQ Entries**: Covers bootcamp registration, ViBe platform, attendance, certification, and more
- ⚡ **Fast & Efficient**: In-memory caching with pre-built indices
- 🐳 **Production Ready**: Docker, systemd, structured logging, health checks
- 🔌 **MCP Compatible**: Works with Claude Desktop and other MCP clients

---

## Quick Start

### 1. Setup

```bash
# Clone repository
git clone <repository-url>
cd Bootcamp-mcp

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r mcp-server/requirements.txt
```

### 2. Configure

```bash
# Copy environment template
cp mcp-server/.env.example .env

# Edit with your settings
nano .env
```

**Minimum configuration:**
```bash
MONGODB_URI=your_mongodb_connection_string
EMBEDDING_PROVIDER=openai  # or: anthropic, local
OPENAI_API_KEY=your_api_key  # if using OpenAI
```

### 3. Ingest Data

```bash
# Parse FAQ file
python scripts/parse_faq.py

# Ingest to MongoDB
python scripts/ingest_to_mongodb.py

# Generate embeddings (recommended)
python scripts/generate_embeddings.py
```

### 4. Run

**Option A: Direct**
```bash
python mcp-server/faq_server.py
```

**Option B: Docker**
```bash
docker-compose up -d
```

**Option C: Systemd (Linux)**
```bash
sudo cp faq-mcp.service /etc/systemd/system/
sudo systemctl enable --now faq-mcp
```

---

## Usage with Claude Desktop

Add to your Claude Desktop config:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "faq-search": {
      "command": "/path/to/venv/bin/python",
      "args": ["/path/to/Bootcamp-mcp/mcp-server/faq_server.py"],
      "env": {
        "MONGODB_URI": "your_mongodb_uri",
        "OPENAI_API_KEY": "your_api_key"
      }
    }
  }
}
```

Restart Claude Desktop and ask questions like:
- "How do I register for the bootcamp?"
- "Can I use mobile for ViBe?"
- "What are the attendance requirements?"

---

## How It Works

### Hybrid Search Algorithm

Combines two complementary search methods:

1. **TF-IDF (30%)**: Keyword-based matching for exact terms
2. **Embeddings (70%)**: Semantic understanding for paraphrased questions

```
Final Score = (0.3 × TF-IDF Score) + (0.7 × Embedding Score)
```

**Example:**

Query: "What's the sign-up process?"

- TF-IDF Score: 25% (different words than "How do I register?")
- Embedding Score: 92% (same semantic meaning)
- **Final Score: 72%** ✅ High match!

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MONGODB_URI` | Yes | - | MongoDB connection string |
| `EMBEDDING_PROVIDER` | No | `openai` | Provider: openai, anthropic, local |
| `OPENAI_API_KEY` | Conditional | - | Required if using OpenAI |
| `ANTHROPIC_API_KEY` | Conditional | - | Required if using Anthropic |
| `TFIDF_WEIGHT` | No | `0.3` | TF-IDF weight (0.0-1.0) |
| `EMBEDDING_WEIGHT` | No | `0.7` | Embedding weight (0.0-1.0) |
| `ENVIRONMENT` | No | `development` | Environment mode |
| `LOG_LEVEL` | No | `INFO` | Logging verbosity |

### Embedding Providers

**OpenAI** (Recommended):
- Best quality, fast
- $0.02 per 1M tokens
- Requires API key

**Anthropic/Voyage AI**:
- Similar quality and pricing
- Requires API key

**Local** (sentence-transformers):
- Free, runs offline
- No API key needed
- Good quality

---

## Deployment

### Docker Deployment

```bash
# Build
docker build -t faq-mcp-server .

# Run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Systemd Service (Linux)

```bash
# Install
sudo cp faq-mcp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable faq-mcp
sudo systemctl start faq-mcp

# Check status
sudo systemctl status faq-mcp

# View logs
sudo journalctl -u faq-mcp -f
```

### Environment Setup

**Development:**
```bash
ENVIRONMENT=development
EMBEDDING_PROVIDER=local  # Free, no API key
LOG_LEVEL=DEBUG
```

**Production:**
```bash
ENVIRONMENT=production
EMBEDDING_PROVIDER=openai
OPENAI_API_KEY=sk-...
LOG_LEVEL=INFO
```

---

## Project Structure

```
Bootcamp-mcp/
├── FAQ Data/
│   ├── Unified_FAQ.txt              # Source FAQ (54 entries)
│   ├── Frequently Asked Questions.txt
│   └── NPTEL Internship -FAQ .txt
│
├── scripts/
│   ├── parse_faq.py                 # Parse FAQ to JSON
│   ├── ingest_to_mongodb.py         # Ingest to MongoDB
│   └── generate_embeddings.py       # Generate embeddings
│
├── mcp-server/
│   ├── faq_server.py                # Main MCP server
│   ├── config.py                    # Configuration
│   ├── logger.py                    # Logging
│   ├── test_search.py               # Tests
│   ├── requirements.txt             # Dependencies
│   └── .env.example                 # Config template
│
├── Dockerfile                        # Docker build
├── docker-compose.yml                # Docker Compose
├── faq-mcp.service                   # Systemd service
└── README.md                         # This file
```

---

## Testing

```bash
# Test search functionality
python mcp-server/test_search.py

# Test with specific provider
EMBEDDING_PROVIDER=local python mcp-server/test_search.py
```

---

## Updating FAQs

```bash
# 1. Edit FAQ file
nano "FAQ Data/Unified_FAQ.txt"

# 2. Re-parse and ingest
python scripts/parse_faq.py
python scripts/ingest_to_mongodb.py

# 3. Regenerate embeddings
python scripts/generate_embeddings.py

# 4. Restart server
docker-compose restart  # or: sudo systemctl restart faq-mcp
```

---

## Troubleshooting

### MongoDB Connection Failed
- Verify `MONGODB_URI` is correct
- Check IP whitelist in MongoDB Atlas
- Test: `mongosh "your_connection_string"`

### Missing API Key
- Set `OPENAI_API_KEY` in `.env`
- Or use local: `EMBEDDING_PROVIDER=local`

### No Embeddings Found
- Run: `python scripts/generate_embeddings.py`
- Or continue with TF-IDF only (still works)

### Docker Build Fails
```bash
docker-compose down
docker system prune -a
docker build --no-cache -t faq-mcp-server .
```

---

## FAQ Categories

54 FAQs across 12 categories:

1. Program Overview (3)
2. Eligibility & Registration (5)
3. Dates, Duration & Schedule (4)
4. Mode of Delivery & Attendance (20)
5. Course Content & Learning (2)
6. Projects & Assignments (2)
7. Mentorship & Guidance (2)
8. Support & Issue Resolution (6)
9. Completion Criteria & Certification (3)
10. Stipend & Recommendation Letters (3)
11. Termination & Rejoining Policy (3)
12. GitHub Assignment Submission (1)

---

## GitHub Setup

### Create Repository

1. Go to https://github.com/new
2. Name: `faq-mcp-server`
3. **Don't** initialize with README
4. Create repository

### Push to GitHub

```bash
# Configure git (if needed)
git config user.name "Your Name"
git config user.email "your@email.com"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

---

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/name`
3. Make changes
4. Test: `python mcp-server/test_search.py`
5. Commit: `git commit -m "Add feature"`
6. Push: `git push origin feature/name`
7. Create Pull Request

---

## License

MIT License - See LICENSE file

Created for VLED, Indian Institute of Technology, Ropar

---

## Support

- **Email**: internship-support@vicharanashala.zohodesk.in
- **DLED Team**: dled@iitrpr.ac.in

---

## Tech Stack

- **MCP**: Model Context Protocol
- **Database**: MongoDB Atlas
- **Embeddings**: OpenAI / Anthropic / sentence-transformers
- **Search**: TF-IDF + Cosine Similarity
- **Deployment**: Docker, systemd
- **Language**: Python 3.12+
