# 02 - Setting up Ollama

## What is Ollama?

Ollama is a local LLM (Large Language Model) server that runs AI models directly on your machine. It provides:

- **Local inference** - No data leaves your computer
- **Multiple model support** - Switch between different AI models
- **REST API** - Easy integration with other tools
- **Model management** - Download, update, and manage models
- **Resource optimization** - Efficient memory and GPU usage

## Installation

### macOS Installation

```bash
# Option 1: Download from website
# Visit https://ollama.ai and download the macOS installer

# Option 2: Using Homebrew
brew install ollama
```

### Linux Installation

```bash
# Download and install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Or manually download
curl -L https://ollama.ai/download/ollama-linux-amd64 -o ollama
chmod +x ollama
sudo mv ollama /usr/local/bin/
```

### Windows Installation

```bash
# Download from https://ollama.ai
# Or use WSL2 with Linux instructions above
```

### Verify Installation

```bash
# Check if Ollama is installed
ollama --version

# Start Ollama service
ollama serve

# In another terminal, test the installation
ollama list
```

**Expected Output:**
```
ollama version is 0.1.0+
Ollama is running on http://127.0.0.1:11434
NAME    ID    SIZE    MODIFIED
```

## Model Selection Strategy

Based on the RAGS design document, we'll use different models for different tasks:

| Task | Model | Size | Purpose |
|------|-------|------|---------|
| Code Generation | `codellama:13b` | 7.3GB | High-quality code completion |
| Code Explanation | `codellama:instruct` | 7.3GB | Instruction-following for explanations |
| General Chat | `llama3.1:8b` | 4.7GB | Natural conversation and planning |
| Embeddings | `nomic-embed-text` | 274MB | Vector embeddings for RAG |
| Fast Completion | `codellama:7b` | 3.8GB | Quick responses for simple queries |

## Downloading Models

### Essential Models (Required)

```bash
# Download core models for RAGS system
ollama pull codellama:13b      # Primary code model (7.3GB)
ollama pull codellama:instruct # Code explanations (7.3GB)
ollama pull nomic-embed-text   # Embeddings (274MB)
```

### Optional Models (Recommended)

```bash
# Additional models for enhanced experience
ollama pull codellama:7b       # Faster responses (3.8GB)
ollama pull llama3.1:8b        # General chat (4.7GB)
```

### Monitor Download Progress

```bash
# Check download status
ollama list

# Test a model
ollama run codellama:13b "Write a hello world function in Python"
```

## Configuration

### Environment Variables

Create or edit your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Ollama configuration
export OLLAMA_HOST=127.0.0.1:11434
export OLLAMA_MODELS=~/.ollama/models
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=3
export OLLAMA_KEEP_ALIVE=5m
```

### Advanced Configuration

For better performance, create a configuration file:

```bash
# Create Ollama config directory
mkdir -p ~/.config/ollama

# Create configuration file
cat > ~/.config/ollama/config.json << 'EOF'
{
  "host": "127.0.0.1:11434",
  "models_path": "~/.ollama/models",
  "num_parallel": 2,
  "max_loaded_models": 3,
  "keep_alive": "5m",
  "gpu_layers": -1
}
EOF
```

### System Service Setup

#### macOS (using launchd)

```bash
# Create service file
cat > ~/Library/LaunchAgents/com.ollama.ollama.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.ollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Load and start service
launchctl load ~/Library/LaunchAgents/com.ollama.ollama.plist
launchctl start com.ollama.ollama
```

#### Linux (using systemd)

```bash
# Create systemd service
sudo tee /etc/systemd/system/ollama.service > /dev/null << 'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=127.0.0.1:11434"

[Install]
WantedBy=default.target
EOF

# Create ollama user
sudo useradd -r -s /bin/false -m -d /usr/share/ollama ollama

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

## Testing Your Setup

### Basic Functionality Test

```bash
# Test if Ollama is running
curl http://127.0.0.1:11434/api/tags

# Test code generation
ollama run codellama:13b "def fibonacci(n):"

# Test embeddings
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nomic-embed-text",
    "prompt": "Hello world"
  }'
```

### Performance Test

Create a test script to measure performance:

```bash
# Create performance test script
cat > test_ollama_performance.py << 'EOF'
#!/usr/bin/env python3
import requests
import time
import json

def test_ollama_performance():
    url = "http://127.0.0.1:11434/api/generate"
    
    # Test prompt
    prompt = "Write a Python function to calculate factorial"
    
    payload = {
        "model": "codellama:13b",
        "prompt": prompt,
        "stream": False
    }
    
    print("Testing Ollama performance...")
    start_time = time.time()
    
    try:
        response = requests.post(url, json=payload, timeout=60)
        end_time = time.time()
        
        if response.status_code == 200:
            result = response.json()
            duration = end_time - start_time
            response_length = len(result.get('response', ''))
            tokens_per_second = response_length / duration if duration > 0 else 0
            
            print(f"✅ Success!")
            print(f"⏱️  Duration: {duration:.2f} seconds")
            print(f"📝 Response length: {response_length} characters")
            print(f"🚀 Speed: ~{tokens_per_second:.1f} chars/second")
            print(f"📊 Model: {result.get('model', 'unknown')}")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
    
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection error: {e}")
        print("Make sure Ollama is running: ollama serve")

if __name__ == "__main__":
    test_ollama_performance()
EOF

# Run the test
python3 test_ollama_performance.py
```

**Expected Output:**
```
Testing Ollama performance...
✅ Success!
⏱️  Duration: 3.45 seconds
📝 Response length: 234 characters
🚀 Speed: ~67.8 chars/second
📊 Model: codellama:13b
```

## Optimization Tips

### Memory Management

```bash
# Check memory usage
ollama ps

# Unload unused models
ollama stop codellama:7b

# Preload frequently used models
ollama run codellama:13b ""
```

### GPU Acceleration (if available)

```bash
# Check GPU support
nvidia-smi  # For NVIDIA GPUs

# Configure GPU layers in model
ollama run codellama:13b --gpu-layers 35
```

## Troubleshooting

### Common Issues

**Issue**: "Connection refused" error
```bash
# Solution: Start Ollama service
ollama serve
```

**Issue**: Models download slowly
```bash
# Solution: Check internet connection and disk space
df -h
speedtest-cli
```

**Issue**: High memory usage
```bash
# Solution: Reduce loaded models
export OLLAMA_MAX_LOADED_MODELS=1
ollama serve
```

### Health Check Script

```bash
# Create health check script
cat > check_ollama_health.sh << 'EOF'
#!/bin/bash

echo "🔍 Checking Ollama Health..."

# Check if service is running
if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama service is running"
else
    echo "❌ Ollama service is not responding"
    exit 1
fi

# Check available models
echo "📋 Available models:"
ollama list

# Check system resources
echo "💾 Memory usage:"
ps aux | grep ollama | grep -v grep

echo "✅ Health check complete!"
EOF

chmod +x check_ollama_health.sh
./check_ollama_health.sh
```

## What's Next?

Now that Ollama is running with the required models, we'll set up VectorCode to index your codebase and enable semantic search.

In the next guide, we'll:
1. Install VectorCode CLI and Python package
2. Configure the embedding system
3. Index your first project
4. Test semantic code search

---

**Continue to:** [03 - Setting up VectorCode](03-setting-up-vectorcode.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for Ollama-specific issues.
