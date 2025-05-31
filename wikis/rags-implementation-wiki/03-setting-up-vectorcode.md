# 03 - Setting up VectorCode

## What is VectorCode?

VectorCode is a repository-level RAG (Retrieval-Augmented Generation) system that:

- **Indexes your codebase** using semantic embeddings with ChromaDB
- **Enables natural language search** across all your code
- **Provides context-aware results** for AI assistance
- **Supports multiple embedding backends** (SentenceTransformers, Ollama, OpenAI, etc.)
- **Uses TreeSitter** for intelligent code chunking
- **Integrates with Neovim** for seamless workflows

## Installation

### Prerequisites Check

Before installing VectorCode, ensure you have:

```bash
# Check Python version (3.11+ required - VectorCode needs Python 3.11-3.13)
python3 --version

# Check pip/pipx availability
pip3 --version
# OR
pipx --version

# Optional: Verify Ollama is running if you want to use Ollama embeddings
# (VectorCode works with SentenceTransformers by default)
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "prompt": "test"}'
```

### Install VectorCode CLI

#### Installation Options Comparison

| Feature | Option 1: pipx | Option 2: pip | Option 3: CPU-only | Option 4: Development | Option 5: Additional Features |
|---------|---------------|--------------|-------------------|---------------------|----------------------------|
| **Installation Method** | pipx | pip | pipx with CPU flags | Git + pip (editable) | pipx with extras |
| **Isolation** | ✅ Isolated environment | ❌ User Python environment | ✅ Isolated environment | ❌ Development environment | ✅ Isolated environment |
| **CUDA Support** | ✅ Default | ✅ Default | ❌ CPU only | ✅ Default | ✅ Default |
| **LSP Support** | ❌ Not included | ❌ Not included | ❌ Not included | ❌ Not included | ✅ Optional |
| **MCP Support** | ❌ Not included | ❌ Not included | ❌ Not included | ❌ Not included | ✅ Optional |
| **Latest Features** | ❌ Release version | ❌ Release version | ❌ Release version | ✅ Latest code | ❌ Release version |
| **Ease of Updates** | ✅ Easy (`pipx upgrade`) | ⚠️ Moderate | ✅ Easy (with flags) | ⚠️ Git pull required | ✅ Easy (`pipx upgrade`) |
| **Best For** | Most users | Simple setup | Limited GPU resources | Contributors/developers | Advanced features |

**Notes:**
- Option 1 (pipx) is recommended for most users due to environment isolation
- Option 3 is ideal for systems without GPU or to avoid CUDA dependencies
- Option 4 gives you the latest unreleased features but may be less stable
- Option 5 adds LSP support for faster queries and/or MCP for enhanced model context

#### Option 1: Using pipx (Recommended)

```bash
# Install pipx if not available
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Install VectorCode
pipx install vectorcode

# Verify installation
vectorcode --version
```

#### Option 2: Using pip

```bash
# Install VectorCode
pip3 install --user vectorcode

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
vectorcode --version
```

#### Option 3: CPU-only Installation

If you want to avoid CUDA dependencies:

```bash
# CPU-only installation
PIP_INDEX_URL="https://download.pytorch.org/whl/cpu" \
PIP_EXTRA_INDEX_URL="https://pypi.org/simple" \
pipx install vectorcode
```

#### Option 4: Development Installation

```bash
# Clone repository for latest features
git clone https://github.com/Davidyz/VectorCode.git
cd VectorCode

# Install in development mode
pip3 install -e .

# Verify installation
vectorcode --version
```

#### Option 5: With Additional Features

```bash
# Install with LSP support for faster queries
pipx install vectorcode[lsp]

# Install with MCP (Model Context Protocol) support
pipx install vectorcode[mcp]

# Install with both
pipx install vectorcode[lsp,mcp]
```

## Configuration

VectorCode uses ChromaDB as its vector database backend and supports multiple embedding functions. By default, it uses SentenceTransformers, but you can configure it to use Ollama, OpenAI, or other embedding providers.

### Default Configuration (SentenceTransformers)

VectorCode works out of the box with SentenceTransformers. No configuration file is needed for basic usage:

```bash
# Test basic functionality (uses default SentenceTransformers)
cd ~/test-project
vectorcode init
vectorcode vectorise *.py
vectorcode query "function definition"
```

### Optional: Ollama Configuration

If you want to use Ollama for embeddings, create a configuration file:

```bash
# Create VectorCode config directory
mkdir -p ~/.config/vectorcode

# Create configuration file for Ollama embeddings
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
EOF
```

### Configuration Options

VectorCode supports these configuration options:

- **`embedding_function`**: Embedding backend to use
  - `"SentenceTransformerEmbeddingFunction"` (default)
  - `"OllamaEmbeddingFunction"`
  - `"OpenAIEmbeddingFunction"`
  - Others supported by ChromaDB

- **`embedding_params`**: Parameters for the embedding function
  - For Ollama: `{"url": "...", "model_name": "..."}`
  - For OpenAI: `{"api_key": "...", "model_name": "..."}`

- **`db_url`**: ChromaDB server URL (default: `http://127.0.0.1:8000`)
- **`db_path`**: Local database path (default: `~/.local/share/vectorcode/chromadb/`)
- **`chunk_size`**: Maximum characters per chunk (default: 2500)
- **`overlap_ratio`**: Overlap between chunks (default: 0.2)

### Advanced Configuration Example

```bash
cat > ~/.config/vectorcode/config.json5 << 'EOF'
{
  // VectorCode supports JSON5 syntax with comments
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },

  // Database settings
  "db_url": "http://127.0.0.1:8000",
  "db_path": "~/.local/share/vectorcode/chromadb/",

  // Chunking settings
  "chunk_size": 2500,
  "overlap_ratio": 0.2,

  // Query optimization
  "query_multiplier": 10,
  "reranker": "CrossEncoderReranker",

  // File type mapping for TreeSitter
  "filetype_map": {
    "php": ["^phtml$"]
  },

  // Chunk filtering
  "chunk_filters": {
    "python": ["^[^a-zA-Z0-9]+$"],
    "*": ["^[^a-zA-Z0-9]+$"]
  }
}
EOF
```


### Project-Specific Configuration

For each project, you can create a local configuration:

```bash
# In your project directory
cat > .vectorcode.json << 'EOF'
{
  "chunk_size": 1500,
  "overlap_ratio": 0.15,
  "embedding_function": "SentenceTransformerEmbeddingFunction"
}
EOF
```

## Testing VectorCode Installation

### Basic Functionality Test

VectorCode provides these main commands:

- **`vectorcode init`** - Initialize a project for VectorCode
- **`vectorcode vectorise`** - Index files or directories
- **`vectorcode query`** - Search the indexed codebase
- **`vectorcode ls`** - List indexed files and collections
- **`vectorcode drop`** - Remove collections or files
- **`vectorcode update`** - Update existing indexes
- **`vectorcode clean`** - Clean up unused data
- **`vectorcode version`** - Show version information
- **`vectorcode check`** - Check system health

```bash
# Test VectorCode CLI
vectorcode --help

# Check version
vectorcode version

# Test basic functionality (this will work without any configuration)
vectorcode check
```

**Expected Output:**
```
VectorCode CLI v0.x.x
✅ ChromaDB connection working
✅ Embedding function available
```

### Create Test Project

```bash
# Create a test project
mkdir -p ~/test-vectorcode
cd ~/test-vectorcode

# Create sample files
cat > main.py << 'EOF'
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def factorial(n):
    """Calculate the factorial of n."""
    if n <= 1:
        return 1
    return n * factorial(n-1)

if __name__ == "__main__":
    print(f"Fibonacci(10): {fibonacci(10)}")
    print(f"Factorial(5): {factorial(5)}")
EOF

cat > utils.py << 'EOF'
import math

def is_prime(n):
    """Check if a number is prime."""
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

def gcd(a, b):
    """Calculate the greatest common divisor."""
    while b:
        a, b = b, a % b
    return a
EOF

cat > README.md << 'EOF'
# Test VectorCode Project

This is a test project for VectorCode functionality.

## Features

- Fibonacci number calculation
- Factorial calculation
- Prime number checking
- Greatest common divisor calculation

## Usage

```python
from main import fibonacci, factorial
from utils import is_prime, gcd

print(fibonacci(10))
print(factorial(5))
print(is_prime(17))
print(gcd(48, 18))
```
EOF
```

## Indexing Your First Project

### Initialize and Index

```bash
# Navigate to your test project
cd ~/test-vectorcode

# Initialize VectorCode for this project (creates .vectorcode/ directory)
vectorcode init

# Index specific files
vectorcode vectorise main.py utils.py README.md

# Or index all Python files
vectorcode vectorise *.py

# Or index entire directory recursively
vectorcode vectorise .

# Verify indexing
vectorcode ls
```

**Expected Output:**
```
✅ VectorCode initialized for project
📁 Indexing files...
📝 Processing main.py (3 chunks)
📝 Processing utils.py (2 chunks)
📝 Processing README.md (1 chunk)
✅ Indexing complete! 3 files, 6 chunks processed.

Files in collection:
- main.py (3 chunks)
- utils.py (2 chunks)
- README.md (1 chunk)
```

### Test Semantic Search

```bash
# Test various search queries
vectorcode query "fibonacci function"
vectorcode query "calculate factorial"
vectorcode query "prime number check"
vectorcode query "mathematical functions"

# Query with specific number of results
vectorcode query "function" --limit 3

# Query with similarity threshold
vectorcode query "calculation" --threshold 0.7
```

**Expected Output:**
```
Query: "fibonacci function"

main.py:1-8 (score: 0.89)
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

README.md:5-6 (score: 0.72)
- Fibonacci number calculation
```

## Advanced Configuration

### Multiple Project Collections

VectorCode creates separate collections for each project directory:

```bash
# Index different projects (each gets its own collection)
cd ~/projects/backend
vectorcode init
vectorcode vectorise .

cd ~/projects/frontend
vectorcode init
vectorcode vectorise .

cd ~/projects/docs
vectorcode init
vectorcode vectorise .

# List all collections across projects
vectorcode ls --all
```

### Incremental Updates

```bash
# Update existing index (only processes changed files)
vectorcode update

# Update specific files
vectorcode update main.py utils.py

# Force full re-indexing
vectorcode vectorise . --force

# Clean up removed files
vectorcode clean
```

### Query Options

```bash
# Query with specific number of results
vectorcode query "authentication" --limit 5

# Query with similarity threshold
vectorcode query "database connection" --threshold 0.7

# Output results as JSON
vectorcode query "error handling" --format json

# Show more context around matches
vectorcode query "function definition" --context 3

# Search in specific file types
vectorcode query "class definition" --include "*.py"
```

## Performance Optimization

### Chunking Strategy

```bash
# For large files, adjust chunk size
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "chunk_size": 1024,
  "chunk_overlap": 100,
  "max_chunks_per_file": 50
}
EOF
```

### Batch Processing

```bash
# Process multiple projects efficiently
cat > batch_index.sh << 'EOF'
#!/bin/bash

projects=(
  "~/projects/backend"
  "~/projects/frontend"
  "~/projects/mobile"
  "~/docs"
)

for project in "${projects[@]}"; do
  echo "Indexing $project..."
  cd "$project"
  vectorcode vectorise --project_root . --collection "$(basename "$project")"
done

echo "✅ All projects indexed!"
EOF

chmod +x batch_index.sh
./batch_index.sh
```

## Monitoring and Maintenance

### Health Check Script

```bash
cat > check_vectorcode_health.sh << 'EOF'
#!/bin/bash

echo "🔍 Checking VectorCode Health..."

# Check CLI availability
if command -v vectorcode &> /dev/null; then
    echo "✅ VectorCode CLI available"
    vectorcode --version
else
    echo "❌ VectorCode CLI not found"
    exit 1
fi

# Check configuration
if vectorcode config show &> /dev/null; then
    echo "✅ Configuration valid"
else
    echo "❌ Configuration error"
    exit 1
fi

# Test embeddings
if vectorcode test-embeddings &> /dev/null; then
    echo "✅ Ollama embeddings working"
else
    echo "❌ Embedding connection failed"
    exit 1
fi

# List collections
echo "📋 Available collections:"
vectorcode list-collections

echo "✅ VectorCode health check complete!"
EOF

chmod +x check_vectorcode_health.sh
./check_vectorcode_health.sh
```

### Automated Updates

```bash
# Create update script for regular maintenance
cat > update_vectorcode_indexes.sh << 'EOF'
#!/bin/bash

echo "🔄 Updating VectorCode indexes..."

# Update all collections
for collection in $(vectorcode list-collections --names-only); do
    echo "Updating collection: $collection"
    vectorcode update --collection "$collection"
done

# Clean up old embeddings
vectorcode cleanup --older-than 30d

echo "✅ Index updates complete!"
EOF

chmod +x update_vectorcode_indexes.sh

# Add to crontab for weekly updates
(crontab -l 2>/dev/null; echo "0 2 * * 0 $PWD/update_vectorcode_indexes.sh") | crontab -
```

## Troubleshooting

### Common Issues

**Issue**: "Embedding connection failed"
```bash
# Check Ollama status
curl http://127.0.0.1:11434/api/tags

# Verify embedding model
ollama list | grep nomic-embed-text

# Test embedding directly
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "prompt": "test"}'
```

**Issue**: "No files found to index"
```bash
# Check file extensions in config
vectorcode config show | grep supported_extensions

# List files that would be indexed
find . -name "*.py" -o -name "*.js" -o -name "*.md" | head -10
```

**Issue**: "Permission denied"
```bash
# Fix permissions
chmod -R 755 ~/.config/vectorcode
chown -R $USER ~/.config/vectorcode
```

## What's Next?

Now that VectorCode is indexing your code, we need to set up ChromaDB as the vector database backend for persistent storage and fast retrieval.

In the next guide, we'll:
1. Install and configure ChromaDB
2. Connect VectorCode to ChromaDB
3. Optimize vector storage and retrieval
4. Test the complete RAG pipeline

---

**Continue to:** [04 - Setting up ChromaDB](04-setting-up-chromadb.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for VectorCode-specific issues.
