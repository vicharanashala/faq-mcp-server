# Contributing to FAQ MCP Server

Thank you for your interest in contributing!

## How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test your changes**: Run `python mcp-server/test_search.py`
5. **Commit**: `git commit -m "Add your feature"`
6. **Push**: `git push origin feature/your-feature-name`
7. **Create a Pull Request**

## Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/Bootcamp-mcp.git
cd Bootcamp-mcp

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r mcp-server/requirements.txt

# Configure environment
cp mcp-server/.env.example .env
# Edit .env with your settings
```

## Code Style

- Follow PEP 8 guidelines
- Use type hints where appropriate
- Add docstrings to functions and classes
- Keep functions focused and concise

## Testing

Before submitting a PR:

```bash
# Run tests
python mcp-server/test_search.py

# Test with different providers
EMBEDDING_PROVIDER=local python mcp-server/test_search.py
EMBEDDING_PROVIDER=openai python mcp-server/test_search.py
```

## Reporting Issues

When reporting issues, please include:
- Python version
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Error messages and logs

## Questions?

Contact: internship-support@vicharanashala.zohodesk.in
