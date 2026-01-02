# FAQ MCP Server

An intelligent FAQ search system using MCP (Model Context Protocol) with FastMCP framework and hybrid search combining TF-IDF and semantic embeddings.

## Features

- 🔍 **Hybrid Search**: Combines keyword matching (TF-IDF) with semantic understanding (embeddings)
- 🤖 **Multi-Provider Support**: OpenAI, Anthropic (Voyage AI), or local embeddings
- 📊 **54 FAQ Entries**: Covers bootcamp registration, ViBe platform, attendance, certification, and more
- ⚡ **Fast & Efficient**: In-memory caching with pre-built indices
- 🐳 **Production Ready**: Docker, systemd, structured logging
- 🔌 **FastMCP Framework**: Clean architecture with HTTP API support
- 📡 **HTTP Transport**: Accessible via streamable-http on port 9000

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

### 4. Run Server

```bash
# Run FastMCP server
python mcp-server/server.py
```

Server will start on `http://localhost:9000` with streamable-http transport.

---

## Architecture

### Module Structure

```
mcp-server/
├── server.py          # FastMCP server with tool definitions
├── functions.py       # Search logic and data processing
├── models.py          # Pydantic models for type safety
├── constants.py       # Configuration constants
├── requirements.txt   # Python dependencies
└── .env.example       # Environment template
```

### Design Pattern

Following the **ajrasakha** MCP architecture:
- **Separation of Concerns**: Clear module boundaries
- **Type Safety**: Pydantic models for all data structures
- **Async First**: All operations are async
- **FastMCP Framework**: Simplified MCP server setup

---

## Usage

### With MCP Clients

The server exposes a `search_faq` tool that can be called by any MCP client:

```python
# Tool signature
async def search_faq(query: str, top_k: int = 3) -> List[FAQResult]
```

**Example queries:**
- "How do I register for the bootcamp?"
- "Can I use mobile for ViBe?"
- "What are the attendance requirements?"
- "How do I get my certificate?"

### HTTP API

Since the server uses streamable-http transport, you can also access it via HTTP:

```bash
curl -X POST http://localhost:9000/search_faq \
  -H "Content-Type: application/json" \
  -d '{"query": "How do I register?", "top_k": 3}'
```

### Testing

```bash
# Test search functionality
python mcp-server/test_fastmcp.py
```

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
| `SERVER_HOST` | No | `localhost` | Server host |
| `SERVER_PORT` | No | `9000` | Server port |
| `ENVIRONMENT` | No | `development` | Environment mode |

---

## How It Works

### Hybrid Search Algorithm

1. **TF-IDF (30%)**: Keyword-based matching for exact terms
2. **Embeddings (70%)**: Semantic understanding for paraphrased questions

```
Final Score = (0.3 × TF-IDF Score) + (0.7 × Embedding Score)
```

### Data Models

**FAQResult:**
```python
{
  "question": "How can I register?",
  "answer": "Registration details are available...",
  "metadata": {
    "question_id": "Q2.3",
    "category": "Eligibility & Registration",
    "similarity_score": 1.0,
    "tfidf_score": 1.0,
    "embedding_score": 0.0,
    "search_method": "tfidf"
  }
}
```

---

## Deployment

### Docker

```bash
docker-compose up -d
```

### Systemd (Linux)

```bash
sudo cp faq-mcp.service /etc/systemd/system/
sudo systemctl enable --now faq-mcp
```

---

## Project Structure

```
Bootcamp-mcp/
├── FAQ Data/
│   └── Unified_FAQ.txt              # Source FAQ (54 entries)
│
├── scripts/
│   ├── parse_faq.py                 # Parse FAQ to JSON
│   ├── ingest_to_mongodb.py         # Ingest to MongoDB
│   └── generate_embeddings.py       # Generate embeddings
│
├── mcp-server/
│   ├── server.py                    # FastMCP server
│   ├── functions.py                 # Search logic
│   ├── models.py                    # Pydantic models
│   ├── constants.py                 # Configuration
│   ├── test_fastmcp.py              # Tests
│   ├── requirements.txt             # Dependencies
│   └── .env.example                 # Config template
│
├── Dockerfile                        # Docker build
├── docker-compose.yml                # Docker Compose
└── README.md                         # This file
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
# Just restart the Python process
```

---

## Troubleshooting

### MongoDB Connection Failed
- Verify `MONGODB_URI` is correct
- Check IP whitelist in MongoDB Atlas

### Missing API Key
- Set `OPENAI_API_KEY` in `.env`
- Or use local: `EMBEDDING_PROVIDER=local`

### No Embeddings Found
- Run: `python scripts/generate_embeddings.py`
- Or continue with TF-IDF only (still works)

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

## License

MIT License - See LICENSE file

Created for VLED, Indian Institute of Technology, Ropar

---

## Support

- **Email**: internship-support@vicharanashala.zohodesk.in
- **DLED Team**: dled@iitrpr.ac.in

---

## Tech Stack

- **Framework**: FastMCP
- **Database**: MongoDB Atlas
- **Embeddings**: OpenAI / Anthropic / sentence-transformers
- **Search**: TF-IDF + Cosine Similarity
- **Type Safety**: Pydantic
- **Transport**: Streamable-HTTP
- **Language**: Python 3.12+
