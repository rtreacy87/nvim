# 08 - Troubleshooting

## Common Issues and Solutions

This guide covers the most common problems you might encounter with your RAGS system and how to resolve them.

## System Health Check

### Comprehensive Health Check Script

```bash
#!/bin/bash
# Create comprehensive health check
cat > check_rags_health.sh << 'EOF'
#!/bin/bash

echo "🔍 RAGS System Health Check"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_service() {
    local service_name=$1
    local url=$2
    local expected_response=$3
    
    echo -n "Checking $service_name... "
    
    if curl -s "$url" | grep -q "$expected_response" 2>/dev/null; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

check_command() {
    local cmd_name=$1
    local cmd=$2
    
    echo -n "Checking $cmd_name... "
    
    if $cmd &>/dev/null; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# System checks
echo "🖥️  System Components:"
check_command "Neovim" "nvim --version"
check_command "Python" "python3 --version"
check_command "Docker" "docker --version"
check_command "curl" "curl --version"

echo ""
echo "🤖 AI Services:"
check_service "Ollama" "http://127.0.0.1:11434/api/tags" "models"
check_service "ChromaDB" "http://localhost:8000/api/v1/heartbeat" "heartbeat"

echo ""
echo "🔍 RAGS Components:"
check_command "VectorCode CLI" "vectorcode --version"

# Check if models are available
echo ""
echo "📦 Ollama Models:"
if ollama list 2>/dev/null | grep -q "codellama"; then
    echo -e "CodeLlama models: ${GREEN}✅ Available${NC}"
else
    echo -e "CodeLlama models: ${RED}❌ Missing${NC}"
fi

if ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
    echo -e "Embedding model: ${GREEN}✅ Available${NC}"
else
    echo -e "Embedding model: ${RED}❌ Missing${NC}"
fi

# Check VectorCode collections
echo ""
echo "📚 VectorCode Collections:"
if vectorcode list-collections 2>/dev/null | grep -q "Collection"; then
    echo -e "Collections: ${GREEN}✅ Available${NC}"
    vectorcode list-collections 2>/dev/null | grep -E "^-" | head -5
else
    echo -e "Collections: ${YELLOW}⚠️  None found${NC}"
fi

# Resource usage
echo ""
echo "💾 Resource Usage:"
echo "Memory usage:"
free -h | grep "Mem:" | awk '{print "  Total: " $2 ", Used: " $3 ", Available: " $7}'

echo "Disk usage:"
df -h ~ | tail -1 | awk '{print "  Home: " $3 " used, " $4 " available (" $5 " full)"}'

if docker ps | grep -q chromadb; then
    echo "ChromaDB container:"
    docker stats chromadb --no-stream --format "  Memory: {{.MemUsage}}, CPU: {{.CPUPerc}}"
fi

echo ""
echo "🔧 Configuration Files:"
if [ -f ~/.config/vectorcode/config.json ]; then
    echo -e "VectorCode config: ${GREEN}✅ Found${NC}"
else
    echo -e "VectorCode config: ${RED}❌ Missing${NC}"
fi

if [ -f ~/.config/nvim/lua/plugins/codecompanion.lua ]; then
    echo -e "CodeCompanion config: ${GREEN}✅ Found${NC}"
else
    echo -e "CodeCompanion config: ${RED}❌ Missing${NC}"
fi

echo ""
echo "✅ Health check complete!"
EOF

chmod +x check_rags_health.sh
./check_rags_health.sh
```

## Ollama Issues

### Problem: Ollama Not Responding

**Symptoms:**
- `curl http://127.0.0.1:11434/api/tags` returns connection refused
- CodeCompanion shows "connection error"

**Solutions:**

```bash
# Check if Ollama is running
ps aux | grep ollama

# Start Ollama if not running
ollama serve

# Check for port conflicts
lsof -i :11434

# Restart Ollama service (macOS)
launchctl stop com.ollama.ollama
launchctl start com.ollama.ollama

# Restart Ollama service (Linux)
sudo systemctl restart ollama
```

### Problem: Models Not Loading

**Symptoms:**
- "Model not found" errors
- Slow response times
- High memory usage

**Solutions:**

```bash
# Check available models
ollama list

# Download missing models
ollama pull codellama:13b
ollama pull codellama:instruct
ollama pull nomic-embed-text

# Check model status
ollama ps

# Unload unused models to free memory
ollama stop codellama:7b

# Preload frequently used models
ollama run codellama:13b ""
```

### Problem: Slow Model Performance

**Symptoms:**
- Long response times (>30 seconds)
- High CPU/memory usage
- System becomes unresponsive

**Solutions:**

```bash
# Check system resources
htop
# or
top

# Reduce concurrent models
export OLLAMA_MAX_LOADED_MODELS=1
ollama serve

# Use smaller models for simple queries
# Edit CodeCompanion config to use codellama:7b for inline completion

# Increase memory allocation (if using Docker)
docker update --memory=8g ollama-container

# Check for GPU acceleration
nvidia-smi  # For NVIDIA GPUs
```

## ChromaDB Issues

### Problem: ChromaDB Container Not Starting

**Symptoms:**
- `docker ps` doesn't show chromadb container
- Connection refused on port 8000

**Solutions:**

```bash
# Check Docker status
docker info

# Check if port is in use
lsof -i :8000

# Remove existing container and recreate
docker stop chromadb
docker rm chromadb

# Start fresh container
docker run -d \
  --name chromadb \
  -p 8000:8000 \
  -v ~/.local/share/chromadb:/chroma/chroma \
  chromadb/chroma:latest

# Check container logs
docker logs chromadb
```

### Problem: ChromaDB Data Corruption

**Symptoms:**
- "Database is locked" errors
- Inconsistent query results
- Container crashes frequently

**Solutions:**

```bash
# Stop ChromaDB
docker stop chromadb

# Backup existing data
cp -r ~/.local/share/chromadb ~/.local/share/chromadb.backup

# Clear corrupted data
rm -rf ~/.local/share/chromadb/*

# Restart ChromaDB
docker start chromadb

# Re-index your projects
vectorcode vectorise --project_root . --force
```

### Problem: High Memory Usage

**Symptoms:**
- ChromaDB container using excessive memory
- System becomes slow
- Out of memory errors

**Solutions:**

```bash
# Check memory usage
docker stats chromadb

# Limit container memory
docker update --memory=2g chromadb

# Optimize collection settings
python3 << 'EOF'
import chromadb
client = chromadb.HttpClient(host="localhost", port=8000)

for collection in client.list_collections():
    collection.modify(metadata={
        "hnsw_space": "cosine",
        "hnsw_construction_ef": 100,  # Reduced from 200
        "hnsw_search_ef": 50,         # Reduced from 100
        "hnsw_M": 8                   # Reduced from 16
    })
    print(f"Optimized {collection.name}")
EOF
```

## VectorCode Issues

### Problem: VectorCode Not Finding Files

**Symptoms:**
- "No files found to index" message
- Empty search results
- Collections show 0 documents

**Solutions:**

```bash
# Check file extensions in config
cat ~/.config/vectorcode/config.json | jq '.supported_extensions'

# Verify files exist in project
find . -name "*.py" -o -name "*.js" -o -name "*.md" | head -10

# Check ignore patterns
cat ~/.config/vectorcode/config.json | jq '.ignore_patterns'

# Force re-indexing
vectorcode vectorise --project_root . --force --verbose

# Check permissions
ls -la ~/.config/vectorcode/
```

### Problem: Embedding Connection Failed

**Symptoms:**
- "Failed to connect to embedding service"
- VectorCode queries timeout
- No embeddings generated

**Solutions:**

```bash
# Test Ollama embedding endpoint directly
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "prompt": "test"}'

# Check VectorCode configuration
vectorcode config show

# Update configuration if needed
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  }
}
EOF

# Test embeddings
vectorcode test-embeddings
```

### Problem: Slow Indexing Performance

**Symptoms:**
- Indexing takes very long time
- High CPU usage during indexing
- Process appears stuck

**Solutions:**

```bash
# Reduce chunk size for faster processing
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "chunk_size": 256,
  "chunk_overlap": 25,
  "batch_size": 10
}
EOF

# Index smaller batches
find . -name "*.py" | head -50 | xargs vectorcode add-files

# Monitor progress with verbose output
vectorcode vectorise --project_root . --verbose

# Check system resources
htop
```

## CodeCompanion Issues

### Problem: Plugin Not Loading

**Symptoms:**
- `:CodeCompanionChat` command not found
- Plugin errors in Neovim
- Slash commands not working

**Solutions:**

```bash
# Check if plugin is installed
nvim -c "lua print(pcall(require, 'codecompanion'))" -c "qa"

# Update plugins
nvim -c "Lazy sync" -c "qa"

# Check for configuration errors
nvim -c "checkhealth codecompanion" -c "qa"

# Verify dependencies
nvim -c "lua print(pcall(require, 'plenary'))" -c "qa"
nvim -c "lua print(pcall(require, 'nvim-treesitter'))" -c "qa"
```

### Problem: Slash Commands Not Working

**Symptoms:**
- `/codebase` command returns no results
- Slash commands not recognized
- Error messages in chat

**Solutions:**

```bash
# Test VectorCode CLI directly
vectorcode query "test query" --format json

# Check CodeCompanion configuration
nvim ~/.config/nvim/lua/plugins/codecompanion.lua

# Verify slash command syntax in config
# Make sure callback functions are properly defined

# Test with simple slash command
# Add this to test:
["test"] = {
  callback = function(query)
    return "Test command working with query: " .. query
  end,
  description = "Test command"
}
```

### Problem: Chat Window Not Opening

**Symptoms:**
- Keybinding doesn't work
- No chat window appears
- Error messages about window creation

**Solutions:**

```bash
# Check keybinding configuration
nvim -c "nmap <leader>cc" -c "qa"

# Try opening manually
nvim -c "CodeCompanionChat" -c "qa"

# Check window configuration
# Verify display settings in CodeCompanion config

# Reset window settings to defaults
display = {
  chat = {
    window = {
      layout = "vertical",
      width = 0.45,
      height = 0.8,
      relative = "editor",
      border = "rounded"
    }
  }
}
```

## Performance Issues

### Problem: System Running Slowly

**Symptoms:**
- High CPU/memory usage
- Neovim becomes unresponsive
- Long response times

**Solutions:**

```bash
# Check resource usage
htop
ps aux | grep -E "(ollama|vectorcode)"

# Reduce loaded models
export OLLAMA_MAX_LOADED_MODELS=1
ollama serve

# Use smaller models
# Edit CodeCompanion config to use codellama:7b as default

# Clear VectorCode cache
rm -rf ~/.cache/vectorcode/
rm -rf ~/.local/share/vectorcode/chromadb/

# Restart services
pkill ollama
ollama serve

# Re-index if needed
vectorcode init && vectorcode vectorise .
```

### Problem: Out of Disk Space

**Symptoms:**
- "No space left on device" errors
- Models fail to download
- Indexing fails

**Solutions:**

```bash
# Check disk usage
df -h
du -sh ~/.ollama/models
du -sh ~/.local/share/vectorcode/

# Clean up old models
ollama list
ollama rm unused-model-name

# Clean up old embeddings
vectorcode clean

# Move models to different location
export OLLAMA_MODELS=/path/to/larger/disk
ollama serve

# Move VectorCode data
mv ~/.local/share/vectorcode/ /path/to/larger/disk/vectorcode/
ln -s /path/to/larger/disk/vectorcode/ ~/.local/share/vectorcode
```

## Recovery Procedures

### Complete System Reset

If all else fails, here's how to reset your RAGS system:

```bash
#!/bin/bash
# Complete RAGS reset script
cat > reset_rags.sh << 'EOF'
#!/bin/bash

echo "🔄 Resetting RAGS System..."

# Stop all services
echo "Stopping services..."
pkill ollama 2>/dev/null

# Backup existing data
echo "Creating backups..."
mkdir -p ~/rags_backup/$(date +%Y%m%d_%H%M%S)
cp -r ~/.config/vectorcode ~/rags_backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null
cp -r ~/.local/share/vectorcode ~/rags_backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null

# Clean up
echo "Cleaning up..."
rm -rf ~/.local/share/vectorcode/chromadb/

# Restart services
echo "Restarting services..."
ollama serve &

# Wait for services to start
sleep 5

# Re-index current project
echo "Re-indexing current project..."
if [ -d .git ]; then
    vectorcode init
    vectorcode vectorise .
fi

echo "✅ RAGS system reset complete!"
echo "Backup saved in ~/rags_backup/"
EOF

chmod +x reset_rags.sh
```

## Getting Help

### Log Collection

When seeking help, collect these logs:

```bash
# Create log collection script
cat > collect_rags_logs.sh << 'EOF'
#!/bin/bash

LOG_DIR="rags_logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo "📋 Collecting RAGS logs..."

# System info
uname -a > "$LOG_DIR/system_info.txt"
python3 --version > "$LOG_DIR/python_info.txt" 2>&1
nvim --version > "$LOG_DIR/nvim_info.txt" 2>&1

# Service logs
ollama list > "$LOG_DIR/ollama_models.txt" 2>&1
vectorcode version > "$LOG_DIR/vectorcode_version.txt" 2>&1

# Configuration files
cp ~/.config/vectorcode/config.json "$LOG_DIR/" 2>/dev/null
cp ~/.config/nvim/lua/plugins/codecompanion.lua "$LOG_DIR/" 2>/dev/null

# Health check
vectorcode check > "$LOG_DIR/vectorcode_health.txt" 2>&1

# VectorCode info
vectorcode ls > "$LOG_DIR/vectorcode_collections.txt" 2>&1

echo "✅ Logs collected in $LOG_DIR/"
echo "Share this directory when seeking help."
EOF

chmod +x collect_rags_logs.sh
```

## What's Next?

You now have comprehensive troubleshooting tools and procedures for your RAGS system. 

In the final guide, we'll provide:
1. Complete working configuration examples
2. Best practices and optimization tips
3. Advanced customization examples
4. Community resources and support

---

**Continue to:** [09 - Complete Examples](09-complete-examples.md)

**Still having issues?** Run the health check script and log collection for detailed diagnostics.
