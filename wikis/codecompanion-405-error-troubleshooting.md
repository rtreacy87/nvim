# CodeCompanion 405 Method Not Allowed Error Troubleshooting

## Understanding the 405 Error

A **405 Method Not Allowed** error indicates that CodeCompanion is successfully connecting to an API endpoint, but using the wrong HTTP method (GET, POST, PUT, etc.) or the endpoint doesn't support the method being used.

## Common Causes and Solutions

### 1. Incorrect API Provider Configuration

#### Check Your Current Provider
```vim
:lua print(vim.inspect(require('codecompanion.config').adapters))
" Shows configured adapters and their settings
```

#### Common Provider Issues
- **OpenAI**: Using wrong endpoint URL
- **Anthropic**: Incorrect API base URL
- **Ollama**: Wrong port or endpoint configuration
- **Local models**: Misconfigured server endpoints

### 2. API Key and Authentication Issues

#### Verify API Key Setup
```vim
:lua print(os.getenv("OPENAI_API_KEY"))
" Should show your API key (or nil if not set)

:lua print(os.getenv("ANTHROPIC_API_KEY"))
" For Anthropic Claude

:lua print(os.getenv("OLLAMA_HOST"))
" For Ollama local setup
```

#### Check Environment Variables
```bash
# In terminal, verify your API keys are set:
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY
echo $OLLAMA_HOST
```

### 3. CodeCompanion Configuration Issues

#### Based on Your Configuration
You're using **Ollama with CodeLlama models**. Your config shows:
- URL: `http://127.0.0.1:11434`
- Chat model: `codellama:13b`
- Inline model: `codellama:7b`

### 4. Ollama-Specific Troubleshooting

#### Check Ollama Server Status
```bash
# Verify Ollama is running
curl http://127.0.0.1:11434/api/tags
# Should return JSON with available models

# Check if Ollama service is active
ps aux | grep ollama
# Should show ollama process running

# Start Ollama if not running
ollama serve &
```

#### Verify Models Are Available
```bash
# List available models
ollama list
# Should show codellama:13b and codellama:7b

# Pull missing models if needed
ollama pull codellama:13b
ollama pull codellama:7b
```

#### Test Ollama API Directly
```bash
# Test the exact endpoint CodeCompanion uses
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codellama:13b",
    "prompt": "Hello",
    "stream": false
  }'
```

If this returns a 405 error, the issue is with Ollama configuration, not CodeCompanion.

### 5. API Endpoint Issues

#### Check Ollama API Version
```bash
# Verify Ollama version
ollama --version

# Different Ollama versions use different endpoints:
# Older: /api/generate
# Newer: /api/chat or /v1/chat/completions
```

#### Update Ollama Configuration
If you have a newer Ollama version, you may need to update your CodeCompanion config:

```lua
-- In your codecompanion.lua, try updating the URL:
url = 'http://127.0.0.1:11434/v1/chat/completions',
-- or
url = 'http://127.0.0.1:11434/api/chat',
```

### 6. Network and Port Issues

#### Check Port Availability
```bash
# Verify port 11434 is accessible
netstat -tulpn | grep 11434
# Should show Ollama listening on port 11434

# Test connectivity
telnet 127.0.0.1 11434
```

#### Firewall Issues
```bash
# Check if firewall is blocking the port
sudo ufw status
# Ensure port 11434 is allowed

# Add rule if needed
sudo ufw allow 11434
```

### 7. CodeCompanion Adapter Issues

#### Check Adapter Configuration
```vim
:lua print(vim.inspect(require('codecompanion.config').adapters.ollama))
" Should show your Ollama adapter configuration
```

#### Test CodeCompanion Logs
```vim
:CodeCompanionLog
" Check for specific error messages about HTTP methods
```

### 8. Debugging Steps

#### Step 1: Test Ollama Directly
```bash
# First, test if Ollama is responding at all
curl http://127.0.0.1:11434/api/tags

# If that works, test generation
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:13b", "prompt": "Hello", "stream": false}'
```

#### Step 2: Check CodeCompanion Request Format
```vim
" Enable verbose logging in CodeCompanion config
" Add this to your setup:
" log_level = 'DEBUG',
```

#### Step 3: Test Different Endpoints
Try updating your codecompanion.lua URL to different endpoints:

```lua
-- Option 1: Standard Ollama generate endpoint
url = 'http://127.0.0.1:11434/api/generate',

-- Option 2: Chat endpoint (newer Ollama versions)
url = 'http://127.0.0.1:11434/api/chat',

-- Option 3: OpenAI-compatible endpoint
url = 'http://127.0.0.1:11434/v1/chat/completions',
```

### 9. Common Solutions

#### Solution 1: Update Ollama
```bash
# Update to latest Ollama version
curl -fsSL https://ollama.ai/install.sh | sh
```

#### Solution 2: Fix CodeCompanion Adapter
Add this to your codecompanion.lua if using newer Ollama:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      url = 'http://127.0.0.1:11434/v1/chat/completions',
      headers = {
        ['Content-Type'] = 'application/json',
      },
      -- Remove parameters that might cause 405 errors
      -- parameters = { sync = true }, -- Comment this out
    })
  end,
},
```

#### Solution 3: Alternative Ollama Configuration
```lua
-- If standard config fails, try this minimal version:
adapters = {
  ollama = {
    name = 'ollama',
    url = 'http://127.0.0.1:11434/api/generate',
    headers = {
      ['Content-Type'] = 'application/json',
    },
    parameters = {
      model = 'codellama:13b',
      stream = false,
    },
  },
},
```

### 10. Verification Commands

After making changes:

```bash
# 1. Restart Ollama
pkill ollama
ollama serve &

# 2. Test connection
curl http://127.0.0.1:11434/api/tags

# 3. Test in Neovim
nvim
:CodeCompanion
```

## Quick Fix Checklist

1. ✅ **Ollama running**: `ps aux | grep ollama`
2. ✅ **Models available**: `ollama list`
3. ✅ **Port accessible**: `curl http://127.0.0.1:11434/api/tags`
4. ✅ **Correct URL**: Check codecompanion.lua endpoint
5. ✅ **No firewall blocks**: `sudo ufw status`

The 405 error most commonly occurs when CodeCompanion is using the wrong HTTP endpoint for your Ollama version. Try the different URL configurations above until you find one that works with your setup.

## JSON Parsing Error: "Expected end but found invalid token at character 5"

This error indicates that CodeCompanion is receiving malformed JSON from Ollama, often due to incorrect response formatting or streaming issues.

### 11. JSON Response Issues

#### Check Ollama Response Format
```bash
# Test raw Ollama response
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:13b", "prompt": "Hello", "stream": false}' | jq .

# If jq shows "parse error", the JSON is malformed
```

#### Common JSON Issues
1. **Streaming responses** - Ollama returns multiple JSON objects
2. **Incomplete responses** - Connection drops mid-response
3. **Mixed content** - Non-JSON content mixed with JSON
4. **Character encoding** - Invalid UTF-8 characters

### 12. CodeCompanion Configuration Fixes

#### Fix 1: Disable Streaming
Update your codecompanion.lua to force non-streaming responses:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      name = 'ollama',
      url = 'http://127.0.0.1:11434/api/generate',
      headers = {
        ['Content-Type'] = 'application/json',
      },
      parameters = {
        stream = false,  -- CRITICAL: Disable streaming
        sync = true,
      },
      chat = {
        model = 'codellama:13b',
        temperature = 0.2,
        stream = false,  -- Also disable here
        -- Remove problematic stop tokens
        -- stop = { '<|endoftext|>', '<|im_end|>' },  -- Comment out
      },
      inline = {
        model = 'codellama:7b',
        temperature = 0.1,
        stream = false,  -- And here
      },
    })
  end,
},
```
      adapters = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            name = 'ollama',
            url = 'http://127.0.0.1:11434',
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              sync = true,
            },
            chat = {
              model = 'codellama:13b', -- Larger model for detailed conversations
              temperature = 0.2, -- More focused for code discussions
              top_p = 0.95,
              top_k = 40, -- Limits vocabulary to top 40 tokens
              num_ctx = 16384, -- Large context for code understanding
              num_predict = -1, -- Unlimited output length
              repeat_penalty = 1.1, -- Slight penalty to avoid repetition
              seed = -1, -- Random seed for varied responses
              stop = { '<|endoftext|>', '<|im_end|>' },
            },
            inline = {
              model = 'codellama:7b', -- Faster model for quick completions
              temperature = 0.1, -- Very focused for code generation
              top_p = 0.9,
              top_k = 20, -- More restricted vocabulary for precision
              num_ctx = 8192, -- Smaller context for speed
              num_predict = 256, -- Limit inline completions length
              repeat_penalty = 1.05, -- Light penalty for code completions
              seed = -1, -- Random seed
            },
          })
        end,
      },
#### Fix 2: Alternative Adapter Configuration
Try this minimal configuration to avoid JSON parsing issues:

```lua
adapters = {
  ollama = {
    name = 'ollama',
    url = 'http://127.0.0.1:11434/api/generate',
    headers = {
      ['Content-Type'] = 'application/json',
      ['Accept'] = 'application/json',
    },
    parameters = {
      model = 'codellama:13b',
      stream = false,
      format = 'json',  -- Ensure JSON format
    },
  },
},
```

#### Fix 3: Use OpenAI-Compatible Endpoint
Switch to Ollama's OpenAI-compatible API which has more stable JSON:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('openai', {
      name = 'ollama',
      url = 'http://127.0.0.1:11434/v1/chat/completions',
      headers = {
        ['Content-Type'] = 'application/json',
      },
      chat = {
        model = 'codellama:13b',
        temperature = 0.2,
        stream = false,
      },
    })
  end,
},
```

### 13. Debugging JSON Issues

#### Check Ollama Logs
```bash
# Start Ollama with verbose logging
OLLAMA_DEBUG=1 ollama serve

# In another terminal, watch logs
journalctl -fu ollama  # If using systemd
# or
tail -f ~/.ollama/logs/server.log  # If file logging enabled
```

#### Test Response Manually
```bash
# Test exact request CodeCompanion makes
curl -v -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codellama:13b",
    "prompt": "Hello world",
    "stream": false,
    "temperature": 0.2,
    "top_p": 0.95,
    "top_k": 40,
    "num_ctx": 16384,
    "repeat_penalty": 1.1
  }' > response.json

# Check if response is valid JSON
cat response.json | jq .
```

#### Enable CodeCompanion Debug Logging
Add debug logging to your codecompanion.lua:

```lua
require('codecompanion').setup {
  log_level = 'DEBUG',  -- Add this line
  -- ... rest of your config
}
```

Then check logs:
```vim
:CodeCompanionLog
" Look for JSON parsing errors and malformed responses
```

### 14. Model-Specific Issues

#### CodeLlama Token Issues
CodeLlama models sometimes generate invalid tokens. Try:

```lua
chat = {
  model = 'codellama:13b',
  temperature = 0.2,
  top_p = 0.95,
  top_k = 40,
  num_ctx = 16384,
  num_predict = 512,  -- Limit response length
  repeat_penalty = 1.1,
  -- Remove custom stop tokens that might cause issues
  -- stop = {},  -- Empty or remove entirely
},
```

#### Try Different Model
Test with a more stable model:

```bash
# Pull and try llama3.2 which has better JSON compliance
ollama pull llama3.2:3b
```

Update config to use llama3.2:
```lua
chat = {
  model = 'llama3.2:3b',  -- More stable than codellama
  temperature = 0.2,
  stream = false,
},
```

### 15. Network and Connection Fixes

#### Increase Timeout
Add timeout parameters to prevent truncated responses:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      name = 'ollama',
      url = 'http://127.0.0.1:11434/api/generate',
      timeout = 30000,  -- 30 second timeout
      headers = {
        ['Content-Type'] = 'application/json',
        ['Connection'] = 'close',  -- Close connection after response
      },
      parameters = {
        stream = false,
      },
    })
  end,
},
```

#### Check Ollama Configuration
```bash
# Check Ollama environment variables
env | grep OLLAMA

# Set memory limits if needed
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_QUEUE=1

# Restart Ollama with new settings
pkill ollama
ollama serve
```

## Updated Quick Fix for JSON Errors

1. ✅ **Set stream = false** in all adapter configurations
2. ✅ **Remove custom stop tokens** that might cause parsing issues  
3. ✅ **Test with curl** to verify JSON response format
4. ✅ **Try OpenAI-compatible endpoint** (/v1/chat/completions)
5. ✅ **Enable debug logging** to see exact error details
6. ✅ **Test with simpler model** (llama3.2:3b instead of codellama)

The JSON parsing error usually indicates streaming responses or malformed JSON from Ollama. Disabling streaming (`stream = false`) resolves most cases.

<function_calls>
<invoke name="Read">
<parameter name="file_path">/home/ryan/.config/nvim/lua/plugins/codecompanion.lua
