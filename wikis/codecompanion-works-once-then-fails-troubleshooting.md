# CodeCompanion "Works Once Then Fails" Troubleshooting Guide

## Problem Description
CodeCompanion works on first use but fails on subsequent attempts with various errors like:
- `[ERROR] [Ollama] Test prompt is not a valid input for this system`
- Connection timeouts
- Buffer state corruption
- JSON parsing errors

## Common Error Patterns

### Error 1: "Test prompt is not a valid input for this system"
**Symptom**: First chat works, subsequent chats fail with this Ollama error
**Cause**: CodeCompanion sending validation prompts in wrong API format
**Indicates**: API endpoint or format mismatch

### Error 2: Buffer/State Corruption
**Symptom**: Chat window opens but no response, or UI behaves strangely
**Cause**: CodeCompanion internal state gets corrupted after first use
**Indicates**: Buffer management or plugin state issues

### Error 3: Model Loading Issues
**Symptom**: Works once, then "model not found" or placement errors
**Cause**: Ollama unloads model or memory pressure
**Indicates**: Ollama resource management problems

## Immediate Debugging Steps

### Step 1: Check Error Messages
```vim
:messages
" Look for specific error patterns

:CodeCompanionLog
" Check CodeCompanion internal logs

" Copy messages to troubleshoot:
:redir @a
:messages
:redir END
:put a
```

### Step 2: Test Ollama Directly
```bash
# Test if Ollama works multiple times
ollama run codellama:13b "test 1"
ollama run codellama:13b "test 2"
ollama run codellama:13b "test 3"

# Test API endpoint directly
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:13b", "prompt": "Hello", "stream": false}'
```

### Step 3: Reset CodeCompanion State
```vim
" Close all CodeCompanion buffers
:bufdo if &filetype == 'codecompanion' | bdelete | endif

" Restart CodeCompanion (if commands exist)
:CodeCompanionStop
:CodeCompanionStart

" Clear any hanging processes
:lua require('codecompanion').reset()  -- if available
```

## Solution Configurations

### Solution 1: Explicit Endpoint Configuration
Use this config to force correct API endpoint and disable streaming:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ---@diagnostic disable-next-line: undefined-field
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            url = 'http://127.0.0.1:11434/api/generate',  -- Explicit endpoint
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              stream = false,  -- Force non-streaming
            },
            chat = {
              model = 'codellama:13b',
              temperature = 0.2,
              stream = false,
            },
            inline = {
              model = 'codellama:7b',
              temperature = 0.1,
              stream = false,
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = 'ollama' },
        inline = { adapter = 'ollama' },
      },
    }
  end,
}
```

### Solution 2: OpenAI-Compatible Endpoint
If Solution 1 fails, try Ollama's OpenAI-compatible API:

```lua
adapters = {
  ---@diagnostic disable-next-line: undefined-field
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
      },
      inline = {
        model = 'codellama:7b',
        temperature = 0.1,
      },
    })
  end,
},
```

### Solution 3: Buffer Management Fix
Add explicit buffer management to prevent state corruption:

```lua
require('codecompanion').setup {
  -- ... your adapters config
  
  display = {
    chat = {
      window = {
        layout = 'vertical',
        width = 0.45,
      },
    },
  },
  opts = {
    clear_chat_on_new_prompt = true,  -- Clear state between chats
    use_default_actions = true,
  },
}
```

### Solution 4: Minimal Stable Configuration
Most stable config for consistent behavior:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ---@diagnostic disable-next-line: undefined-field
        ollama = require('codecompanion.adapters').ollama,  -- Use built-in
      },
      strategies = {
        chat = { adapter = 'ollama' },
        inline = { adapter = 'ollama' },
      },
    }
    
    -- Set Ollama model via environment
    vim.fn.setenv('OLLAMA_MODEL', 'codellama:13b')
  end,
}
```

## Advanced Debugging

### Debug Helper Commands
Add these to your config for troubleshooting:

```lua
-- Debug configuration
vim.api.nvim_create_user_command('CCDebug', function()
  print('=== CodeCompanion Debug Info ===')
  local adapter_result = require('codecompanion.config').adapters.ollama()
  print('Adapter config:', vim.inspect(adapter_result))
  print('Chat model:', adapter_result.chat and adapter_result.chat.model or 'not set')
end, {})

-- Test Ollama connection
vim.api.nvim_create_user_command('CCTestOllama', function()
  local result = vim.fn.system('curl -s http://127.0.0.1:11434/api/tags')
  if vim.v.shell_error == 0 then
    print('✅ Ollama is running')
    print('Available models:', result)
  else
    print('❌ Ollama is not accessible')
  end
end, {})

-- Force new chat
vim.api.nvim_create_user_command('CCNew', function()
  vim.cmd('bufdo if &filetype == "codecompanion" | bdelete | endif')
  vim.cmd('CodeCompanion')
end, {})
```

### Ollama Server Debugging
```bash
# Start Ollama with debug logging
OLLAMA_DEBUG=1 ollama serve

# Monitor Ollama logs
journalctl -fu ollama  # if systemd
tail -f ~/.ollama/logs/server.log  # if file logging

# Check Ollama resource usage
ollama ps
```

### Check CodeCompanion Version Compatibility
```vim
:lua print(require('codecompanion').version or 'version unknown')

# Update if needed
:Lazy update codecompanion.nvim
```

## Systematic Troubleshooting Process

### Phase 1: Isolate the Problem
1. **Test Ollama independently**: Multiple `ollama run` commands
2. **Check CodeCompanion logs**: `:CodeCompanionLog` after failure  
3. **Verify model availability**: `ollama list | grep codellama`

### Phase 2: Try Solutions in Order
1. **Start with Solution 1** (explicit endpoint)
2. **If still failing, try Solution 2** (OpenAI endpoint)
3. **If UI issues, add Solution 3** (buffer management)
4. **As last resort, use Solution 4** (minimal config)

### Phase 3: Verify Fix
1. **Restart Neovim** completely
2. **Test multiple chat sessions**:
   ```vim
   :CodeCompanion
   " Type message, get response
   :CCNew
   " Type another message, verify it works
   ```
3. **Monitor for errors**: `:messages` after each test

## Prevention Strategies

### Regular Maintenance
```bash
# Keep Ollama updated
curl -fsSL https://ollama.ai/install.sh | sh

# Monitor model memory usage
ollama ps

# Clean up unused models
ollama rm <old-model>
```

### Stable Usage Patterns
- **Use `:CCNew` command** instead of reusing chat buffers
- **Close chat buffers** when done: `:bdelete`
- **Restart Ollama periodically**: `pkill ollama && ollama serve`

### Configuration Best Practices
- **Always disable streaming**: `stream = false`
- **Use explicit endpoints**: Don't rely on defaults
- **Set reasonable timeouts**: Prevent hanging requests
- **Monitor resource usage**: Ensure adequate RAM/GPU memory

## Common Root Causes Summary

1. **API Format Mismatch**: CodeCompanion using wrong endpoint/format for your Ollama version
2. **Streaming Issues**: Streaming responses causing JSON parsing failures
3. **State Corruption**: CodeCompanion internal state not resetting between chats
4. **Resource Exhaustion**: Ollama running out of memory for model
5. **Model Loading**: Ollama unloading/reloading models between requests

The "works once then fails" pattern almost always indicates issue #1 or #3 - use Solutions 1-2 for API issues, Solution 3 for state issues.