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

| Feature                 | Option 1: pipx           | Option 2: pip              | Option 3: CPU-only      | Option 4: Development      | Option 5: Additional Features |
|-------------------------|--------------------------|----------------------------|-------------------------|----------------------------|-------------------------------|
| **Installation Method** | pipx                     | pip                        | pipx with CPU flags     | Git + pip (editable)       | pipx with extras              |
| **Isolation**           | ✅ Isolated environment  | ❌ User Python environment | ✅ Isolated environment | ❌ Development environment | ✅ Isolated environment       |
| **CUDA Support**        | ✅ Default               | ✅ Default                 | ❌ CPU only             | ✅ Default                 | ✅ Default                    |
| **LSP Support**         | ❌ Not included          | ❌ Not included            | ❌ Not included         | ❌ Not included            | ✅ Optional                   |
| **MCP Support**         | ❌ Not included          | ❌ Not included            | ❌ Not included         | ❌ Not included            | ✅ Optional                   |
| **Latest Features**     | ❌ Release version       | ❌ Release version         | ❌ Release version      | ✅ Latest code             | ❌ Release version            |
| **Ease of Updates**     | ✅ Easy (`pipx upgrade`) | ⚠️ Moderate                | ✅ Easy (with flags)    | ⚠️ Git pull required       | ✅ Easy (`pipx upgrade`)      |
| **Best For**            | Most users               | Simple setup               | Limited GPU resources   | Contributors/developers    | Advanced features             |

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
vectorcode version
```
You should see a warning about deprecated parameters, but the version number indicates successful installation:

```bash
vectorcode version
WARNING: vectorcode.cli_utils : "host" and "port" are deprecated and will be removed in 0.7.0. Use "db_url" (eg. http://localhost:8000).
0.6.10
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
cat > ~/.config/vectorcode/config.json << 'EOF' {
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
### Optional: GitHub Copilot Configuration

If you prefer to use GitHub Copilot instead of Ollama for code assistance:

```bash
# Install Copilot.vim plugin in your Neovim configuration
# Add to your plugin manager (example using lazy.nvim)
cat > ~/.config/nvim/lua/plugins/copilot.lua << 'EOF'
return {
  "github/copilot.vim",
  config = function()
    -- Enable Copilot for specific filetypes
    vim.g.copilot_filetypes = {
      ["*"] = true,
    }
    -- Optional: Set keybindings
    vim.g.copilot_no_tab_map = true
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
  end,
}
EOF
```
If you're using GitHub Copilot instead of Ollama, you don't need to change your VectorCode configuration for embeddings. VectorCode and Copilot serve different purposes in this setup:

1. VectorCode will still handle your codebase indexing and RAG capabilities
2. Copilot will handle code completions and suggestions

You can continue using the default SentenceTransformers embeddings for VectorCode, which doesn't require any special configuration:

````json path=~/.config/vectorcode/config.json mode=EDIT
{
  "embedding_function": "SentenceTransformerEmbeddingFunction",
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
````

Or if you prefer, you can still use Ollama just for embeddings while using Copilot for completions:

````json path=~/.config/vectorcode/config.json mode=EDIT
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
````

The key point is that VectorCode's configuration is independent of your code completion tool choice. You'll configure Copilot separately through its Neovim plugin as shown in the previous examples.

### Ollama Embeddings vs SentenceTransformer Embeddings

| Feature            | Ollama Embeddings                                   | SentenceTransformer Embeddings                       |
|--------------------|-----------------------------------------------------|------------------------------------------------------|
| **Implementation** | Uses Ollama API with models like `nomic-embed-text` | Python library using Hugging Face models             |
| **Installation**   | Requires Ollama server running                      | Included with VectorCode, no external service needed |
| **Offline Usage**  | Requires local Ollama server                        | Works completely offline                             |
| **Resource Usage** | Moderate (274MB for `nomic-embed-text`)             | Lightweight, runs in Python process                  |
| **Speed**          | Depends on Ollama server performance                | Generally fast, optimized for CPU                    |
| **Quality**        | High quality with models like `nomic-embed-text`    | Good quality with models like `all-MiniLM-L6-v2`     |
| **Customization**  | Can switch between different Ollama models          | Can use different SentenceTransformer models         |
| **Dependencies**   | Requires Ollama installation and setup              | Built-in to VectorCode                               |
| **Configuration**  | Requires explicit configuration in VectorCode       | Default option, works out of the box                 |
| **Consistency**    | Depends on Ollama server availability               | More consistent as it's built-in                     |
| **Integration**    | Requires network calls (even if local)              | Direct in-process calls                              |

#### Key Considerations

1. **Simplicity**: SentenceTransformer is the simpler option as it's built-in and requires no additional setup.

2. **Performance**: Both options provide good embedding quality, with Ollama potentially offering more advanced models.

3. **Dependencies**: SentenceTransformer eliminates the need for running Ollama if you're only using it for embeddings.

4. **Resource Management**: If you're already running Ollama for other purposes, using it for embeddings consolidates resource usage.

5. **Setup Effort**: SentenceTransformer works out of the box, while Ollama requires setting up and maintaining the Ollama server.

For most users who are using GitHub Copilot for code completion, the SentenceTransformer option is simpler and more straightforward since you don't need to run Ollama at all.

Note: GitHub Copilot requires a subscription and authentication. VectorCode will still be used for codebase search, while Copilot provides the code completion and generation features.

### Copilot vs Ollama: Comparison (Enterprise Focus)

| Feature                    | GitHub Copilot (Enterprise)                        | Ollama                                         |
|----------------------------|----------------------------------------------------|------------------------------------------------|
| **Hosting**                | Cloud-based with enterprise controls               | Self-hosted, runs locally                      |
| **Privacy**                | Enterprise data policies, optional IP indemnity    | All processing happens locally                 |
| **Cost**                   | Enterprise subscription ($19-39/user/month)        | Free, open-source                              |
| **Compliance**             | SOC 2, GDPR compliant, audit logs                  | Depends on self-hosted implementation          |
| **Model Quality**          | High-quality, trained on vast GitHub data          | Varies by model, generally good with CodeLlama |
| **Speed**                  | Very fast responses with enterprise SLAs           | Depends on local hardware, typically slower    |
| **Resource Usage**         | Minimal local resources                            | 2-8GB RAM per model, high CPU/GPU usage        |
| **Internet Requirement**   | Requires internet connection                       | Works offline after model download             |
| **Integration**            | Enterprise IDE integrations, admin controls        | Requires more configuration with CodeCompanion |
| **Customization**          | Enterprise policy controls, blocking capabilities  | Highly customizable (models, parameters, etc.) |
| **Team Management**        | Centralized license management, usage analytics    | Manual setup per developer                     |
| **Security**               | Enterprise-grade security, vulnerability filtering | Security depends on local implementation       |
| **Support**                | Enterprise support with SLAs                       | Community support only                         |
| **Codebase Understanding** | No direct codebase understanding                   | Works with VectorCode for codebase RAG         |

## Key Enterprise Considerations

1. **Governance**: Copilot Enterprise offers centralized management, policy controls, and usage analytics.

2. **Security**: Enterprise version includes vulnerability filtering and compliance certifications.

3. **Support**: Dedicated enterprise support with SLAs vs. community support for Ollama.

4. **Total Cost**: Higher subscription cost but potentially lower infrastructure and maintenance costs compared to self-hosting Ollama at scale.

5. **Deployment**: Standardized deployment across teams vs. individual developer setups with Ollama.

You can absolutely use the standard GitHub Copilot plugin alongside VectorCode for a hybrid approach that gives you the best of both worlds:

1. **Standard Copilot Plugin**: You can use the regular Copilot.vim plugin for code completions and suggestions.

2. **VectorCode for RAG**: VectorCode will still work perfectly for indexing your codebase locally and providing RAG capabilities.

This hybrid approach offers several benefits:

- **Cloud-based completions**: Get Copilot's high-quality completions without the resource usage of running models locally
- **Local codebase understanding**: VectorCode provides project-specific context through its RAG system
- **Privacy control**: Your codebase index stays local while only small code snippets go to Copilot
- **Lower resource usage**: No need to run large LLMs locally for completions

You would configure Copilot for completions and use VectorCode's query capabilities through CodeCompanion's slash commands to search your codebase. This gives you Copilot's powerful completions with the added context awareness of a local RAG system.

The standard Copilot plugin is much more affordable ($10/month) than the enterprise version while still providing excellent code completion capabilities.


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
# Advantages of Project-Specific VectorCode Configuration

Having a separate `.vectorcode.json` configuration file for each project offers several key benefits:

1. **Tailored Chunking Strategy**: Different codebases have different characteristics - you can optimize chunk size and overlap for each project's specific code style and file sizes.

2. **Project-Specific Embedding Models**: You can use different embedding models for different projects based on their domain (e.g., more code-focused models for backend projects, more natural language models for documentation projects).

3. **Isolation Between Projects**: Each project maintains its own configuration, preventing settings from one project affecting another.

4. **Optimized Performance**: You can tune performance parameters based on each project's size and complexity:
   - Smaller chunk sizes for dense, complex codebases
   - Larger chunks for more documentation-heavy projects

5. **Team Collaboration**: Project-specific configs can be committed to version control, ensuring all team members use the same optimized settings.

6. **Resource Management**: You can allocate resources differently based on project importance:
   - Higher quality embeddings for critical projects
   - Faster, lighter embeddings for less critical projects

7. **Query Customization**: Different projects might benefit from different query strategies (reranking, filtering, etc.).

8. **File Type Handling**: Projects with different language compositions can have customized file type handling.

9. **Versioning and Migration**: As your projects evolve, you can update configurations independently without affecting other projects.

10. **Testing and Experimentation**: You can experiment with different configurations on specific projects without changing your global settings.

This approach follows the principle of "configuration as code" - your indexing strategy becomes part of your project, ensuring consistent and optimized results for each specific codebase.


## Testing VectorCode Installation

### Basic Functionality Test

VectorCode provides these main commands:

- **`vectorcode init`** - Initialize a project for VectorCode
    - This will initalize a project for VectorCode. It will create a `.vectorcode` directory in the project root. This directory will contain the configuration file and other metadata.
- **`vectorcode vectorise`** - Index files or directories
    - This will index the files or directories. It will create a collection in the ChromaDB database. The collection will contain the vector embeddings for the files.
- **`vectorcode query`** - Search the indexed codebase
- **`vectorcode ls`** - List indexed files and collections
- **`vectorcode drop`** - Remove collections or files
- **`vectorcode update`** - Update existing indexes
- **`vectorcode clean`** - Clean up unused data
- **`vectorcode version`** - Show version information
- **`vectorcode check`** - Check system health

Whether to include the `.vectorcode` file in `.gitignore` depends on your team's workflow and preferences:

## Reasons to commit `.vectorcode` (exclude from `.gitignore`):

1. **Consistent team experience**: Everyone uses the same optimized configuration
2. **Configuration as code**: Treat indexing strategy as part of your project
3. **Version control benefits**: Track changes to indexing strategy over time
4. **Onboarding**: New team members get the optimal configuration automatically
5. **Project-specific optimizations**: Ensure everyone benefits from tailored settings

## Reasons to add to `.gitignore`:

1. **Personal preferences**: Allow developers to customize their own indexing settings
2. **Hardware differences**: Team members with different hardware might need different settings
3. **Avoid conflicts**: Prevent merge conflicts on configuration changes
4. **Local paths**: If configuration contains absolute paths specific to each developer
5. **Different embedding models**: If team members use different local models

## Recommendation:

For most teams, it's better to **commit the `.vectorcode` file** (exclude from `.gitignore`) because:

1. The benefits of consistent configuration usually outweigh individual preferences
2. Most configuration options are project-specific, not developer-specific
3. You can always override global settings in your personal VectorCode config

If you do commit it, consider documenting the reasoning in your project README so team members understand why it's version controlled.


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
vectorcode ls

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
