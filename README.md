# FAQ MCP Server

An intelligent FAQ search system using MCP (Model Context Protocol) with hybrid search combining TF-IDF and semantic embeddings.

## Features

- 🔍 **Hybrid Search**: Combines keyword matching (TF-IDF) with semantic understanding (embeddings)
- 🤖 **Multi-Provider Support**: OpenAI, Anthropic (Voyage AI), or local embeddings
- 📊 **54 FAQ Entries**: Covers bootcamp registration, ViBe platform, attendance, certification, and more
- ⚡ **Fast & Efficient**: In-memory caching with pre-built indices
- 🐳 **Production Ready**: Docker, systemd, structured logging, health checks
- 🔌 **MCP Compatible**: Works with Claude Desktop and other MCP clients

## Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd Bootcamp-mcp
```

### 2. Setup Environment

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r mcp-server/requirements.txt
```

### 3. Configure

```bash
# Copy environment template
cp mcp-server/.env.example .env

# Edit with your settings
nano .env
```

**Required settings:**
```bash
MONGODB_URI=your_mongodb_connection_string
EMBEDDING_PROVIDER=openai  # or anthropic, or local
OPENAI_API_KEY=your_api_key  # if using OpenAI
```

### 4. Ingest Data

```bash
# Parse FAQ file
python scripts/parse_faq.py

# Ingest to MongoDB
python scripts/ingest_to_mongodb.py

# Generate embeddings (optional but recommended)
python scripts/generate_embeddings.py
```

### 5. Run Server

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

## Usage

### With Claude Desktop

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

### Standalone Testing

```bash
python mcp-server/test_search.py
```

## Project Structure

```
Bootcamp-mcp/
├── FAQ Data/
│   ├── Unified_FAQ.txt              # Source FAQ file (54 entries)
│   ├── Frequently Asked Questions.txt
│   └── NPTEL Internship -FAQ .txt
│
├── scripts/
│   ├── parse_faq.py                 # Parse FAQ file to JSON
│   ├── ingest_to_mongodb.py         # Ingest to MongoDB
│   └── generate_embeddings.py       # Generate semantic embeddings
│
├── mcp-server/
│   ├── faq_server.py                # Main MCP server
│   ├── config.py                    # Configuration management
│   ├── logger.py                    # Structured logging
│   ├── test_search.py               # Test script
│   ├── requirements.txt             # Python dependencies
│   └── .env.example                 # Environment template
│
├── Dockerfile                        # Docker build
├── docker-compose.yml                # Docker Compose config
├── faq-mcp.service                   # Systemd service
├── DEPLOYMENT.md                     # Deployment guide
└── README.md                         # This file
```

## How It Works

### Hybrid Search Algorithm

The server combines two search methods:

1. **TF-IDF (30%)**: Keyword-based matching for exact terms
2. **Embeddings (70%)**: Semantic understanding for paraphrased questions

```
Final Score = (0.3 × TF-IDF Score) + (0.7 × Embedding Score)
```

This allows matching both exact questions and paraphrased variations.

### Example

**Query**: "What's the sign-up process?"

**TF-IDF Score**: 25% (different words than "How do I register?")  
**Embedding Score**: 92% (same semantic meaning)  
**Final Score**: 72% ✅ High match!

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MONGODB_URI` | Yes | - | MongoDB connection string |
| `EMBEDDING_PROVIDER` | No | `openai` | Provider: openai, anthropic, local |
| `OPENAI_API_KEY` | Conditional | - | Required if using OpenAI |
| `ANTHROPIC_API_KEY` | Conditional | - | Required if using Anthropic |
| `TFIDF_WEIGHT` | No | `0.3` | TF-IDF weight in hybrid search |
| `EMBEDDING_WEIGHT` | No | `0.7` | Embedding weight in hybrid search |
| `ENVIRONMENT` | No | `development` | Environment: development, staging, production |
| `LOG_LEVEL` | No | `INFO` | Logging level |

### Embedding Providers

**OpenAI** (Recommended):
- Best quality
- Fast
- $0.02 per 1M tokens
- Requires API key

**Anthropic/Voyage AI**:
- Similar quality to OpenAI
- Similar pricing
- Requires API key

**Local** (sentence-transformers):
- Free
- Runs offline
- No API key needed
- Slightly lower quality

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions including:
- Docker deployment
- Systemd service setup
- Monitoring and logging
- Troubleshooting
- Security best practices

## Development

### Running Tests

```bash
# Test search functionality
python mcp-server/test_search.py

# Test with specific provider
EMBEDDING_PROVIDER=local python mcp-server/test_search.py
```

### Updating FAQs

```bash
# 1. Edit FAQ file
nano "FAQ Data/Unified_FAQ.txt"

# 2. Re-parse and ingest
python scripts/parse_faq.py
python scripts/ingest_to_mongodb.py

# 3. Regenerate embeddings
python scripts/generate_embeddings.py

# 4. Restart server
docker-compose restart  # or systemctl restart faq-mcp
```

## FAQ Categories

The database includes 54 FAQs across 12 categories:

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

## Troubleshooting

### MongoDB Connection Failed
- Verify `MONGODB_URI` is correct
- Check IP whitelist in MongoDB Atlas
- Test connection with `mongosh`

### Missing API Key
- Set `OPENAI_API_KEY` in `.env`
- Or use local embeddings: `EMBEDDING_PROVIDER=local`

### No Embeddings Found
- Run `python scripts/generate_embeddings.py`
- Or continue with TF-IDF only (still works)

See [DEPLOYMENT.md](DEPLOYMENT.md) for more troubleshooting tips.

## License

Created for VLED, Indian Institute of Technology, Ropar

## Support

- **Email**: internship-support@vicharanashala.zohodesk.in
- **DLED Team**: dled@iitrpr.ac.in

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Acknowledgments

- Built with [MCP (Model Context Protocol)](https://modelcontextprotocol.io/)
- Powered by MongoDB Atlas
- Embeddings by OpenAI, Anthropic, or sentence-transformers
