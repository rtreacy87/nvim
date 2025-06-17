# VectorCode Troubleshooting Guide

## Overview

This guide helps you fix common VectorCode issues, especially when the integration test shows "VectorCode functionality is not working." This guide is written for beginners with minimal coding experience.

## Quick Problem Identification

When you run `./test_codecompanion_integration.sh` and see:
- ✅ VectorCode CLI is working
- ❌ VectorCode functionality is not working  
- ❌ VectorCode queries are failing

This means VectorCode is installed but can't connect to its database properly.

## Step-by-Step Fix Process

### Step 1: Check Your Current Setup

First, let's see what's happening:

```bash
# Check if you're in the right place
pwd
# Should show: /home/ryan

# Check VectorCode installation and version
pip show vectorcode
# Should show version info like: Version: 0.6.12

# Check VectorCode help to see available commands
vectorcode --help
# Shows all available commands

# Check what VectorCode thinks is wrong
vectorcode check config
# This will verify your project configuration

# List any existing collections
vectorcode ls
# Shows if VectorCode database is working
```

**What you might see:**
- ❌ "No project found" (need to run `vectorcode init`)
- ❌ "No collections found" (no files indexed yet)
- ❌ "ChromaDB connection error" (database issues)

### Step 2: Create the Missing Test Directory

The test script expects a directory that doesn't exist. Let's create it:

```bash
# Create the test directory the script is looking for
mkdir -p ~/test-vectorcode

# Go into that directory
cd ~/test-vectorcode

# Create some test files for VectorCode to work with
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

# Initialize VectorCode in this directory
vectorcode init

# Add the files to VectorCode
vectorcode vectorise *.py

# Test that it's working
vectorcode query "fibonacci"
```

### Step 3: Fix Database Connection Issues

If `vectorcode check` still fails, try these fixes:

#### Fix 1: Reset VectorCode Database

```bash
# Go to your home directory
cd ~

# Remove any existing VectorCode data
rm -rf ~/.local/share/vectorcode/

# Remove any old ChromaDB data
rm -rf ~/.chroma/

# Re-initialize VectorCode
vectorcode init

# Verify it's working
vectorcode check config
```

#### Fix 2: Check Virtual Environment Issues

If you're using a virtual environment (which you are, based on `((venv))`), make sure VectorCode is properly installed:

```bash
# Make sure you're in your virtual environment
source ~/venv/bin/activate

# Check if VectorCode is installed in the virtual environment
which vectorcode
# Should show: /home/ryan/venv/bin/vectorcode

# If not found, reinstall VectorCode in the virtual environment
pip install vectorcode

# Verify installation
pip show vectorcode
```

#### Fix 3: Manual ChromaDB Fix

If VectorCode can't start its database automatically:

```bash
# Install ChromaDB manually
pip install chromadb

# Try starting VectorCode again
vectorcode check config

# If it still fails, try forcing a clean start
vectorcode init --force
```

### Step 4: Test the Complete Setup

Now let's test everything step by step:

```bash
# Make sure you're in the test directory
cd ~/test-vectorcode

# Test 1: Check VectorCode CLI
echo "Testing VectorCode CLI..."
pip show vectorcode > /dev/null && echo "✅ CLI installed" || echo "❌ CLI not installed"

# Test 2: Check VectorCode functionality  
echo "Testing VectorCode functionality..."
vectorcode check config > /dev/null 2>&1 && echo "✅ Functionality working" || echo "❌ Functionality failed"

# Test 3: Test file indexing
echo "Testing file indexing..."
vectorcode vectorise *.py && echo "✅ Indexing working" || echo "❌ Indexing failed"

# Test 4: Test querying
echo "Testing queries..."
vectorcode query "fibonacci" && echo "✅ Queries working" || echo "❌ Queries failed"

# Test 5: Test structured output (needed for CodeCompanion)
echo "Testing structured output..."
vectorcode query "fibonacci" --pipe > /tmp/test_output.json 2>/dev/null
if [ -s /tmp/test_output.json ]; then
    echo "✅ Structured output working"
    echo "Sample output:"
    head -3 /tmp/test_output.json
else
    echo "❌ Structured output failed"
    echo "💡 This is needed for CodeCompanion integration"
fi
```

### Step 5: Fix ChromaDB Port Conflicts

If you see errors about port conflicts:

```bash
# Check if something is using the default ChromaDB port
netstat -tlnp | grep 8000

# If something is using port 8000, kill it or use a different port
# Method 1: Kill the process using port 8000
sudo lsof -ti:8000 | xargs kill -9

# Method 2: Configure VectorCode to use a different port
mkdir -p ~/.config/vectorcode
cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "db_url": "http://127.0.0.1:8001",
  "embedding_function": "SentenceTransformerEmbeddingFunction",
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
EOF

# Try again
vectorcode check
```

### Step 6: Create a Fixed Test Script

Let's create a better version of the test script that won't fail:

```bash
# Create an improved test script
cat > ~/test_codecompanion_integration_fixed.sh << 'EOF'
#!/bin/bash

echo "🔍 Testing CodeCompanion + RAGS Integration (Fixed Version)..."
echo "================================================================"

# Function to check if a command succeeded
check_command() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ $1"
        return 1
    fi
}

# Test 1: Check Neovim version
echo "📋 Checking Neovim version..."
nvim --version | head -1
check_command "Neovim available"

# Test 2: Check plugin loading
echo -e "\n📦 Testing plugin loading..."
nvim --headless -c "lua 
local function check_plugin(name, module)
  local ok, _ = pcall(require, module)
  print(name .. ': ' .. (ok and '✅ loaded' or '❌ failed'))
end

check_plugin('CodeCompanion', 'codecompanion')
check_plugin('VectorCode', 'vectorcode')
check_plugin('Plenary', 'plenary')
check_plugin('Treesitter', 'nvim-treesitter')
" -c "qa" 2>/dev/null

# Test 3: Check Ollama
echo -e "\n🤖 Testing Ollama status..."
if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama is running"
    echo "📊 Available models:"
    ollama list | grep -E "(llama|codellama)" | head -3
else
    echo "❌ Ollama is not responding"
    echo "💡 Try running: ollama serve"
fi

# Test 4: Check VectorCode CLI
echo -e "\n🔍 Testing VectorCode CLI..."
if command -v vectorcode > /dev/null; then
    echo "✅ VectorCode CLI available"
    VERSION=$(pip show vectorcode 2>/dev/null | grep Version | cut -d' ' -f2)
    echo "📋 Version: ${VERSION:-'Unknown'}"
else
    echo "❌ VectorCode CLI not found"
    echo "💡 Try running: pip install vectorcode"
fi

# Test 5: Check VectorCode functionality
echo -e "\n🗄️  Testing VectorCode functionality..."
if vectorcode check config > /dev/null 2>&1; then
    echo "✅ VectorCode functionality working"
else
    echo "❌ VectorCode functionality issues"
    echo "💡 Try the fixes in the troubleshooting guide"
    echo "🔧 Quick fix attempt..."
    
    # Try to fix common issues
    vectorcode init > /dev/null 2>&1
    if vectorcode check config > /dev/null 2>&1; then
        echo "✅ Fixed! VectorCode now working"
    else
        echo "❌ Still not working - see troubleshooting guide"
    fi
fi

# Test 6: Test VectorCode with actual files
echo -e "\n💻 Testing VectorCode with test files..."

# Create test directory if it doesn't exist
TEST_DIR="$HOME/test-vectorcode"
if [ ! -d "$TEST_DIR" ]; then
    echo "📁 Creating test directory..."
    mkdir -p "$TEST_DIR"
    
    # Create test files
    cat > "$TEST_DIR/test.py" << 'PYEOF'
def hello_world():
    """A simple hello world function."""
    print("Hello, World!")

def fibonacci(n):
    """Calculate fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
PYEOF
    
    echo "📝 Created test files"
fi

# Test indexing and querying
cd "$TEST_DIR"
echo "📍 Working in: $(pwd)"

if vectorcode init > /dev/null 2>&1; then
    echo "✅ VectorCode initialized"
    
    if vectorcode vectorise *.py > /dev/null 2>&1; then
        echo "✅ Files indexed successfully"
        
        # Test basic query
        if vectorcode query "hello" > /dev/null 2>&1; then
            echo "✅ Basic queries working"
            
            # Test structured query (needed for CodeCompanion)
            if vectorcode query "hello" --pipe > /dev/null 2>&1; then
                echo "✅ Structured queries working (CodeCompanion ready)"
            else
                echo "❌ Structured queries failing"
            fi
        else
            echo "❌ Basic queries failing"
        fi
    else
        echo "❌ File indexing failed"
    fi
else
    echo "❌ VectorCode initialization failed"
fi

# Test 7: Check ChromaDB
echo -e "\n🗄️  Testing ChromaDB status..."
if curl -s http://localhost:8000/api/v1/heartbeat > /dev/null 2>&1; then
    echo "✅ ChromaDB server running"
elif curl -s http://127.0.0.1:8001/api/v1/heartbeat > /dev/null 2>&1; then
    echo "✅ ChromaDB server running (alternative port)"
else
    echo "ℹ️  ChromaDB server not running (VectorCode uses bundled version)"
fi

echo -e "\n✅ Integration test complete!"
echo "📚 If any tests failed, check the troubleshooting guide at:"
echo "    wikis/rags-implementation-wiki/06-vectorcode-troubleshooting-guide.md"
EOF

chmod +x ~/test_codecompanion_integration_fixed.sh

echo "✅ Created fixed test script: ~/test_codecompanion_integration_fixed.sh"
echo "🚀 Run it with: ./test_codecompanion_integration_fixed.sh"
```

### Step 7: Run the Fixed Test

```bash
# Run the improved test script
cd ~
./test_codecompanion_integration_fixed.sh
```

## Common Error Messages and Solutions

### Error: "ChromaDB connection failed"

**Cause**: VectorCode can't connect to its database  
**Solution**:
```bash
# Delete old database and start fresh
rm -rf ~/.local/share/vectorcode/
vectorcode init
vectorcode check
```

### Error: "Collection not found"

**Cause**: No files have been indexed yet  
**Solution**:
```bash
# Make sure you're in a directory with code files
cd ~/test-vectorcode
vectorcode vectorise *.py
vectorcode query "test"
```

### Error: "No such file or directory"

**Cause**: Test directory doesn't exist  
**Solution**:
```bash
# Create the missing directory
mkdir -p ~/test-vectorcode
cd ~/test-vectorcode
# Create test files (see Step 2 above)
```

### Error: "Permission denied"

**Cause**: VectorCode can't write to its data directory  
**Solution**:
```bash
# Fix permissions
chmod -R 755 ~/.local/share/
mkdir -p ~/.local/share/vectorcode/
vectorcode init
```

### Error: "Port already in use"

**Cause**: Another process is using ChromaDB's port  
**Solution**:
```bash
# Find what's using the port
sudo lsof -i :8000

# Kill the process (replace XXXX with actual PID)
kill XXXX

# Or configure VectorCode to use a different port (see Step 5)
```

## Verification Checklist

After following this guide, you should be able to run these commands successfully:

```bash
# ✅ These should all work:
pip show vectorcode              # Shows version information
vectorcode --help               # Shows available commands
vectorcode check config         # Verifies project configuration
vectorcode ls                   # Lists collections (may be empty initially)
vectorcode init                 # Creates .vectorcode directory
vectorcode vectorise *.py       # Indexes Python files
vectorcode query "test"         # Returns search results
vectorcode query "test" --pipe  # Returns structured JSON results
```

## When to Ask for Help

If after following this guide you still see:
- ❌ VectorCode functionality is not working
- Errors that aren't covered in this guide
- The fixed test script still fails

Then provide these details when asking for help:

```bash
# Run these commands and share the output:
echo "=== System Info ==="
uname -a
python3 --version
pip list | grep vectorcode

echo "=== VectorCode Status ==="
pip show vectorcode
vectorcode check config

echo "=== Virtual Environment ==="
which python
which vectorcode
echo $VIRTUAL_ENV

echo "=== Directory Status ==="
pwd
ls -la
ls -la ~/.local/share/vectorcode/ 2>/dev/null || echo "No vectorcode data directory"
```

This information will help diagnose any remaining issues.

## Success! What's Next?

Once VectorCode is working properly:

1. **Test CodeCompanion Integration**: Try using `/codebase` commands in CodeCompanion
2. **Index Your Real Projects**: Run `vectorcode init` and `vectorcode vectorise .` in your actual code projects  
3. **Explore Advanced Features**: Check out the other guides in the wiki for more advanced setups

Remember: VectorCode needs to be working properly for CodeCompanion's RAG features to function. Once you see ✅ for all tests, you're ready to use the full RAGS system!
