# CodeCompanion Setup Guide - Part 4: Configuration and Integration

## Overview

Now that you have CodeCompanion installed and basic functionality working, let's optimize the configuration for the best coding experience. This guide covers advanced configuration, workflow integration, and performance tuning.

## Step 1: Advanced Adapter Configuration

Let's enhance your Ollama adapter configuration for better performance and reliability.

### Complete Adapter Configuration

Update your `lua/plugins/codecompanion.lua` with this comprehensive configuration:

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
            name = 'ollama',
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
                default = 'codellama:7b',
                choices = {
                  'codellama:7b',
                  'codellama:13b',
                  'llama3.1:8b',
                  'codellama:7b-python',
                },
              },
              num_ctx = {
                default = 16384, -- Context window size
              },
              temperature = {
                default = 0.1, -- Lower for more consistent code
              },
              top_p = {
                default = 0.9,
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'ollama',
          roles = {
            llm = 'CodeCompanion', -- Name shown in chat
            user = 'You',
          },
        },
        inline = {
          adapter = 'ollama',
        },
        agent = {
          adapter = 'ollama',
        },
      },
      prompt_library = {
        ['Custom Code Review'] = {
          strategy = 'chat',
          description = 'Review code for bugs and improvements',
          opts = {
            mapping = '<leader>cr',
          },
          prompts = {
            {
              role = 'system',
              content = 'You are an expert code reviewer. Analyze the provided code for bugs, security issues, performance problems, and suggest improvements. Be specific and provide examples.',
            },
            {
              role = 'user',
              content = function()
                return 'Please review this code:\n\n' .. require('codecompanion.helpers.actions').get_code()
              end,
            },
          },
        },
        ['Explain Code'] = {
          strategy = 'chat',
          description = 'Explain how the selected code works',
          opts = {
            mapping = '<leader>ce',
          },
          prompts = {
            {
              role = 'system',
              content = 'You are a programming teacher. Explain code clearly and concisely, breaking down complex concepts into understandable parts.',
            },
            {
              role = 'user',
              content = function()
                return 'Please explain this code:\n\n' .. require('codecompanion.helpers.actions').get_code()
              end,
            },
          },
        },
        ['Generate Tests'] = {
          strategy = 'chat',
          description = 'Generate unit tests for the selected code',
          opts = {
            mapping = '<leader>ct',
          },
          prompts = {
            {
              role = 'system',
              content = 'You are a testing expert. Generate comprehensive unit tests for the provided code. Include edge cases and follow testing best practices for the given language.',
            },
            {
              role = 'user',
              content = function()
                return 'Please generate unit tests for this code:\n\n' .. require('codecompanion.helpers.actions').get_code()
              end,
            },
          },
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = 'Prompt> ',
        },
        chat = {
          window = {
            layout = 'vertical',
            width = 0.45,
            height = 0.8,
            row = 2,
            col = 0,
          },
          show_settings = true,
        },
      },
      opts = {
        log_level = 'ERROR',
        send_code = true, -- Include code context in messages
        use_default_actions = true,
        silence_notifications = false,
      },
    }
  end,
}
```

### What This Configuration Provides:

1. **Multiple Model Choices**: Easily switch between different Ollama models
2. **Optimized Parameters**: Lower temperature for more consistent code generation
3. **Custom Prompts**: Pre-built prompts for common coding tasks
4. **Better UI**: Improved window layout and settings visibility
5. **Context Awareness**: Automatically includes code context

## Step 2: Enhanced Keybindings

Replace your basic keybindings with this comprehensive set:

### Complete Keybinding Configuration

Add to your `init.lua` or keybindings file:

```lua
-- CodeCompanion keybindings
local opts = { noremap = true, silent = true }

-- Basic functionality
vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = 'Open CodeCompanion Chat' })
vim.keymap.set('v', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = 'Send selection to CodeCompanion' })
vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion Actions' })

-- Quick actions with custom prompts
vim.keymap.set('v', '<leader>cr', '<cmd>CodeCompanion Custom Code Review<cr>', { desc = 'Code Review' })
vim.keymap.set('v', '<leader>ce', '<cmd>CodeCompanion Explain Code<cr>', { desc = 'Explain Code' })
vim.keymap.set('v', '<leader>ct', '<cmd>CodeCompanion Generate Tests<cr>', { desc = 'Generate Tests' })

-- Inline assistance
vim.keymap.set('n', '<leader>ci', '<cmd>CodeCompanion<cr>', { desc = 'Inline CodeCompanion' })
vim.keymap.set('v', '<leader>ci', '<cmd>CodeCompanion<cr>', { desc = 'Inline CodeCompanion with selection' })

-- Quick question (without opening chat)
vim.keymap.set('n', '<leader>cq', function()
  vim.ui.input({ prompt = 'Quick question: ' }, function(input)
    if input and input ~= '' then
      vim.cmd('CodeCompanion ' .. input)
    end
  end)
end, { desc = 'Quick CodeCompanion question' })

-- Toggle chat window
vim.keymap.set('n', '<leader>ct', '<cmd>CodeCompanionToggle<cr>', { desc = 'Toggle CodeCompanion Chat' })

-- Advanced: Send entire buffer context
vim.keymap.set('n', '<leader>cb', function()
  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  
  -- Create context-aware prompt
  local prompt = string.format('Here is my %s code. Please review it and suggest improvements:\n\n```%s\n%s\n```', 
    filetype, filetype, content)
  
  vim.cmd('CodeCompanionChat ' .. vim.fn.shellescape(prompt))
end, { desc = 'Send buffer to CodeCompanion' })
```

### Explanation of Keybindings:

- `<leader>cc` - Open chat (normal/visual mode)
- `<leader>ca` - Open action palette
- `<leader>cr` - Review selected code
- `<leader>ce` - Explain selected code
- `<leader>ct` - Generate tests for selected code
- `<leader>ci` - Inline assistance
- `<leader>cq` - Quick question popup
- `<leader>cb` - Send entire buffer for review

## Step 3: Context-Aware Configuration

Configure CodeCompanion to understand your project context better:

### Project-Specific Settings

Create a `.codecompanion.json` file in your project root:

```json
{
  "adapters": {
    "ollama": {
      "model": "codellama:7b-python"
    }
  },
  "context": {
    "include_files": [
      "README.md",
      "requirements.txt",
      "package.json",
      "Cargo.toml"
    ],
    "exclude_patterns": [
      "*.log",
      "node_modules/*",
      ".git/*",
      "*.tmp"
    ]
  }
}
```

### Enhanced Context Variables

Add context variables to your configuration:

```lua
-- Add to your CodeCompanion setup
context = {
  buffer = true,    -- Include current buffer
  filetype = true,  -- Include file type information
  selection = true, -- Include selected text
  surrounding_text = {
    lines_before = 10,
    lines_after = 10,
  },
},
```

## Step 4: Workflow Integration

### Integration with LSP

Make CodeCompanion work better with your Language Server Protocol setup:

```lua
-- Add to your CodeCompanion config
lsp = {
  enable = true,
  diagnostics = true, -- Include diagnostic information
  symbols = true,     -- Include symbol information
},
```

### Integration with Git

Add Git context to your conversations:

```lua
-- Custom function to include Git context
local function get_git_context()
  local handle = io.popen('git log -1 --oneline 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()
    return result:gsub('\n', '')
  end
  return ''
end

-- Add to your prompt library
['Git-Aware Review'] = {
  strategy = 'chat',
  description = 'Review code with Git context',
  prompts = {
    {
      role = 'system',
      content = 'You are reviewing code changes. Consider the Git context and recent commits.',
    },
    {
      role = 'user',
      content = function()
        local code = require('codecompanion.helpers.actions').get_code()
        local git_context = get_git_context()
        return string.format('Recent commit: %s\n\nCode to review:\n%s', git_context, code)
      end,
    },
  },
},
```

## Step 5: Performance Optimization

### Model Selection Based on Task

Configure different models for different tasks:

```lua
-- Add to adapters configuration
adapters = {
  ollama_fast = function()
    return require('codecompanion.adapters').extend('ollama', {
      schema = {
        model = { default = 'codellama:7b' }, -- Fast model for simple tasks
      },
    })
  end,
  ollama_smart = function()
    return require('codecompanion.adapters').extend('ollama', {
      schema = {
        model = { default = 'codellama:13b' }, -- Larger model for complex tasks
      },
    })
  end,
},

strategies = {
  chat = { adapter = 'ollama_smart' },    -- Use smart model for chat
  inline = { adapter = 'ollama_fast' },   -- Use fast model for inline
  agent = { adapter = 'ollama_smart' },   -- Use smart model for agents
},
```

### Memory Management

Configure memory usage for better performance:

```lua
opts = {
  log_level = 'ERROR',
  max_messages = 50,      -- Limit message history
  auto_save_session = true,
  session_cleanup = true,
  memory_limit = 1000,    -- Limit memory usage (MB)
},
```

## Step 6: Testing Your Complete Setup

### Comprehensive Test Checklist

1. **Health Check:**
   ```vim
   :checkhealth codecompanion
   ```

2. **Basic Chat Test:**
   - Open chat with `<leader>cc`
   - Ask: "What programming languages do you support?"

3. **Code Review Test:**
   - Select some code
   - Press `<leader>cr`
   - Verify you get a detailed review

4. **Inline Assistance Test:**
   - Type a comment like `// TODO: write function to sort array`
   - Press `<leader>ci`
   - Ask it to implement the function

5. **Context Test:**
   - Send entire buffer with `<leader>cb`
   - Verify it understands your project context

### Performance Verification

Check performance metrics:

```bash
# Monitor Ollama resource usage
htop -p $(pgrep ollama)

# Check response times
time curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "codellama:7b", "prompt": "Hello", "stream": false}'
```

## Step 7: Custom Workflows

### Example: Code Documentation Workflow

Create a workflow for automatic documentation:

```lua
['Document Code'] = {
  strategy = 'inline',
  description = 'Generate documentation for selected code',
  opts = {
    mapping = '<leader>cd',
  },
  prompts = {
    {
      role = 'system',
      content = 'Generate comprehensive documentation for the provided code. Include parameter descriptions, return values, and usage examples.',
    },
    {
      role = 'user',
      content = function()
        return 'Document this code:\n\n' .. require('codecompanion.helpers.actions').get_code()
      end,
    },
  },
},
```

### Example: Refactoring Workflow

```lua
['Refactor Code'] = {
  strategy = 'chat',
  description = 'Suggest refactoring improvements',
  opts = {
    mapping = '<leader>crf',
  },
  prompts = {
    {
      role = 'system',
      content = 'You are a refactoring expert. Analyze the code and suggest specific refactoring improvements. Focus on readability, maintainability, and performance.',
    },
    {
      role = 'user',
      content = function()
        return 'Please suggest refactoring for:\n\n' .. require('codecompanion.helpers.actions').get_code()
      end,
    },
  },
},
```

## Verification Checklist

Before moving to Part 5, verify:

- [ ] Advanced configuration is working
- [ ] All keybindings respond correctly
- [ ] Context awareness is functioning
- [ ] Custom prompts work as expected
- [ ] Performance is acceptable
- [ ] Workflows integrate well with your coding process

## Next Steps

Excellent! You now have a fully configured and optimized CodeCompanion setup. In Part 5, we'll cover:

1. Common troubleshooting scenarios
2. Performance optimization tips
3. Advanced debugging techniques
4. Integration with other tools

---

**Continue to:** [Part 5: Troubleshooting Common Issues](./05-troubleshooting-common-issues.md)