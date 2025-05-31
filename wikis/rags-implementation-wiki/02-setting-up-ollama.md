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

**troubleshooting**

If you get the error "listen tcp 127.0.0.1:11434: bind: address already in use" check the following steps.
````bash
# Check what's using port 11434
lsof -i :11434
# or
netstat -tuln | grep 11434

```bash
tcp        0      0 127.0.0.1:11434         0.0.0.0:*               LISTEN
```

# If it's ollama already running, you don't need to start it again
# You can verify ollama is running with:
curl http://127.0.0.1:11434/api/tags


```bash
curl http://127.0.0.1:11434/api/tags
{"models":[]}
```

```bash
# If you need to restart ollama, first find and kill the existing process
ps aux | grep ollama
kill -9 <PID>  # Replace <PID> with the process ID from the previous command

# Then start ollama again
ollama serve
````


```bash
# In another terminal, test the installation
ollama list
```

**Expected Output:**
```bash
ollama version is 0.1.0+
Ollama is running on http://127.0.0.1:11434
NAME    ID    SIZE    MODIFIED
```

## Model Selection Strategy

Based on the RAGS design document, we'll use different models for different tasks:

| Task             | Model                | Size  | Purpose                                |
|------------------|----------------------|-------|----------------------------------------|
| Code Generation  | `codellama:13b`      | 7.3GB | High-quality code completion           |
| Code Explanation | `codellama:instruct` | 7.3GB | Instruction-following for explanations |
| General Chat     | `llama3.1:8b`        | 4.7GB | Natural conversation and planning      |
| Embeddings       | `nomic-embed-text`   | 274MB | Vector embeddings for RAG              |
| Fast Completion  | `codellama:7b`       | 3.8GB | Quick responses for simple queries     |

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
These environment variables configure Ollama's behavior:

- `OLLAMA_HOST`: Sets the server address (127.0.0.1:11434)
- `OLLAMA_MODELS`: Specifies where model files are stored
- `OLLAMA_NUM_PARALLEL`: Limits concurrent operations to 2
- `OLLAMA_MAX_LOADED_MODELS`: Caps loaded models at 3 to manage memory usage
- `OLLAMA_KEEP_ALIVE`: Keeps models in memory for 5 minutes after last use

These settings are important for optimizing performance, managing system resources, and ensuring Ollama runs efficiently without overwhelming your system's memory.


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

#### Ollama Configuration File Explained

These commands create a persistent configuration file for Ollama, which is important for several reasons:

1. **Consistent Settings**: Unlike environment variables that may be lost between sessions, a config file ensures settings persist across system reboots.

2. **Centralized Management**: All configuration options are stored in one location, making them easier to maintain.

3. **System Service Compatibility**: When running Ollama as a system service, environment variables might not be accessible, but a config file will be.

### Command Breakdown:

- `mkdir -p ~/.config/ollama`: Creates the configuration directory if it doesn't exist.

- `cat > ~/.config/ollama/config.json << 'EOF'`: Uses a "here document" to write the following text into the config file.

- Configuration options:
  - `"host"`: Defines where Ollama's API server will listen
  - `"models_path"`: Specifies the storage location for downloaded models
  - `"num_parallel"`: Limits concurrent model operations to prevent resource exhaustion
  - `"max_loaded_models"`: Controls memory usage by limiting how many models can be loaded simultaneously
  - `"keep_alive"`: Sets how long models remain in memory after last use (5 minutes)
  - `"gpu_layers"`: Controls GPU acceleration (-1 means auto-detect optimal setting)

This configuration balances performance and resource usage, preventing Ollama from consuming excessive system memory while maintaining responsive AI capabilities.


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
#### Linux Systemd Service Setup for Ollama

These commands create and configure a systemd service for Ollama, which is important for:

1. **Automatic Startup**: Ensures Ollama starts automatically when your system boots
2. **Process Management**: Handles crashes by automatically restarting the service
3. **Security**: Runs Ollama as a dedicated non-privileged user for better security
4. **Proper Dependency Handling**: Ensures Ollama starts after network is available

##### Command Breakdown:

`sudo tee /etc/systemd/system/ollama.service`: Creates a systemd service file with root permissions

The `tee` command in this context serves a specific and important purpose:

### What `tee` Does:
- `tee` reads from standard input and writes to both standard output and files simultaneously
- In this case, it's being used with `sudo` to write to a system file that requires root privileges

### Breaking Down the Command:
- `sudo tee /etc/systemd/system/ollama.service > /dev/null << 'EOF'`
  1. `sudo` - Executes the command with root privileges
  2. `tee /etc/systemd/system/ollama.service` - Writes input to the systemd service file
  3. `> /dev/null` - Redirects standard output to nowhere (suppresses screen output)
  4. `<< 'EOF'` - Uses a "here document" to provide the content between this marker and the closing EOF

### Why Use `tee` Instead of Direct Redirection:
- **Privilege Handling**: The `>` redirection operator works at the shell level before `sudo` takes effect
- If you tried `sudo echo "content" > /etc/systemd/system/ollama.service`, the redirection would happen as your user (not root), causing a permission error
- `tee` receives the content through sudo's elevated privileges, allowing it to write to protected system directories

This approach is a common pattern for safely writing to system files that require root permissions while using shell scripts.

The `ollama.service` file contains the following configuration:

- `[Unit]` section: Defines service metadata and dependencies
  - `After=network-online.target`: Ensures network is available before starting

- `[Service]` section: Configures how the service runs
  - `ExecStart=/usr/local/bin/ollama serve`: The command to start Ollama
  - `User=ollama` and `Group=ollama`: Runs as dedicated user instead of root
  - `Restart=always`: Automatically restarts if it crashes
  - `RestartSec=3`: Waits 3 seconds before restarting
  - `Environment="OLLAMA_HOST=127.0.0.1:11434"`: Sets the API endpoint

- `[Install]` section: Determines when service is started
  - `WantedBy=default.target`: Starts during normal system boot

- `sudo useradd -r -s /bin/false -m -d /usr/share/ollama ollama`: Creates a dedicated system user with:
  - No login shell (`-s /bin/false`)
  - System account (`-r`)
  - Home directory (`-m -d /usr/share/ollama`)

- Final commands enable and start the service:
  - `systemctl daemon-reload`: Reloads systemd configuration
  - `systemctl enable ollama`: Configures service to start at boot
  - `systemctl start ollama`: Starts the service immediately

**Note**

Do not be alamed if you see the following message when running the `setup-ollama-service.sh` script.  It is normal and expected.
```bash
./setup-ollama-service.sh
useradd: user 'ollama' already exists
```
The error message `useradd: user 'ollama' already exists` simply indicates that the user account for Ollama has already been created on your system, likely during a previous installation or setup process.

This is perfectly fine and won't affect the rest of the script's execution. The script will continue to:

1. Create/update the systemd service file
2. Reload the systemd configuration
3. Enable the service to start at boot
4. Start the service

Since the user already exists, it means you're just ensuring the service is properly configured for persistence across reboots. The script is doing exactly what you want - setting up Ollama to run as a system service that starts automatically when your system boots.

You can safely ignore this message and continue using the service.

### Prerequisites:
- Systemd (standard on most modern Linux distributions)
- Root/sudo access
- Ollama binary installed at `/usr/local/bin/ollama`
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

## Ollama Basic Functionality Tests Explained

These three tests verify that your Ollama installation is working correctly across all essential functions:

### 1. API Connectivity Test
```bash
curl http://127.0.0.1:11434/api/tags
```
- **Purpose**: Verifies Ollama's API server is running and responding
- **Why Important**: This is the foundation - if this fails, nothing else will work
- **Expected Result**: JSON response listing available models
- **Failure Indicates**: Ollama service isn't running or has network configuration issues

### 2. Code Generation Test
```bash
ollama run codellama:13b "def fibonacci(n):"
```
- **Purpose**: Tests if your primary code model can generate code completions
- **Why Important**: Validates that your main LLM is working properly
- **Expected Result**: A completed Python function for calculating Fibonacci numbers
- **Failure Indicates**: Model not downloaded, memory issues, or model configuration problems

### 3. Embeddings Test
```bash
curl -X POST http://127.0.0.1:11434/api/embeddings...
```
- **Purpose**: Verifies the embedding model can convert text to vector representations
- **Why Important**: Embeddings are critical for semantic search and RAG functionality
- **Expected Result**: JSON response containing vector embeddings (array of floating-point numbers)
- **Failure Indicates**: Embedding model not installed or API configuration issues

These tests validate the three core capabilities needed for a complete RAG system:
1. API connectivity (foundation)
2. Text generation (for responses)
3. Vector embeddings (for semantic search)

The output of the embedding test should be a large vector similar to what you posted. The complete response would look something like:

```json
{
  "embedding": [-0.16076038777828217, -0.02850004844367504, -3.919273614883423, 0.1904442310333252, 0.13802175223827362, 1.5940337181091309, -0.009262681007385254, -0.9820472002029419, -0.3361378312110901, -1.237851858139038, 0.0019750315696001053, 0.8872381448745728, 0.6358040571212769, 1.8510982990264893, 1.0302563905715942, -1.434023141860962, 0.2338400, ...],
  "model": "nomic-embed-text"
}
```
The embedding is a high-dimensional vector (typically 768 or 1024 dimensions) that represents the semantic meaning of your input text "Hello world" in a mathematical form. Each number in the array represents a different dimension in the embedding space.

This vector output confirms that:
1. The embedding model is properly loaded
2. The API is correctly processing requests
3. The model can generate embeddings for your RAG system

The exact values and length will depend on the specific embedding model being used, but seeing a response with a large array of floating-point numbers indicates success.

If all three tests pass, your Ollama installation is correctly configured and ready for integration with the rest of your system.

**Brief aside on the curl command**

The `curl` command is a tool for making HTTP requests from the command line. Here's a breakdown of the flags used in your example:

````bash path=wikis/rags-implementation-wiki/02-setting-up-ollama.md mode=EXCERPT
curl -X POST http://127.0.0.1:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nomic-embed-text",
    "prompt": "Hello world"
  }'
````

- `-X POST`: Specifies the HTTP method to use. POST is used to send data to the server (in this case, sending text to get embeddings).

# HTTP Methods in REST APIs

| Method  | Purpose                        | Example Use Case                                                                          | Request Body | Idempotent |
|---------|--------------------------------|-------------------------------------------------------------------------------------------|--------------|------------|
| GET     | Retrieve data                  | Fetch model list<br>`curl http://127.0.0.1:11434/api/tags`                                | No           | Yes        |
| POST    | Create resource or submit data | Generate embeddings<br>`curl -X POST http://127.0.0.1:11434/api/embeddings`               | Yes          | No         |
| PUT     | Replace/update entire resource | Update model parameters<br>`curl -X PUT http://127.0.0.1:11434/api/models/custom`         | Yes          | Yes        |
| PATCH   | Partial resource update        | Update specific model setting<br>`curl -X PATCH http://127.0.0.1:11434/api/models/custom` | Yes          | No         |
| DELETE  | Remove a resource              | Delete a custom model<br>`curl -X DELETE http://127.0.0.1:11434/api/models/custom`        | Optional     | Yes        |
| HEAD    | Get headers only (no body)     | Check if model exists<br>`curl -I http://127.0.0.1:11434/api/models/codellama`            | No           | Yes        |
| OPTIONS | Get supported methods          | Check API capabilities<br>`curl -X OPTIONS http://127.0.0.1:11434/api`                    | No           | Yes        |

**Notes:**
- **Idempotent**: Multiple identical requests have the same effect as a single request
- **Request Body**: Whether the method typically includes data in the request
- Most REST APIs primarily use GET, POST, PUT, and DELETE



- `-H "Content-Type: application/json"`: Sets an HTTP header.
  - `-H` stands for "header"
  - `Content-Type: application/json` tells the server you're sending JSON data

- `-d '{...}'`: Provides the data payload to send.
  - `-d` stands for "data"
  - The JSON object contains:
    - `model`: Which embedding model to use
    - `prompt`: The text to convert into vector embeddings

This command is sending a request to the Ollama API running on your local machine (at 127.0.0.1:11434), asking it to convert the text "Hello world" into vector embeddings using the "nomic-embed-text" model.

The REST API principles at work here are:
1. Using standard HTTP methods (POST)
2. Communicating with a specific resource endpoint (/api/embeddings)
3. Sending structured data (JSON)
4. Getting a response back in a standard format (JSON)


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
