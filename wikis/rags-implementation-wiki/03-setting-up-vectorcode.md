# 03 - Setting up VectorCode

## What is VectorCode?

VectorCode is a repository-level RAG (Retrieval-Augmented Generation) system that:

- **Indexes your codebase** using semantic embeddings
- **Enables natural language search** across all your code
- **Provides context-aware results** for AI assistance
- **Updates automatically** when code changes
- **Integrates with Neovim** for seamless workflows

## Installation

### Prerequisites Check

Before installing VectorCode, ensure you have:

```bash
# Check Python version (3.8+ required)
python3 --version

# Check pip/pipx availability
pip3 --version
# OR
pipx --version

# Verify Ollama is running with embedding model
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "prompt": "test"}'
```

### Install VectorCode CLI

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

#### Option 3: Development Installation

```bash
# Clone repository for latest features
git clone https://github.com/Davidyz/VectorCode.git
cd VectorCode

# Install in development mode
pip3 install -e .

# Verify installation
vectorcode --version
```

## Configuration

### Create Configuration Directory

```bash
# Create VectorCode config directory
mkdir -p ~/.config/vectorcode

# Create main configuration file
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "host": "localhost",
  "port": 8000,
  "chunk_size": 512,
  "chunk_overlap": 50,
  "supported_extensions": [
    ".py", ".js", ".ts", ".lua", ".go", ".rs", 
    ".java", ".cpp", ".c", ".h", ".hpp", ".cc",
    ".md", ".txt", ".json", ".yaml", ".yml",
    ".sh", ".bash", ".zsh", ".fish"
  ],
  "ignore_patterns": [
    "node_modules/",
    ".git/",
    "__pycache__/",
    "*.pyc",
    ".DS_Store",
    "target/",
    "build/",
    "dist/",
    ".venv/",
    "venv/"
  ]
}
EOF
```

### Project-Specific Configuration

For each project, you can create a local configuration:

```bash
# In your project directory
cat > .vectorcode.json << 'EOF'
{
  "chunk_size": 256,
  "supported_extensions": [".py", ".md"],
  "ignore_patterns": [
    "tests/",
    "docs/",
    "*.log"
  ],
  "collection_name": "my-project"
}
EOF
```

## Testing VectorCode Installation

### Basic Functionality Test

```bash
# Test VectorCode CLI
vectorcode --help

# Test connection to Ollama embeddings
vectorcode test-embeddings

# Check configuration
vectorcode config show
```

**Expected Output:**
```
VectorCode CLI v1.0.0
✅ Ollama embeddings working
✅ Configuration loaded from ~/.config/vectorcode/config.json
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

# Initialize VectorCode for this project
vectorcode init

# Index the project
vectorcode vectorise --project_root . --recursive

# Verify indexing
vectorcode list-collections
```

**Expected Output:**
```
✅ VectorCode initialized for project
📁 Indexing files in .
📝 Found 3 files to index
🔄 Processing main.py...
🔄 Processing utils.py...
🔄 Processing README.md...
✅ Indexing complete! 3 files processed.

Collections:
- test-vectorcode (3 documents, 12 chunks)
```

### Test Semantic Search

```bash
# Test various search queries
vectorcode query "fibonacci function"
vectorcode query "calculate factorial"
vectorcode query "prime number check"
vectorcode query "mathematical functions"
```

**Expected Output:**
```
🔍 Query: "fibonacci function"

📄 main.py (similarity: 0.89)
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

📄 README.md (similarity: 0.72)
- Fibonacci number calculation
```

## Advanced Configuration

### Multiple Project Collections

```bash
# Index different projects with specific collection names
cd ~/projects/backend
vectorcode vectorise --project_root . --collection backend

cd ~/projects/frontend  
vectorcode vectorise --project_root . --collection frontend

cd ~/projects/docs
vectorcode vectorise --project_root . --collection documentation

# List all collections
vectorcode list-collections
```

### Incremental Updates

```bash
# Update existing index (only processes changed files)
vectorcode update

# Force full re-indexing
vectorcode vectorise --project_root . --force

# Update specific collection
vectorcode update --collection backend
```

### Query Options

```bash
# Query with specific number of results
vectorcode query "authentication" --num-results 5

# Query specific collection
vectorcode query "user login" --collection backend

# Query with similarity threshold
vectorcode query "database connection" --min-similarity 0.7

# Output results as JSON
vectorcode query "error handling" --output json
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
