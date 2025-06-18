# CodeCompanion Setup Guide - Part 1: Prerequisites and Dependencies

## Overview
This guide will walk you through setting up CodeCompanion with Ollama for local AI assistance in Neovim. CodeCompanion is a powerful plugin that brings AI chat capabilities directly into your editor, and when paired with Ollama, you can run everything locally without sending your code to external services.

## What You'll Need

### 1. System Requirements
- **Operating System**: Linux (Ubuntu/Debian recommended), macOS, or Windows with WSL2
- **Memory**: At least 8GB RAM (16GB+ recommended for larger models)
- **Storage**: 10GB+ free space for Ollama models
- **Internet**: Required for initial downloads

### 2. Software Prerequisites

#### Neovim (Version 0.9.0 or higher)
CodeCompanion requires a modern version of Neovim. Check your version:

```bash
nvim --version
```

**Expected Output:**
```
NVIM v0.12.0
Build type: Release
LuaJIT 2.1.1713484068
```

**If you need to install/upgrade Neovim:**
- **Linux (Ubuntu/Debian)**: 
  ```bash
  sudo apt update
  sudo apt install neovim
  ```
- **macOS**: 
  ```bash
  brew install neovim
  ```
- **Windows**: Download from [GitHub releases](https://github.com/neovim/neovim/releases)

#### Git (for cloning repositories)
Check if Git is installed:
```bash
git --version
```

**If not installed:**
- **Linux**: `sudo apt install git`
- **macOS**: `brew install git`
- **Windows**: Download from [git-scm.com](https://git-scm.com)

#### curl (for API requests)
Check if curl is installed:
```bash
curl --version
```

**If not installed:**
- **Linux**: `sudo apt install curl`
- **macOS**: Usually pre-installed
- **Windows**: Usually available in modern versions

### 3. Required Neovim Plugins

CodeCompanion depends on several Neovim plugins. Here's what each one does:

#### Core Dependencies:
1. **plenary.nvim** - Utility functions for Lua plugins
2. **nvim-treesitter** - Syntax highlighting and code parsing
3. **dressing.nvim** - Better UI for input dialogs

#### Tree-sitter Parsers:
Tree-sitter parsers are essential for CodeCompanion to understand your code structure. You'll need:

- **markdown parser** - For chat formatting
- **yaml parser** - For configuration files ⚠️ **This is currently missing in your setup**

### 4. Checking Your Current Status

Based on your diagnostic output, here's your current status:

✅ **Working:**
- Neovim version: 0.12.0 ✓
- plenary.nvim installed ✓
- nvim-treesitter installed ✓
- curl installed ✓
- base64 installed ✓
- markdown parser installed ✓

⚠️ **Needs Attention:**
- yaml parser not found (we'll fix this)
- rg (ripgrep) not found (optional but recommended)

❌ **Issues:**
- YAML file errors (likely due to missing yaml parser)

## Next Steps

In the next guide, we'll:
1. Install and configure Ollama
2. Download AI models
3. Test the Ollama installation

## Quick Pre-flight Check

Before proceeding, run these commands to verify your setup:

```bash
# Check Neovim version (should be 0.9.0+)
nvim --version | head -1

# Check if you have a plugin manager (Lazy.nvim recommended)
ls ~/.config/nvim/lua/

# Check current working directory for this guide
pwd
```

**Expected working directory:** `/home/ryan/.config/nvim`

## Understanding the Setup Process

Here's what we'll accomplish across all guides:

1. **Part 1** (This guide) - Prerequisites and dependencies ✓
2. **Part 2** - Installing and configuring Ollama
3. **Part 3** - CodeCompanion plugin installation and tree-sitter setup
4. **Part 4** - Configuration and integration
5. **Part 5** - Troubleshooting common issues

Each step builds on the previous one, so it's important to complete them in order.

---

**Ready for the next step?** Continue to [Part 2: Installing and Configuring Ollama](./02-installing-and-configuring-ollama.md)