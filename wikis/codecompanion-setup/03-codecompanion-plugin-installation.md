# CodeCompanion Setup Guide - Part 3: CodeCompanion Plugin Installation

## Overview

In this guide, we'll install the CodeCompanion plugin and fix the missing dependencies identified in Part 1. We'll focus on getting the YAML parser working and ensuring all Tree-sitter components are properly configured.

## Step 1: Understanding Your Current Setup

Based on your current configuration file at `lua/plugins/codecompanion.lua`, you already have the plugin defined but need to fix some issues.

### Current Configuration Analysis

Your current config:
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
        ollama = require('codecompanion.adapters').ollama,
      },
      strategies = {
        chat = { adapter = 'ollama' },
        inline = { adapter = 'ollama' },
        agent = { adapter = 'ollama' },
      },
    }
  end,
}
```

**What's good:** ✅
- Plugin source is correct
- Dependencies are listed
- Ollama adapter is configured
- All strategies point to Ollama

## Step 2: Installing Missing Tree-sitter Parsers

The main issue is the missing YAML parser. Let's fix this first.

### Method 1: Install via Neovim Command

Open Neovim and run:

```vim
:TSInstall yaml
```

**What you'll see:**
```
[nvim-treesitter] Installing tree-sitter for yaml...
[nvim-treesitter] Installing tree-sitter for yaml... done
```

### Method 2: Install via Lua Configuration

Add this to your Tree-sitter configuration (usually in `lua/plugins/treesitter.lua` or similar):

```lua
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "yaml",  -- Add this line
    -- Add other languages you use
  },
  -- ... rest of your config
}
```

### Verify Installation

Check if the YAML parser is installed:

```vim
:TSInstallInfo yaml
```

**Expected output:**
```
yaml: [✓] installed
```

## Step 3: Installing ripgrep (Optional but Recommended)

Ripgrep (`rg`) enhances CodeCompanion's search capabilities:

```bash
# Linux (Ubuntu/Debian)
sudo apt install ripgrep

# Verify installation
rg --version
```

**Expected output:**
```
ripgrep 14.1.0
```

## Step 4: Enhanced Plugin Configuration

Let's improve your CodeCompanion configuration with better error handling and additional features:

### Enhanced Configuration

Update your `lua/plugins/codecompanion.lua`:

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
            env = {
              url = 'http://localhost:11434',
            },
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              sync = true,
            },
          })
        end,
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
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = 'vertical', -- or 'horizontal', 'float'
            width = 0.45,
            height = 0.8,
          },
        },
      },
      opts = {
        log_level = 'ERROR', -- Change to 'DEBUG' for troubleshooting
      },
    }
  end,
}
```

### What This Configuration Does:

1. **Extended Ollama Adapter**: More explicit configuration with URL and headers
2. **Display Settings**: Better window sizing and layout
3. **Error Handling**: Proper log level configuration
4. **Sync Parameters**: Ensures proper communication with Ollama

## Step 5: Setting Up Keybindings

Add keybindings to make CodeCompanion easier to use. Create or update your keybindings file:

### Basic Keybindings

Add to your `init.lua` or keybindings file:

```lua
-- CodeCompanion keybindings
vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = 'Open CodeCompanion Chat' })
vim.keymap.set('v', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = 'Send selection to CodeCompanion' })
vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion Actions' })
vim.keymap.set('n', '<leader>ct', '<cmd>CodeCompanionToggle<cr>', { desc = 'Toggle CodeCompanion' })
vim.keymap.set('n', '<leader>ci', '<cmd>CodeCompanion<cr>', { desc = 'Inline CodeCompanion' })
```

### Advanced Keybindings (Optional)

```lua
-- More advanced keybindings
vim.keymap.set('n', '<leader>cq', function()
  vim.ui.input({ prompt = 'Quick question: ' }, function(input)
    if input then
      vim.cmd('CodeCompanion ' .. input)
    end
  end)
end, { desc = 'Quick CodeCompanion question' })

-- Send current buffer to CodeCompanion
vim.keymap.set('n', '<leader>cb', function()
  vim.cmd('%CodeCompanionChat')
end, { desc = 'Send buffer to CodeCompanion' })
```

## Step 6: Testing the Installation

### Test 1: Health Check

Run the CodeCompanion health check:

```vim
:checkhealth codecompanion
```

**Expected output should show:**
```
codecompanion: health#codecompanion#check
========================================================================
## Dependencies
  - OK plenary.nvim installed
  - OK nvim-treesitter installed

## Tree-sitter parsers
  - OK markdown parser installed
  - OK yaml parser installed

## Libraries
  - OK curl installed
  - OK base64 installed
  - OK rg installed (if you installed ripgrep)
```

### Test 2: Open CodeCompanion Chat

Try opening a chat window:

```vim
:CodeCompanionChat
```

**What should happen:**
1. A new window/buffer opens
2. You see the CodeCompanion interface
3. No error messages appear

### Test 3: Simple Query

In the chat window, try typing:
```
Hello, can you help me write a simple Python function?
```

**Expected behavior:**
1. Message sends successfully
2. You receive a response from Ollama
3. No connection errors

## Step 7: Configuring Tree-sitter for Better Integration

Ensure your Tree-sitter configuration supports CodeCompanion features:

### Complete Tree-sitter Setup

If you don't have a Tree-sitter config file, create `lua/plugins/treesitter.lua`:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'lua',
        'vim',
        'vimdoc',
        'query',
        'markdown',
        'markdown_inline',
        'yaml',
        'json',
        'python',
        'javascript',
        'typescript',
        'html',
        'css',
        -- Add languages you commonly use
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    }
  end,
}
```

## Step 8: Model Configuration for CodeCompanion

Configure which Ollama model CodeCompanion should use:

### Specifying the Model

Update your CodeCompanion config to specify the model:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      env = {
        url = 'http://localhost:11434',
      },
      headers = {
        ['Content-Type'] = 'application/json',
      },
      parameters = {
        sync = true,
      },
      schema = {
        model = {
          default = 'codellama:7b', -- Specify your preferred model
        },
      },
    })
  end,
},
```

### Testing Different Models

You can test different models by changing the default value:
- `codellama:7b` - Good for coding tasks
- `llama3.1:8b` - Better for general conversation
- `codellama:13b` - More capable but slower

## Troubleshooting Common Issues

### Issue 1: "YAML parser not found"

**Solution:**
```vim
:TSUninstall yaml
:TSInstall yaml
:checkhealth codecompanion
```

### Issue 2: CodeCompanion won't connect to Ollama

**Check Ollama status:**
```bash
curl http://localhost:11434/api/tags
```

**If it fails:**
```bash
sudo systemctl status ollama
sudo systemctl restart ollama
```

### Issue 3: Plugin not loading

**Check for errors:**
```vim
:messages
```

**Common fixes:**
1. Restart Neovim
2. Run `:Lazy sync` to update plugins
3. Check your Lua syntax in the config file

## Verification Checklist

Before proceeding to Part 4, ensure:

- [ ] YAML parser is installed and working
- [ ] `:checkhealth codecompanion` passes all checks
- [ ] CodeCompanion chat window opens without errors
- [ ] You can send a simple message and get a response
- [ ] Keybindings work as expected
- [ ] No error messages in `:messages`

## Next Steps

Excellent! You now have CodeCompanion installed and the basic dependencies working. In Part 4, we'll:

1. Fine-tune the configuration for optimal performance
2. Set up advanced features like context awareness
3. Configure different chat strategies
4. Test various use cases

---

**Continue to:** [Part 4: Configuration and Integration](./04-configuration-and-integration.md)