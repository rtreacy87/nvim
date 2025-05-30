# 01 - Introduction and Prerequisites

## What is RAGS?

RAGS (Retrieval-Augmented Generation System) is a local AI development environment that combines:

- **Retrieval**: Semantic search through your codebase using vector embeddings
- **Augmented**: Enhanced AI responses with relevant code context
- **Generation**: Local LLM-powered code assistance and explanations

Instead of generic AI responses, RAGS provides answers based on YOUR actual code, patterns, and documentation.

## Why Use RAGS?

### Traditional AI Coding Assistants
- ❌ Send your code to external servers
- ❌ Provide generic responses without project context
- ❌ Require ongoing subscription fees
- ❌ Don't work offline
- ❌ Limited understanding of your specific codebase

### RAGS Local AI Assistant
- ✅ Keeps all code and data on your machine
- ✅ Understands your specific codebase and patterns
- ✅ One-time setup with no ongoing costs
- ✅ Works completely offline
- ✅ Learns from your actual code and documentation

## Real-World Example

**Traditional AI Assistant:**
```
You: "How do I handle authentication in this project?"
AI: "Here's a generic example using JWT tokens..."
```

**RAGS Assistant:**
```
You: "/codebase how do I handle authentication in this project?"
AI: "Based on your codebase, you're using a custom middleware in 
auth/middleware.py that validates tokens from the Authorization 
header. Here's how it works in your project:

[Shows actual code from your auth/middleware.py]

You can use this pattern in your new endpoint by adding the 
@require_auth decorator like in user/routes.py..."
```

## System Requirements

### Hardware Requirements
- **RAM**: 8GB minimum, 16GB+ recommended
- **Storage**: 10GB+ free space for models and embeddings
- **CPU**: Modern multi-core processor (Intel i5/AMD Ryzen 5 or better)
- **GPU**: Optional but recommended for faster inference

### Software Requirements

#### Essential Tools
- **Neovim 0.9+** with Lazy.nvim package manager
- **Python 3.8+** with pip or pipx
- **Docker** for running ChromaDB
- **Git** for version control
- **curl** for API testing

#### Operating System Support
- ✅ **macOS** (Intel and Apple Silicon)
- ✅ **Linux** (Ubuntu 20.04+, Fedora, Arch, etc.)
- ✅ **Windows** (with WSL2 recommended)

### Checking Your System

Run these commands to verify your system meets the requirements:

```bash
# Check Neovim version
nvim --version | head -1

# Check Python version
python3 --version

# Check Docker
docker --version

# Check available RAM
free -h  # Linux
vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' | awk '{print $1 * 4096 / 1024 / 1024 " MB"}' # macOS

# Check available disk space
df -h ~
```

**Expected Output:**
```
NVIM v0.9.0+
Python 3.8.0+
Docker version 20.0.0+
Available RAM: 8GB+
Available Space: 10GB+
```

## Understanding the Components

### 1. Ollama - Local LLM Server
- **Purpose**: Runs large language models locally
- **Models**: CodeLlama, Llama3.1, and embedding models
- **Resource Usage**: 2-8GB RAM per model
- **Speed**: 10-50 tokens/second depending on hardware

### 2. VectorCode - RAG System
- **Purpose**: Indexes your code and enables semantic search
- **Technology**: Uses embeddings to understand code meaning
- **Storage**: Creates vector database of your codebase
- **Updates**: Automatically tracks code changes

### 3. ChromaDB - Vector Database
- **Purpose**: Stores and retrieves code embeddings
- **Deployment**: Runs in Docker container
- **Performance**: Fast similarity search across millions of code chunks
- **Persistence**: Maintains embeddings between sessions

### 4. CodeCompanion - Neovim Interface
- **Purpose**: Provides chat interface within Neovim
- **Features**: Slash commands, context sharing, inline assistance
- **Integration**: Connects Neovim to Ollama and VectorCode
- **Workflow**: Seamless coding and AI assistance

## Installation Overview

The setup process involves these main steps:

1. **Install Ollama** and download required models (~30 minutes)
2. **Set up ChromaDB** vector database (~10 minutes)
3. **Install VectorCode** CLI and Python package (~15 minutes)
4. **Configure CodeCompanion** Neovim plugin (~20 minutes)
5. **Index your first project** and test the system (~15 minutes)
6. **Customize workflows** and keybindings (~30 minutes)

**Total Time**: 2-4 hours for complete setup

## Pre-Installation Checklist

Before proceeding to the next guide, ensure you have:

- [ ] **Neovim 0.9+** installed and working
- [ ] **Lazy.nvim** package manager configured
- [ ] **Python 3.8+** with pip/pipx available
- [ ] **Docker** installed and running
- [ ] **8GB+ RAM** available
- [ ] **10GB+ disk space** free
- [ ] **Internet connection** for initial downloads
- [ ] **Basic terminal/command line** familiarity

## What's Next?

In the next guide, we'll:
1. Install and configure Ollama
2. Download the required language models
3. Test the local LLM server
4. Optimize performance for your hardware

The Ollama setup is the foundation of the entire system, so we'll take time to get it right.

---

**Ready to continue?** Proceed to [02 - Setting up Ollama](02-setting-up-ollama.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for common issues.
