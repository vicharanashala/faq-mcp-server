# FAQ MCP Server

Intelligent FAQ search system using FastMCP framework with hybrid TF-IDF and semantic embeddings.

## Features

- 🔍 **Hybrid Search**: TF-IDF + semantic embeddings
- 🤖 **Multi-Provider**: OpenAI, Anthropic, or local embeddings
- 📊 **54 FAQs**: Bootcamp, ViBe platform, attendance, certification
- ⚡ **FastMCP**: Clean architecture with HTTP API
- 🔌 **Port 9010**: Streamable-HTTP transport

## Quick Start

### 1. Setup

```bash
cd /home/ubuntu/Kshitij/Chat-bot/faq-mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure

```bash
# Ensure .env exists (copied from example)
cp .env.example .env
# Edit .env with your MongoDB URI and API keys if needed
```

### 3. Run

```bash
./run_server.sh
# Or: python faq.py
```

Server starts on `http://0.0.0.0:9010`

## Project Structure

```
faq-mcp-server/
├── FAQ Data/
│   └── Unified_FAQ.txt          # FAQ source data
├── faq.py                       # Single-file MCP server & logic
├── run_server.sh                # Startup script
├── requirements.txt             # Dependencies
├── .env                         # Configuration
└── README.md                    # Documentation
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_URI` | - | MongoDB connection (required) |
| `EMBEDDING_PROVIDER` | `openai` | openai, anthropic, or local |
| `OPENAI_API_KEY` | - | For OpenAI embeddings |
| `TFIDF_WEIGHT` | `0.3` | TF-IDF weight (0-1) |
| `EMBEDDING_WEIGHT` | `0.7` | Embedding weight (0-1) |
| `SERVER_PORT` | `9010` | Server port |

## Usage

### MCP Tool

The server exposes a `search_faq` tool:

```python
search_faq(query: str, top_k: int = 3) -> List[FAQResult]
```

**Example queries:**
- "How do I register?"
- "Can I use mobile for ViBe?"
- "What are the attendance requirements?"

### With MCP Clients

Connect via Claude Desktop or other MCP clients to `http://localhost:9010/mcp`

## Tech Stack

FastMCP • MongoDB • OpenAI/Anthropic/Local Embeddings • Pydantic • Python 3.12+
