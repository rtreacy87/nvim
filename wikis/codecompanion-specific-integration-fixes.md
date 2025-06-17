# CodeCompanion-Specific Integration Fixes

## Problem Confirmed: CodeCompanion Integration Issue

Since Ollama works perfectly from the shell but fails through CodeCompanion, the issue is in CodeCompanion's adapter implementation or how it's sending requests to Ollama.

## Root Cause Analysis

The issue is likely one of these CodeCompanion-specific problems:

1. **Incorrect HTTP method** - CodeCompanion using wrong HTTP verb
2. **Malformed request payload** - JSON structure doesn't match Ollama's expectations  
3. **Missing/incorrect headers** - CodeCompanion not sending required headers
4. **Adapter configuration mismatch** - Using wrong adapter base for Ollama
5. **Request streaming issues** - CodeCompanion expecting streaming when disabled

## Immediate Fixes

### Fix 1: Use Ollama's Built-in Adapter (Recommended)

Replace your current adapter configuration with CodeCompanion's built-in Ollama adapter:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ollama = require('codecompanion.adapters').ollama,  -- Use built-in adapter
      },
      strategies = {
        chat = {
          adapter = 'ollama',
        },
        inline = {
          adapter = 'ollama',
        },
        agent = {
          adapter = 'ollama',
        },
      },
      -- Keep your display and other configs
      display = {
        -- your existing display config
      },
    }
  end,
}
```
            name = 'ollama',
            url = 'http://127.0.0.1:11434/api/generate',
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              stream = false, -- CRITICAL: Disable streaming
              sync = true,
            },
            chat = {
              model = 'codellama:13b',
              temperature = 0.2,
              stream = false, -- Also disable here
              -- Remove problematic stop tokens
              -- stop = { '<|endoftext|>', '<|im_end|>' },  -- Comment out
            },
            inline = {
              model = 'codellama:7b',
              temperature = 0.1,
              stream = false, -- And here
            },
          })
        end,
### Fix 2: Override Only Essential Settings

If you need custom models, override minimally:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      schema = {
        model = {
          default = 'codellama:13b',
        },
      },
    })
  end,
},
```

### Fix 3: Debug Current Request Format

Add logging to see exactly what CodeCompanion is sending:

```lua
require('codecompanion').setup {
  log_level = 'DEBUG',
  adapters = {
    ollama = function()
      local adapter = require('codecompanion.adapters').extend('ollama', {
        name = 'ollama',
        url = 'http://127.0.0.1:11434',
        -- Minimal configuration to isolate issues
      })
      
      -- Override request method to add logging
      local original_chat = adapter.handlers.chat
      adapter.handlers.chat = function(self, data, child)
        print('=== CodeCompanion Request ===')
        print(vim.inspect(data))
        print('=============================')
        return original_chat(self, data, child)
      end
      
      return adapter
    end,
  },
}
```

## Advanced Debugging

### Check CodeCompanion's Request vs Working Shell Command

#### Compare Working Shell Request:
```bash
# This works for you:
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:13b", "prompt": "Hello", "stream": false}'
```

#### See CodeCompanion's Actual Request:
```vim
:lua require('codecompanion.utils.log').set_level('DEBUG')
:CodeCompanion
" Type a message, then check logs:
:CodeCompanionLog
```

### Inspect CodeCompanion Adapter Code

```vim
:lua print(vim.inspect(require('codecompanion.adapters').ollama))
" See the default ollama adapter configuration
```

### Test Different CodeCompanion Versions

```vim
" Check your CodeCompanion version
:lua print(require('codecompanion').version or 'unknown')

" Update to latest
:Lazy update codecompanion.nvim
```

## Common CodeCompanion Integration Issues

### Issue 1: Wrong Endpoint Path
CodeCompanion might be appending incorrect paths to your base URL.

**Fix**: Use the exact working endpoint:
```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      url = 'http://127.0.0.1:11434/api/generate',  -- Full path
    })
  end,
},
```

### Issue 2: Request Method Mismatch
CodeCompanion might be using GET instead of POST or vice versa.

**Debug**: Check CodeCompanion logs for HTTP method used.

### Issue 3: Header Problems
CodeCompanion might be missing headers or sending conflicting ones.

**Fix**: Explicitly set headers:
```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      headers = {
        ['Content-Type'] = 'application/json',
        ['Accept'] = 'application/json',
        ['User-Agent'] = 'codecompanion.nvim',
      },
    })
  end,
},
```

### Issue 4: Payload Structure Mismatch
CodeCompanion might be structuring the JSON differently than Ollama expects.

**Fix**: Use CodeCompanion's built-in adapter (Fix 1 above) which should have the correct payload structure.

## Nuclear Option: Minimal Configuration

If nothing works, try this absolute minimal config:

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
        ollama = require('codecompanion.adapters').ollama,
      },
      strategies = {
        chat = { adapter = 'ollama' },
        inline = { adapter = 'ollama' },
      },
    }
  end,
}
```

Then configure Ollama's default model:
```bash
# Set default model for Ollama
export OLLAMA_MODEL=codellama:13b
```

## Verification Steps

1. **Test built-in adapter**: Use Fix 1 above
2. **Check logs**: `:CodeCompanionLog` after making a request
3. **Compare requests**: Shell curl vs CodeCompanion logs
4. **Minimal config**: Try nuclear option if needed

## Expected Outcome

After using the built-in adapter (Fix 1), CodeCompanion should work exactly like your shell commands since it will use the correct request format that Ollama expects.

The key insight is that your custom adapter configuration is likely incompatible with how CodeCompanion structures requests internally. The built-in adapter is tested and known to work with Ollama.

## "No placement returned" Error Fix

### Problem Identified
- ✅ Built-in adapter works: `ollama = require('codecompanion.adapters').ollama`
- ❌ Custom model fails: `[ERROR] [Ollama] No placement returned`

The "No placement returned" error occurs when trying to override the model schema incorrectly.

### Root Cause
The issue is with how you're setting the default model. The `schema.model.default` approach doesn't work properly with CodeCompanion's request handling.

### Working Solutions

#### Solution 1: Set Model via Environment Variable (Recommended)
Instead of changing CodeCompanion config, set Ollama's default model:

```bash
# Set default model for Ollama globally
export OLLAMA_MODEL=codellama:13b

# Or in your shell profile (.bashrc, .zshrc, etc.)
echo 'export OLLAMA_MODEL=codellama:13b' >> ~/.bashrc
```

Then use the simple built-in adapter:
```lua
adapters = {
  ollama = require('codecompanion.adapters').ollama,
},
```

#### Solution 2: Override Model in Chat Parameters
```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      chat = {
        model = 'codellama:13b',  -- Set model here, not in schema
      },
      inline = {
        model = 'codellama:7b',
      },
    })
  end,
},
```

#### Solution 3: Use Ollama CLI to Set Default
```bash
# Create a modelfile with codellama:13b as default
ollama create my-default -f - <<EOF
FROM codellama:13b
EOF

# Use the custom model name
```

Then in CodeCompanion:
```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      chat = {
        model = 'my-default',
      },
    })
  end,
},
```

### Why Schema Override Fails

The `schema.model.default` approach fails because:

1. **Request structure mismatch** - CodeCompanion expects the model in the request body, not schema
2. **Ollama placement logic** - Ollama's "placement" refers to which GPU/CPU to use for the model
3. **Model loading issues** - The schema override might prevent proper model loading

### Debugging Steps

#### Check Available Models
```bash
# Verify your models are available
ollama list | grep codellama

# Test model directly
ollama run codellama:13b "Hello"
```

#### Test Model Parameter
```bash
# Test exact model name CodeCompanion will use
curl -X POST http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:13b", "prompt": "test", "stream": false}'
```

#### Enable Ollama Debug Logging
```bash
# Start Ollama with debug logging
OLLAMA_DEBUG=1 ollama serve

# Watch for placement and model loading messages
```

### Recommended Configuration

Based on your testing, use this configuration:

```lua
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            chat = {
              model = 'codellama:13b',  -- Direct model assignment
              temperature = 0.2,
              num_ctx = 16384,
            },
            inline = {
              model = 'codellama:7b',
              temperature = 0.1,
              num_ctx = 8192,
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = 'ollama' },
        inline = { adapter = 'ollama' },
        agent = { adapter = 'ollama' },
      },
      -- Keep your existing display config
      display = {
        chat = {
          window = {
            layout = 'vertical',
            width = 0.45,
            height = 0.8,
            relative = 'editor',
            border = 'rounded',
            title = 'CodeCompanion',
          },
        },
      },
    }
  end,
}
```

### Verification Steps

1. **Test built-in first**: Confirm `require('codecompanion.adapters').ollama` works
2. **Add model override**: Use Solution 2 above with direct model assignment
3. **Check logs**: `:CodeCompanionLog` for placement errors
4. **Test models**: Verify both codellama:13b and codellama:7b work via ollama CLI

The key is to set the model in the `chat` and `inline` sections directly, not via `schema.model.default` which doesn't work with CodeCompanion's request handling.
