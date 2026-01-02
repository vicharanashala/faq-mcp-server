# Multi-stage Docker build for FAQ MCP Server
FROM python:3.12-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY mcp-server/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.12-slim

# Create non-root user
RUN useradd -m -u 1000 faquser

# Set working directory
WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/faquser/.local

# Copy application code
COPY mcp-server/ ./mcp-server/
COPY scripts/ ./scripts/

# Set ownership
RUN chown -R faquser:faquser /app

# Switch to non-root user
USER faquser

# Add local bin to PATH
ENV PATH=/home/faquser/.local/bin:$PATH

# Set Python to run in unbuffered mode
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Run the server
CMD ["python", "mcp-server/faq_server.py"]
