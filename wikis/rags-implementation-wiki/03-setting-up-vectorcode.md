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

# If you see Python 3.10 or older, VectorCode will NOT install
# You'll need to upgrade Python first (see Troubleshooting section below)

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

| Feature                 | Option 1: pipx           | Option 2: pip              | Option 3: CPU-only      | Option 4: Development      | Option 5: Additional Features | Option 6: Virtual Environment |
|-------------------------|--------------------------|----------------------------|-------------------------|----------------------------|-------------------------------|-------------------------------|
| **Installation Method** | pipx                     | pip                        | pipx with CPU flags     | Git + pip (editable)       | pipx with extras              | venv + pip                    |
| **Isolation**           | ✅ Isolated environment  | ❌ User Python environment | ✅ Isolated environment | ❌ Development environment | ✅ Isolated environment       | ✅ Fully isolated environment |
| **CUDA Support**        | ✅ Default               | ✅ Default                 | ❌ CPU only             | ✅ Default                 | ✅ Default                    | ✅ Default                    |
| **LSP Support**         | ❌ Not included          | ❌ Not included            | ❌ Not included         | ❌ Not included            | ✅ Optional                   | ✅ Optional                   |
| **MCP Support**         | ❌ Not included          | ❌ Not included            | ❌ Not included         | ❌ Not included            | ✅ Optional                   | ✅ Optional                   |
| **Latest Features**     | ❌ Release version       | ❌ Release version         | ❌ Release version      | ✅ Latest code             | ❌ Release version            | ❌ Release version            |
| **Ease of Updates**     | ✅ Easy (`pipx upgrade`) | ⚠️ Moderate                | ✅ Easy (with flags)    | ⚠️ Git pull required       | ✅ Easy (`pipx upgrade`)      | ⚠️ Requires activation        |
| **Version Control**     | ❌ Single version        | ❌ Single version          | ❌ Single version       | ✅ Git-based versions      | ❌ Single version             | ✅ Multiple projects/versions |
| **Project Isolation**   | ❌ Global installation   | ❌ Global installation     | ❌ Global installation  | ❌ Global installation     | ❌ Global installation        | ✅ Per-project isolation     |
| **Best For**            | Most users               | Simple setup               | Limited GPU resources   | Contributors/developers    | Advanced features             | Multiple projects/versions    |

**Notes:**
- Option 1 (pipx) is recommended for most users due to environment isolation
- Option 3 is ideal for systems without GPU or to avoid CUDA dependencies
- Option 4 gives you the latest unreleased features but may be less stable
- Option 5 adds LSP support for faster queries and/or MCP for enhanced model context
- Option 6 (virtual environments) is ideal for developers working on multiple projects with different VectorCode requirements

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

#### Option 6: Virtual Environment Installation

Virtual environments provide the highest level of isolation and are ideal for:
- Working on multiple projects with different VectorCode versions
- Testing different configurations without affecting global installations
- Ensuring reproducible environments across team members
- Avoiding conflicts with other Python packages

```bash
# Create a virtual environment for VectorCode
python3 -m venv ~/.venvs/vectorcode

# Activate the virtual environment
source ~/.venvs/vectorcode/bin/activate

# Install VectorCode
pip install vectorcode

# Install with additional features if needed
pip install vectorcode[lsp,mcp]

# Verify installation
vectorcode --version

# Create an alias for easy activation (add to ~/.bashrc or ~/.zshrc)
echo 'alias activate-vectorcode="source ~/.venvs/vectorcode/bin/activate"' >> ~/.bashrc
source ~/.bashrc
```

**Per-Project Virtual Environments:**

For even better isolation, create separate virtual environments for each project:

```bash
# Navigate to your project directory
cd ~/my-project

# Create project-specific virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate

# Install VectorCode
pip install vectorcode

# Create a requirements.txt for reproducibility
echo "vectorcode==0.6.10" > requirements.txt

# Deactivate when done
deactivate
```

**Virtual Environment Management Script:**

```bash
# Create a helper script for managing VectorCode environments
cat > ~/bin/vectorcode-env << 'EOF'
#!/bin/bash

VENV_BASE="$HOME/.venvs"
PROJECT_VENV=".venv"

case "$1" in
    "global")
        source "$VENV_BASE/vectorcode/bin/activate"
        echo "✅ Activated global VectorCode environment"
        ;;
    "local")
        if [ -d "$PROJECT_VENV" ]; then
            source "$PROJECT_VENV/bin/activate"
            echo "✅ Activated local VectorCode environment"
        else
            echo "❌ No local .venv found. Create one with: python3 -m venv .venv"
            exit 1
        fi
        ;;
    "create")
        if [ -z "$2" ]; then
            echo "Usage: vectorcode-env create <env-name>"
            exit 1
        fi
        python3 -m venv "$VENV_BASE/$2"
        source "$VENV_BASE/$2/bin/activate"
        pip install vectorcode
        echo "✅ Created and activated VectorCode environment: $2"
        ;;
    "list")
        echo "Available VectorCode environments:"
        ls -1 "$VENV_BASE" | grep -E '^(vectorcode|.*-vectorcode)$' || echo "No environments found"
        ;;
    *)
        echo "Usage: vectorcode-env {global|local|create <name>|list}"
        echo "  global - Activate global VectorCode environment"
        echo "  local  - Activate local project environment (.venv)"
        echo "  create - Create new named environment"
        echo "  list   - List available environments"
        ;;
esac
EOF

chmod +x ~/bin/vectorcode-env

# Add ~/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi
```

### Virtual Environments vs Other Installation Methods: Analysis

#### Advantages of Virtual Environments

**1. Complete Isolation**
- Each project can have its own VectorCode version and dependencies
- No conflicts between different projects' requirements
- Safe to experiment without affecting other installations

**2. Version Management**
- Easy to test different VectorCode versions
- Can maintain legacy projects with older versions
- Rollback capabilities if updates cause issues

**3. Team Collaboration**
- `requirements.txt` files ensure consistent environments across team members
- Reproducible setups for CI/CD pipelines
- Documentation of exact dependency versions

**4. Development Flexibility**
- Can install development versions alongside stable releases
- Easy to switch between different configurations (CPU-only, GPU, etc.)
- Test different embedding models or configurations per project

**5. System Cleanliness**
- No global package pollution
- Easy cleanup by deleting environment directory
- Multiple Python versions supported per project

#### Disadvantages of Virtual Environments

**1. Management Overhead**
- Must remember to activate environments
- More complex workflow for beginners
- Additional commands to manage environments

**2. Storage Usage**
- Each environment duplicates dependencies
- Can consume significant disk space with multiple environments
- Larger backup requirements

**3. Learning Curve**
- Requires understanding of Python virtual environments
- More complex than simple `pip install` or `pipx install`
- Additional concepts for new developers

**4. Path Management**
- Need to ensure correct environment is activated
- Potential confusion if wrong environment is active
- Shell integration complexity

#### When to Choose Virtual Environments

**Choose Virtual Environments When:**

✅ **Multiple Projects**: Working on several projects that might need different VectorCode versions or configurations

✅ **Team Development**: Need to ensure consistent environments across team members

✅ **Experimentation**: Frequently testing different configurations, models, or VectorCode versions

✅ **CI/CD Integration**: Need reproducible builds and deployments

✅ **Version Constraints**: Specific projects require particular VectorCode versions

✅ **Dependency Conflicts**: Other Python tools conflict with VectorCode's dependencies

✅ **Development Work**: Contributing to VectorCode or building tools around it

**Choose pipx Instead When:**

❌ **Single Project**: Only working on one project that uses VectorCode

❌ **Simplicity Preferred**: Want the simplest possible installation and management

❌ **Casual Usage**: Occasional use without complex requirements

❌ **Beginner Users**: New to Python development and virtual environments

❌ **System Tools**: Using VectorCode as a general system utility across all projects

#### Recommendation Summary

**For Most Users**: Start with **pipx** (Option 1) for its simplicity and built-in isolation.

**For Development Teams**: Use **Virtual Environments** (Option 6) to ensure consistency and enable per-project customization.

**For Enterprise**: Consider **Virtual Environments** for better compliance, reproducibility, and version control.

**Migration Path**: You can always start with pipx and migrate to virtual environments later as your needs grow more complex.

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

If you want to use Ollama for embeddings instead of the default SentenceTransformers, follow these steps:

#### Prerequisites for Ollama Embeddings

**1. Ensure Ollama is Running**
```bash
# Check if Ollama is running
curl -f http://127.0.0.1:11434/api/tags 2>/dev/null && echo "✅ Ollama is running" || echo "❌ Ollama is not running"

# If not running, start Ollama (see guide 02-setting-up-ollama.md)
ollama serve
```

**2. Verify nomic-embed-text Model is Available**
```bash
# Check if the embedding model is installed
ollama list | grep nomic-embed-text

# If not installed, pull the model
ollama pull nomic-embed-text

# Test the embedding model
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "prompt": "test embedding"}' \
  | jq '.embedding[0:5]'  # Should return first 5 embedding values
```

#### Create Ollama Configuration

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

#### Verify Ollama Configuration

```bash
# Test VectorCode with Ollama embeddings
cd ~/test-vectorcode  # or any test directory
vectorcode init

# Create a simple test file
echo "def hello_world(): print('Hello, World!')" > test.py

# Test embedding with Ollama (this will verify the configuration works)
vectorcode vectorise test.py

# If successful, you should see output like:
# ✅ Using OllamaEmbeddingFunction with nomic-embed-text
# 📝 Processing test.py (1 chunk)
# ✅ Indexing complete!

# Test querying
vectorcode query "hello function"
```

#### Configuration Parameters Explained

- **`embedding_function`**: Specifies which embedding backend to use
  - `"OllamaEmbeddingFunction"` for Ollama
  - `"SentenceTransformerEmbeddingFunction"` for default (no config needed)

- **`embedding_params`**: Parameters specific to the chosen function
  - `url`: Ollama embeddings API endpoint (usually `http://127.0.0.1:11434/api/embeddings`)
  - `model_name`: The embedding model to use (`nomic-embed-text` is recommended)

- **`chunk_size`**: Maximum characters per code chunk (2500 is optimal for most codebases)
- **`overlap_ratio`**: Overlap between chunks as ratio (0.2 = 20% overlap for better context)

#### Alternative Embedding Models

You can use other Ollama embedding models by changing the `model_name`:

```bash
# Available embedding models (pull if needed)
ollama pull all-minilm        # Smaller, faster
ollama pull mxbai-embed-large # Larger, more accurate

# Update config for different model
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "mxbai-embed-large"
  },
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
EOF
```

#### Troubleshooting Ollama Configuration

**Issue**: "Connection refused" or "Ollama not responding"
```bash
# Check Ollama status and restart if needed
pgrep ollama || echo "Ollama not running"
ollama serve &  # Start in background
sleep 5  # Wait for startup
curl http://127.0.0.1:11434/api/tags  # Test connection
```

**Issue**: "Model not found" error
```bash
# Ensure the embedding model is pulled
ollama pull nomic-embed-text
ollama list | grep embed  # Verify it's installed
```

**Issue**: VectorCode still uses SentenceTransformers
```bash
# Verify config file exists and is valid JSON
cat ~/.config/vectorcode/config.json | jq .  # Should parse without errors

# Check config location (VectorCode looks for config in this order):
# 1. ./.vectorcode.json (project-specific)
# 2. ~/.config/vectorcode/config.json (global)
# 3. Default SentenceTransformers (if no config found)
```

### SentenceTransformers vs Ollama Embeddings: Detailed Comparison

Before choosing your embedding strategy, understand the trade-offs between VectorCode's default SentenceTransformers and Ollama embeddings:

#### Feature Comparison Table

| Feature | SentenceTransformers (Default) | Ollama Embeddings |
|---------|--------------------------------|------------------|
| **Setup Complexity** | ✅ Zero configuration required | ⚠️ Requires Ollama installation and configuration |
| **Installation Size** | ✅ ~200MB (included with VectorCode) | ⚠️ 2-8GB (Ollama + embedding models) |
| **Startup Time** | ✅ Instant (loads with VectorCode) | ⚠️ 2-5 seconds (API calls to Ollama) |
| **Resource Usage** | ✅ Low CPU, ~500MB RAM | ⚠️ Higher CPU/GPU, 1-4GB RAM |
| **Offline Usage** | ✅ Completely offline | ✅ Offline (after model download) |
| **Internet Dependency** | ✅ None after installation | ✅ None after model download |
| **Model Quality** | ✅ Good (`all-MiniLM-L6-v2`) | ✅ Excellent (`nomic-embed-text`) |
| **Embedding Dimensions** | 384 dimensions | 768 dimensions (nomic-embed-text) |
| **Code Understanding** | ✅ Good for general text and code | ✅ Better for code-specific embeddings |
| **Customization** | ⚠️ Limited model choices | ✅ Multiple model options |
| **Performance** | ✅ Consistent, predictable | ⚠️ Depends on hardware and model |
| **Reliability** | ✅ No external dependencies | ⚠️ Requires Ollama service to be running |
| **Memory Persistence** | ✅ Stays loaded in VectorCode process | ⚠️ Separate Ollama process management |
| **Multi-language Support** | ✅ 50+ languages | ✅ 100+ languages (model dependent) |
| **Updates** | ✅ Automatic with VectorCode updates | ⚠️ Manual model updates via Ollama |

#### Performance Benchmarks

**Embedding Speed Comparison (1000 code chunks):**
```bash
# SentenceTransformers (typical)
Processing time: ~15-30 seconds
Memory usage: ~500MB additional
CPU usage: 80-100% during processing

# Ollama (nomic-embed-text)
Processing time: ~45-90 seconds
Memory usage: ~2-4GB additional
CPU/GPU usage: Variable (depends on hardware)
```

**Search Quality Comparison (subjective assessment):**
- **SentenceTransformers**: Good semantic understanding, reliable results
- **Ollama**: Better context understanding, especially for code patterns and technical terminology

#### Detailed Analysis

**1. Setup and Maintenance**

**SentenceTransformers:**
```bash
# No configuration needed - works out of the box
vectorcode init
vectorcode vectorise *.py  # Just works
```

**Ollama:**
```bash
# Requires setup and maintenance
ollama serve &  # Must be running
ollama pull nomic-embed-text  # Model management
# Plus configuration file creation
```

**2. Resource Usage Patterns**

**SentenceTransformers:**
- Memory usage is predictable and lower
- CPU spikes only during embedding creation
- No additional processes to manage

**Ollama:**
- Higher baseline memory usage from Ollama service
- GPU acceleration available (if supported)
- Separate process management required

**3. Code-Specific Performance**

**Test Query: "authentication function with JWT token validation"**

*SentenceTransformers Results:*
```
auth.py:15-25 (score: 0.72)
def authenticate_user(token):
    """Validate JWT token and return user"""
    # Implementation...
```

*Ollama (nomic-embed-text) Results:*
```
auth.py:15-25 (score: 0.89)
def authenticate_user(token):
    """Validate JWT token and return user"""
    # Implementation...

security.py:45-55 (score: 0.81)
class JWTValidator:
    """JWT token validation utilities"""
    # Implementation...
```

**Analysis**: Ollama often provides better semantic understanding and more relevant results, especially for technical queries.

#### When to Choose Each Option

**Choose SentenceTransformers When:**

✅ **Simplicity First**: You want zero-configuration setup
✅ **Resource Constraints**: Limited RAM/disk space (<2GB available)
✅ **Reliability Priority**: Need consistent, predictable performance
✅ **Single Developer**: Personal projects without complex requirements
✅ **Quick Start**: Want to try VectorCode immediately
✅ **Stable Environment**: Don't want external service dependencies
✅ **Battery Life**: Working on laptops where efficiency matters

**Choose Ollama Embeddings When:**

✅ **Quality Priority**: Need the best possible search results
✅ **Code-Heavy Projects**: Working primarily with source code
✅ **Large Codebases**: >100k lines where search quality matters more
✅ **Team Environment**: Shared infrastructure can handle Ollama
✅ **GPU Available**: Have GPU acceleration for faster processing
✅ **Technical Expertise**: Comfortable managing additional services
✅ **Custom Models**: Want to experiment with different embedding models
✅ **Multi-language**: Working with diverse programming languages

#### Migration Between Approaches

**From SentenceTransformers to Ollama:**
```bash
# 1. Install and configure Ollama (see above sections)
# 2. Create Ollama configuration
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

# 3. Re-index your projects (embeddings are not compatible)
vectorcode clean  # Remove old embeddings
vectorcode vectorise .  # Re-create with Ollama
```

**From Ollama to SentenceTransformers:**
```bash
# 1. Remove or rename the configuration file
mv ~/.config/vectorcode/config.json ~/.config/vectorcode/config.json.backup

# 2. Re-index projects
vectorcode clean
vectorcode vectorise .  # Uses SentenceTransformers by default
```

#### Hybrid Approach

You can use different embedding strategies for different projects:

```bash
# Global default: SentenceTransformers (no config file)
# Project-specific: Ollama (local .vectorcode.json)

cd ~/important-project
cat > .vectorcode.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  }
}
EOF

cd ~/quick-scripts
# Uses default SentenceTransformers (no local config)
```

#### Recommendation Summary

**For Most Users**: Start with **SentenceTransformers** (default) for its simplicity and reliability. You can always upgrade to Ollama later as your needs grow.

**For Power Users**: Use **Ollama embeddings** if you have the resources and want the best possible search quality for code-heavy projects.

**For Teams**: Consider **SentenceTransformers** for consistency unless your team has dedicated infrastructure for running Ollama reliably.

**Migration Strategy**: Begin with SentenceTransformers, and migrate specific high-value projects to Ollama embeddings as needed.

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

### Installation Issues

#### Python Version Compatibility Error

**Error Message:**
```
ERROR: Ignored the following versions that require a different python version: 0.6.10 Requires-Python <3.14,>=3.11
ERROR: Could not find a version that satisfies the requirement vectorcode
ERROR: No matching distribution found for vectorcode
```

**Root Cause:** VectorCode requires Python 3.11-3.13, but your system has Python 3.10 or older.

**Solution Options:**

**Option 1: Install Python 3.11+ via pyenv (Recommended)**

*Note: If pyenv installation fails, see Option 1b below for a virtual environment alternative.*

```bash
# Install pyenv dependencies first
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev

# Install pyenv
curl https://pyenv.run | bash

# Add pyenv to your shell (add to ~/.bashrc or ~/.zshrc)
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc

# If pyenv command is still not found, try:
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# Install Python 3.11 (or 3.12, 3.13)
pyenv install 3.11.9
pyenv global 3.11.9

# Verify version
python3 --version  # Should show Python 3.11.9

# Now install VectorCode with the correct Python version
pipx install vectorcode --python $(which python3)
```

**Option 1b: Virtual Environment Alternative (If pyenv fails)**

If pyenv installation is unsuccessful or you prefer a simpler approach, use this virtual environment method:

```bash
# First install Python 3.11 via system package manager
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-pip

# Create a virtual environment in your home directory
python3.11 -m venv ~/venv

# Activate the virtual environment
source ~/venv/bin/activate

# Verify you're using Python 3.11
python --version  # Should show Python 3.11.x

# Install VectorCode in the virtual environment
pip install vectorcode

# Verify installation
vectorcode --version

# Create convenient aliases (add to ~/.bashrc or ~/.zshrc)
echo 'alias activate-venv="source ~/venv/bin/activate"' >> ~/.bashrc
echo 'alias vectorcode-setup="source ~/venv/bin/activate && echo \"VectorCode environment activated (Python \$(python --version))\""' >> ~/.bashrc
source ~/.bashrc

# To use VectorCode in the future:
# 1. Activate the environment: activate-venv
# 2. Use VectorCode normally: vectorcode init, vectorcode query, etc.
# 3. Deactivate when done: deactivate
```

**Usage with Virtual Environment:**
```bash
# Start a new terminal session
activate-venv  # or: source ~/venv/bin/activate

# Now use VectorCode normally
cd ~/my-project
vectorcode init
vectorcode vectorise *.py
vectorcode query "function definition"

# When finished
deactivate
```

**Permanent Setup Script:**
Create a setup script for easy VectorCode access:

```bash
cat > ~/bin/vectorcode-venv << 'EOF'
#!/bin/bash

# Activate virtual environment and run vectorcode
source ~/venv/bin/activate
vectorcode "$@"
deactivate
EOF

chmod +x ~/bin/vectorcode-venv

# Add ~/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# Now you can use: vectorcode-venv init, vectorcode-venv query "test", etc.
```

**Option 2: Use System Package Manager**

*Ubuntu/Debian:*
```bash
# Add deadsnakes PPA for newer Python versions
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.11
sudo apt install python3.11 python3.11-venv python3.11-pip

# Install pipx with Python 3.11
python3.11 -m pip install --user pipx
python3.11 -m pipx ensurepath

# Install VectorCode using Python 3.11
pipx install vectorcode --python python3.11
```

*Fedora/RHEL:*
```bash
# Install Python 3.11
sudo dnf install python3.11 python3.11-pip

# Install VectorCode
pipx install vectorcode --python python3.11
```

*Arch Linux:*
```bash
# Install Python 3.11
sudo pacman -S python311

# Install VectorCode
pipx install vectorcode --python python3.11
```

**Option 3: Virtual Environment with Specific Python Version**
```bash
# Create virtual environment with Python 3.11 (if available)
python3.11 -m venv ~/.venvs/vectorcode-py311
source ~/.venvs/vectorcode-py311/bin/activate

# Install VectorCode
pip install vectorcode

# Create activation alias
echo 'alias vectorcode-env="source ~/.venvs/vectorcode-py311/bin/activate"' >> ~/.bashrc
```

**Option 4: Docker Alternative (If Python upgrade not possible)**
```bash
# Create a Dockerfile for VectorCode
cat > Dockerfile.vectorcode << 'EOF'
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install VectorCode
RUN pip install vectorcode

# Set working directory
WORKDIR /workspace

# Default command
CMD ["vectorcode", "--help"]
EOF

# Build the image
docker build -t vectorcode -f Dockerfile.vectorcode .

# Create wrapper script
cat > ~/bin/vectorcode-docker << 'EOF'
#!/bin/bash
docker run --rm -it \
  -v "$(pwd):/workspace" \
  -v "$HOME/.config/vectorcode:/root/.config/vectorcode" \
  vectorcode "$@"
EOF

chmod +x ~/bin/vectorcode-docker

# Use as: vectorcode-docker init
```

**Verification After Fix:**
```bash
# Check Python version
python3 --version  # Should be 3.11+

# Test VectorCode installation
vectorcode --version

# Test basic functionality
vectorcode check
```

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
