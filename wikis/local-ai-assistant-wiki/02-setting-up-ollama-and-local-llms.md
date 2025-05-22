# Setting Up the Foundation: Ollama and Local LLMs

The foundation of our local AI coding assistant is a well-configured local Large Language Model (LLM) system. In this guide, we'll set up Ollama, a powerful tool for running LLMs locally, and select appropriate code-focused models for our assistant.

## Understanding Ollama

Ollama is an open-source tool that simplifies running LLMs locally. It provides:

- Easy installation and setup
- A simple API for interacting with models
- Efficient model management
- Support for various model architectures
- GPU acceleration when available

## Installing Ollama

### On macOS

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
ollama --version
```

### On Linux

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
ollama --version
```

### On Windows

1. Download the installer from [Ollama's website](https://ollama.com/download/windows)
2. Run the installer and follow the prompts
3. Open Command Prompt or PowerShell and verify the installation:
   ```
   ollama --version
   ```

## Starting the Ollama Service

Ollama runs as a service that needs to be started:

```bash
# Start Ollama service
ollama serve
```

This command starts the Ollama server, which listens on `localhost:11434` by default. Keep this terminal window open, or run Ollama as a background service.

## Selecting Code-Focused LLMs

For our AI coding assistant, we need models that excel at understanding and generating code. Here are some recommended models:

### Recommended Models for Different Hardware Configurations

| Hardware | Recommended Models |
|----------|-------------------|
| CPU only (8GB+ RAM) | phi-3-mini-4k-instruct, starcoder2-3b, codellama-7b-instruct |
| CPU only (16GB+ RAM) | phi-3-small-8k-instruct, starcoder2-7b, codellama-7b-instruct |
| GPU with 8GB VRAM | codellama-13b-instruct, starcoder2-15b, qwen2.5-coder-7b |
| GPU with 16GB+ VRAM | codellama-34b-instruct, qwen2.5-coder-32b, mixtral-8x7b-instruct |

### Model Comparison

| Model | Size | Strengths | Limitations |
|-------|------|-----------|-------------|
| CodeLlama | 7B-34B | Strong code generation, multiple languages | Larger sizes need significant resources |
| Starcoder2 | 3B-15B | Specialized for code, efficient | Less general knowledge than some alternatives |
| Phi-3 | 3.8B-14B | Excellent performance for size, efficient | Limited context window in smaller versions |
| Qwen2.5-Coder | 7B-32B | Strong code understanding, multilingual | Larger sizes need significant resources |
| Mixtral | 8x7B | Good all-around performance | Not code-specialized but still capable |

## Installing Models with Ollama

To install a model with Ollama, use the `pull` command:

```bash
# Pull a model (examples)
ollama pull codellama:7b-instruct
ollama pull phi3:mini-4k-instruct
ollama pull starcoder2:3b
```

You can install multiple models and switch between them based on your needs.

## Testing Your Models

Let's test the installed models with some basic coding tasks:

```bash
# Test with a simple coding prompt
ollama run codellama:7b-instruct "Write a Python function to calculate the Fibonacci sequence up to n terms."
```

Try different prompts to test the model's capabilities:

- "Explain how a binary search tree works"
- "Write a JavaScript function to sort an array of objects by a property"
- "Debug this code: [paste problematic code]"

## Optimizing Models for Your Hardware

### CPU Optimization

If you're running on CPU only:

```bash
# Set environment variables for better CPU performance
export OMP_NUM_THREADS=4  # Adjust based on your CPU cores
export OPENBLAS_NUM_THREADS=4
```

### GPU Optimization

If you have a compatible NVIDIA GPU:

```bash
# Check if Ollama is using your GPU
ollama run codellama:7b-instruct "Hello" --verbose
```

You should see GPU-related information in the output. If not, ensure your NVIDIA drivers and CUDA are properly installed.

## Creating a Custom Modelfile

Ollama allows you to create custom configurations for models using Modelfiles. This is useful for optimizing models for code completion:

```
FROM codellama:7b-instruct

# Set a system prompt for code-focused interactions
SYSTEM """
You are an AI coding assistant. Your primary goal is to help with programming tasks by providing clear, concise, and correct code. Focus on writing efficient, readable code that follows best practices for the language in question. Provide explanations when helpful.
"""

# Set parameters for better code generation
PARAMETER temperature 0.1
PARAMETER top_p 0.95
```

Save this as `Modelfile` and create your custom model:

```bash
ollama create code-assistant -f Modelfile
```

Now you can run your custom model:

```bash
ollama run code-assistant "Write a function to check if a string is a palindrome"
```

### Automating Model Setup with PowerShell

For Windows users, we've created a PowerShell script that automates the process of setting up your custom code assistant model. The script performs the following steps:

1. Checks if Ollama is installed
2. Creates the Modelfile with optimized settings
3. Removes any existing model with the same name
4. Creates the custom model
5. Tests it with a simple prompt
6. Provides usage instructions

Save the following script as `setup-code-assistant.ps1`:

```powershell
# setup-code-assistant.ps1
# This script creates a custom code-focused LLM using Ollama

# Check if Ollama is installed
try {
    $ollamaVersion = ollama --version
    Write-Host "Found Ollama: $ollamaVersion" -ForegroundColor Green
} catch {
    Write-Host "Ollama not found. Please install Ollama first: https://ollama.com/download" -ForegroundColor Red
    exit 1
}

# Create the Modelfile
$modelfileContent = @"
FROM codellama:7b-instruct

# Set a system prompt for code-focused interactions
SYSTEM """
You are an AI coding assistant. Your primary goal is to help with programming tasks by providing clear, concise, and correct code. Focus on writing efficient, readable code that follows best practices for the language in question. Provide explanations when helpful.
"""

# Set parameters for better code generation
PARAMETER temperature 0.1
PARAMETER top_p 0.95
"@

# Write the Modelfile
$modelfileContent | Out-File -FilePath .\Modelfile -Encoding ascii
Write-Host "Created Modelfile" -ForegroundColor Green

# Check if the model already exists and remove it if it does
$modelExists = ollama list | Select-String "code-assistant"
if ($modelExists) {
    Write-Host "Removing existing code-assistant model..." -ForegroundColor Yellow
    ollama rm code-assistant
}

# Create the custom model
Write-Host "Creating custom code-assistant model..." -ForegroundColor Cyan
ollama create code-assistant -f Modelfile

# Test the model
Write-Host "`nTesting the model with a simple prompt..." -ForegroundColor Cyan
Write-Host "Prompt: Write a function to check if a string is a palindrome`n" -ForegroundColor Gray
ollama run code-assistant "Write a function to check if a string is a palindrome"

Write-Host "`nSetup complete! You can now use your code assistant with:" -ForegroundColor Green
Write-Host "ollama run code-assistant 'your coding question here'" -ForegroundColor Cyan
```

To run the script:

1. Open PowerShell
2. Navigate to the directory containing the script
3. Run: `.\setup-code-assistant.ps1`

This script makes it easy to set up your custom code assistant model with optimal settings for code generation.

## Setting Up the Ollama API

Our AI coding assistant will interact with Ollama through its API. Let's test the API with a simple Python script:

```python
# Save as test_ollama.py
import requests
import json

def query_ollama(prompt, model="code-assistant"):
    """Send a prompt to Ollama and get the response."""
    url = "http://localhost:11434/api/generate"
    data = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }

    response = requests.post(url, json=data)
    return response.json()["response"]

# Test with a simple coding prompt
prompt = "Write a Python function to check if a number is prime."
response = query_ollama(prompt)
print(response)
```

Run the script to test the API:

```bash
python test_ollama.py
```

## Managing Multiple Models

For our AI coding assistant, we'll use different models for different tasks:

1. **Fast Completion Model**: A smaller model for real-time code completions
2. **Comprehensive Chat Model**: A larger model for in-depth code explanations
3. **Embedding Model**: A specialized model for creating code embeddings

You can switch between models based on the task:

```python
# For quick completions
completion_response = query_ollama("Complete this code: def fibonacci(n):", "phi3:mini-4k-instruct")

# For detailed explanations
explanation_response = query_ollama("Explain how async/await works in JavaScript:", "codellama:13b-instruct")
```

## Troubleshooting Common Issues

### Model Downloads Failing

If model downloads fail:

```bash
# Check your internet connection
# Try with a smaller model first
ollama pull phi3:mini-4k-instruct

# Check disk space
df -h
```

### Out of Memory Errors

If you encounter out of memory errors:

```bash
# Try a smaller model
# Close other applications
# Add swap space (Linux)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Slow Performance

If performance is slow:

```bash
# Check if GPU is being used (for NVIDIA GPUs)
nvidia-smi

# Try models with smaller parameter counts
# Reduce context length in your prompts
```

## Next Steps

Now that you have Ollama set up with appropriate code-focused LLMs, the next step is to build a code understanding system that will allow our AI assistant to comprehend your codebase.

Continue to [Building a Code Understanding System](03-building-code-understanding.md).

