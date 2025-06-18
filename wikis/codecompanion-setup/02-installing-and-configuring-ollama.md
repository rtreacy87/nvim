# CodeCompanion Setup Guide - Part 2: Installing and Configuring Ollama

## What is Ollama?

Ollama is a tool that makes it easy to run large language models locally on your machine. Instead of sending your code to external AI services like OpenAI or Anthropic, Ollama lets you run models like Llama, CodeLlama, and others directly on your computer.

**Benefits of using Ollama:**
- **Privacy**: Your code never leaves your machine
- **Cost**: No API fees - run unlimited queries
- **Speed**: No network latency for requests
- **Offline**: Works without internet after initial setup

## Step 1: Installing Ollama

### Linux Installation (Recommended)

Since you're on Linux, this is the easiest method:

```bash
# Download and install Ollama
curl -fsSL https://ollama.com/install.sh | sh
```

**What this command does:**
- Downloads the official Ollama installer script
- Installs Ollama binary to `/usr/local/bin/ollama`
- Sets up the Ollama service
- Creates necessary directories

### Verifying Installation

Check if Ollama installed correctly:

```bash
# Check Ollama version
ollama --version

# Check if Ollama service is running
systemctl status ollama
```

**Expected output for version:**
```
ollama version is 0.1.33
```

**Expected output for service status:**
```
● ollama.service - Ollama Service
   Loaded: loaded (/etc/systemd/system/ollama.service; enabled; vendor preset: enabled)
   Active: active (running) since [timestamp]
```

### Starting Ollama Service

If the service isn't running:

```bash
# Start Ollama service
sudo systemctl start ollama

# Enable it to start on boot
sudo systemctl enable ollama
```

## Step 2: Downloading Your First Model

Ollama needs at least one language model to work. For coding tasks, we recommend starting with CodeLlama.

### Recommended Models for Coding:

1. **codellama:7b** - Good balance of speed and capability (4.8GB)
2. **codellama:13b** - Better performance, needs more RAM (7.3GB)
3. **llama3.1:8b** - General purpose, good for mixed tasks (4.7GB)

### Downloading CodeLlama

```bash
# Download CodeLlama 7B (this will take a few minutes)
ollama pull codellama:7b
```

**What you'll see:**
```
pulling manifest
pulling 3a43f93b78ec... 100% ▕████████████████▏ 3.8 GB
pulling 8c17c2ebb5da... 100% ▕████████████████▏ 7.0 KB
pulling 590d74a5569b... 100% ▕████████████████▏ 4.8 KB
pulling 2e0493f67d0c... 100% ▕████████████████▏   59 B
pulling 37440d7f8816... 100% ▕████████████████▏  120 B
pulling 1400016f8dbb... 100% ▕████████████████▏  529 B
verifying sha256 digest
writing manifest
removing any unused layers
success
```

### Alternative: Start with a Smaller Model

If you have limited RAM or want to test quickly:

```bash
# Download a smaller general-purpose model (3.2GB)
ollama pull llama3.2:3b
```

## Step 3: Testing Ollama

Let's verify Ollama is working correctly:

### Basic Test

```bash
# Test with a simple prompt
ollama run codellama:7b "Write a hello world function in Python"
```

**Expected output:**
```
Here's a simple Hello World function in Python:

```python
def hello_world():
    print("Hello, World!")

# Call the function
hello_world()
```

This function defines a simple `hello_world()` function that prints "Hello, World!" when called.
```

### Interactive Chat Test

```bash
# Start interactive session
ollama run codellama:7b
```

**Try these prompts:**
1. `>>> Explain what a function is in Python`
2. `>>> Write a function to calculate fibonacci numbers`
3. `>>> /bye` (to exit)

## Step 4: Configuring Ollama for CodeCompanion

### Check Available Models

```bash
# List all downloaded models
ollama list
```

**Expected output:**
```
NAME            ID              SIZE    MODIFIED
codellama:7b    8fdf8f752f6e    3.8 GB  2 minutes ago
```

### Test API Endpoint

CodeCompanion communicates with Ollama through its REST API. Let's test this:

```bash
# Test the API endpoint
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codellama:7b",
    "prompt": "Hello",
    "stream": false
  }'
```

**Expected response (abbreviated):**
```json
{
  "model": "codellama:7b",
  "created_at": "2024-01-20T10:30:00Z",
  "response": "Hello! How can I help you today?",
  "done": true
}
```

## Step 5: Optimizing Ollama Configuration

### Configuration File Location

Ollama stores its configuration in:
```
~/.ollama/
```

### Memory Management

If you have limited RAM, you can configure Ollama to use less memory:

```bash
# Check current memory usage
free -h

# If you need to limit Ollama's memory usage, create/edit:
sudo nano /etc/systemd/system/ollama.service.d/override.conf
```

**Add these lines for 4GB systems:**
```ini
[Service]
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_MAX_QUEUE=2"
```

Then restart the service:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### Port Configuration (Optional)

By default, Ollama runs on port 11434. If you need to change this:

```bash
# Stop Ollama
sudo systemctl stop ollama

# Set custom port (example: 8080)
export OLLAMA_HOST=0.0.0.0:8080

# Restart Ollama
sudo systemctl start ollama
```

## Step 6: Downloading Additional Models (Optional)

Based on your needs, you might want additional models:

### For Different Programming Languages:
```bash
# Python-focused
ollama pull codellama:7b-python

# General coding with better context
ollama pull codellama:13b
```

### For General Chat:
```bash
# Better conversational AI
ollama pull llama3.1:8b
```

### For Faster Responses:
```bash
# Smaller, faster model
ollama pull codellama:7b-instruct
```

## Troubleshooting Common Issues

### Issue 1: "ollama: command not found"

**Solution:**
```bash
# Add Ollama to PATH
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Issue 2: Service won't start

**Check logs:**
```bash
sudo journalctl -u ollama -f
```

**Common fixes:**
```bash
# Fix permissions
sudo chown -R ollama:ollama /usr/share/ollama

# Restart service
sudo systemctl restart ollama
```

### Issue 3: Out of memory errors

**Solutions:**
1. Use smaller models (3b instead of 7b)
2. Close other applications
3. Configure memory limits (shown above)

## Verification Checklist

Before proceeding to the next guide, verify:

- [ ] Ollama is installed and running
- [ ] At least one model is downloaded
- [ ] API endpoint responds to curl test
- [ ] Interactive chat works

## Next Steps

Great! You now have Ollama running locally. In the next guide, we'll:
1. Install the missing YAML parser for Tree-sitter
2. Configure CodeCompanion plugin
3. Test the integration

---

**Continue to:** [Part 3: CodeCompanion Plugin Installation](./03-codecompanion-plugin-installation.md)