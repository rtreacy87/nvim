# CodeCompanion Configuration Guide

## Table of Contents
- [Overview](#overview)
- [Configuration Structure](#configuration-structure)
- [Adapters](#adapters)
- [Strategies](#strategies)
- [Slash Commands](#slash-commands)
- [Display Settings](#display-settings)
- [Advanced Configuration](#advanced-configuration)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

## Overview

CodeCompanion is a highly configurable Neovim plugin that provides AI-powered chat assistance. This guide explains each configuration option and how to customize it for your needs.

## Configuration Structure

The main configuration is passed to `require("codecompanion").setup({})` and contains these main sections:

```lua
require("codecompanion").setup({
  adapters = {},     -- Define AI model connections
  strategies = {},   -- Configure different interaction modes
  display = {},      -- UI and display settings
  opts = {},         -- Global options
})
```

## Adapters

Adapters define how CodeCompanion connects to AI models (Ollama, OpenAI, Anthropic, etc.).

### Basic Adapter Structure

```lua
adapters = {
  adapter_name = function()
    return require("codecompanion.adapters").extend("base_adapter", {
      -- Adapter-specific configuration
    })
  end,
}
```

### Ollama Adapter Configuration

#### Recommended: Strategy-Specific Models (Best for Code Editors)

```lua
adapters = {
  ollama = function()
    return require("codecompanion.adapters").extend("ollama", {
      name = "ollama",
      url = "http://127.0.0.1:11434",           -- Ollama server URL
      headers = {
        ["Content-Type"] = "application/json",    -- Request headers
      },
      parameters = {
        sync = true,                              -- Synchronous requests
      },
      chat = {
        model = "codellama:13b",                  -- Larger model for detailed conversations
        temperature = 0.2,                       -- More focused for code discussions
        top_p = 0.95,
        num_ctx = 16384,                         -- Large context for understanding code
        stop = { "<|endoftext|>", "<|im_end|>" },
      },
      inline = {
        model = "codellama:7b",                   -- Faster model for quick completions
        temperature = 0.1,                       -- Very focused for code generation
        top_p = 0.9,
        num_ctx = 8192,                          -- Smaller context for speed
      },
    })
  end,
}
```

**Why This Configuration is Better for Code Editors:**

| Aspect | Chat (codellama:13b) | Inline (codellama:7b) | Benefit |
|--------|---------------------|----------------------|---------|
| **Model Size** | 13B parameters | 7B parameters | Chat gets accuracy, inline gets speed |
| **Temperature** | 0.2 (focused) | 0.1 (very focused) | Code discussions vs precise completions |
| **Context Size** | 16384 tokens | 8192 tokens | Large context for analysis, smaller for speed |
| **Use Case** | Code explanation, debugging | Auto-completion, quick fixes | Optimized for different interaction types |

#### Alternative: Schema-Based Configuration

For simpler setups or when using the same model for all strategies:

```lua
adapters = {
  ollama = function()
    return require("codecompanion.adapters").extend("ollama", {
      env = {
        url = "http://127.0.0.1:11434",           -- Ollama server URL
        api_key = "optional_api_key",             -- API key if required
      },
      headers = {
        ["Content-Type"] = "application/json",    -- Request headers
        ["Authorization"] = "Bearer ${api_key}",  -- Auth header (optional)
      },
      schema = {
        model = {
          default = "codellama:13b",              -- Single model for all strategies
        },
        num_ctx = {
          default = 16384,                        -- Context window size
        },
        num_predict = {
          default = -1,                           -- Max tokens to generate (-1 = unlimited)
        },
        temperature = {
          default = 0.3,                          -- Moderate creativity for code
        },
        top_p = {
          default = 0.9,                          -- Nucleus sampling (0.0-1.0)
        },
        top_k = {
          default = 40,                           -- Top-k sampling
        },
        repeat_penalty = {
          default = 1.1,                          -- Repetition penalty
        },
        seed = {
          default = -1,                           -- Random seed (-1 = random)
        },
      },
    })
  end,
}
```

### Model Selection for Code Editors

#### CodeLlama vs General Purpose Models

**CodeLlama Models (Recommended for Code):**

| Model | Size | Best For | Speed | Quality |
|-------|------|----------|-------|---------|
| `codellama:7b` | 7B | Inline completions, quick fixes | ⚡⚡⚡ | ⭐⭐⭐⭐ |
| `codellama:13b` | 13B | Code explanations, complex analysis | ⚡⚡ | ⭐⭐⭐⭐⭐ |
| `codellama:34b` | 34B | Complex refactoring, architecture | ⚡ | ⭐⭐⭐⭐⭐⭐ |

**General Purpose Models:**

| Model | Size | Best For | Code Quality | General Chat |
|-------|------|----------|--------------|--------------|
| `llama3.2:1b` | 1B | Very fast responses | ⭐⭐ | ⭐⭐⭐ |
| `llama3.2:3b` | 3B | Balanced speed/quality | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| `llama3.2:latest` | 8B | General conversations | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Why CodeLlama for Code Editors:**

✅ **Code-Specific Training**: Trained on code repositories and programming patterns
✅ **Better Syntax Understanding**: Understands language-specific patterns and conventions  
✅ **Focused Responses**: Less likely to add unnecessary explanations in inline mode
✅ **Multiple Languages**: Supports 20+ programming languages effectively
✅ **API Awareness**: Better understanding of standard libraries and frameworks

#### Strategy-Specific Configuration Benefits

**Chat Strategy (codellama:13b):**
- **Detailed Explanations**: Can provide comprehensive code analysis
- **Architecture Discussions**: Understands complex system design patterns
- **Debugging Help**: Better at identifying subtle bugs and issues
- **Code Review**: Provides thoughtful feedback on code quality

**Inline Strategy (codellama:7b):**
- **Fast Completions**: 2-3x faster than 13b model
- **Precise Suggestions**: Focused on completing the immediate context
- **Less Verbose**: Provides code without unnecessary explanations
- **Real-time Feel**: Fast enough for typing-speed completions

#### Configuration Parameter Reference

| Parameter | Description | Range | Schema Default | Chat Optimized | Inline Optimized | Purpose |
|-----------|-------------|-------|----------------|----------------|------------------|---------|
| `model` | AI model to use | Any valid model | `codellama:13b` | `codellama:13b` | `codellama:7b` | Balance quality vs speed |
| `num_ctx` | Context window size | 1024-32768+ | 16384 | 16384 | 8192 | Memory for code understanding |
| `num_predict` | Max output tokens | -1 or 1-4096 | -1 (unlimited) | -1 (unlimited) | 256 (limited) | Control response length |
| `temperature` | Response creativity | 0.0-2.0 | 0.3 | 0.2 | 0.1 | Balance creativity vs precision |
| `top_p` | Nucleus sampling | 0.0-1.0 | 0.9 | 0.95 | 0.9 | Control response diversity |
| `top_k` | Top-k sampling | 1-100 | 40 | 40 | 20 | Vocabulary restriction |
| `repeat_penalty` | Avoid repetition | 1.0-1.3 | 1.1 | 1.1 | 1.05 | Prevent repetitive patterns |
| `seed` | Random seed | -1 or number | -1 (random) | -1 (random) | -1 (random) | Reproducible responses |

### Parameter Explanations for Beginners

#### **`model` - The AI Brain**
**What it is**: The specific AI model that processes your requests
**Why it matters**: Different models have different capabilities
- **`codellama:13b`**: Larger, smarter, better for complex explanations (chat)
- **`codellama:7b`**: Smaller, faster, good for quick completions (inline)
- **Think of it like**: Choosing between a detailed expert consultant vs. a quick reference assistant

#### **`num_ctx` - Memory Size**
**What it is**: How much code/text the AI can "remember" at once
**Why it matters**: Affects how well the AI understands your code context
- **16384 tokens**: Can understand ~8,000 lines of code
- **8192 tokens**: Can understand ~4,000 lines of code  
- **Think of it like**: The AI's short-term memory - bigger = better understanding but slower

#### **`num_predict` - Response Length Limit**
**What it is**: Maximum length of the AI's response
**Why it matters**: Controls how verbose the AI gets
- **-1 (unlimited)**: AI can give full, detailed explanations (chat)
- **256 tokens**: AI gives brief, focused answers (~100 words) (inline)
- **Think of it like**: Setting a word limit on an essay - unlimited for essays, short for quick answers

#### **`temperature` - Creativity Level**
**What it is**: How "creative" or "random" the AI's responses are
**Why it matters**: Affects consistency and predictability
- **0.1**: Very focused, same answer every time (inline completions)
- **0.2**: Mostly consistent but some variation (chat discussions)  
- **0.8**: Creative and varied responses (general conversation)
- **Think of it like**: Coffee strength - low = focused and precise, high = energetic and creative

#### **`top_p` - Response Diversity**
**What it is**: Controls how the AI chooses words (nucleus sampling)
**Why it matters**: Affects response quality and variety
- **0.9**: Considers 90% of likely word choices (balanced)
- **0.95**: Considers 95% of likely word choices (more diverse)
- **Think of it like**: Size of vocabulary the AI considers - higher = more word variety

#### **`top_k` - Vocabulary Restriction**
**What it is**: Limits AI to only the most likely word choices
**Why it matters**: Prevents AI from choosing unusual words
- **20**: Only considers top 20 most likely words (very focused, inline)
- **40**: Considers top 40 most likely words (balanced, chat)
- **Think of it like**: Restricting to a "safe" vocabulary - lower = more predictable

#### **`repeat_penalty` - Anti-Repetition**
**What it is**: Discourages the AI from repeating the same words/phrases
**Why it matters**: Prevents boring, repetitive responses
- **1.05**: Light penalty (allows code patterns to repeat)
- **1.1**: Moderate penalty (good balance for explanations)
- **1.3**: Strong penalty (may hurt code structure)
- **Think of it like**: A rule against saying the same thing twice - higher = stricter rule

#### **`seed` - Randomness Control**
**What it is**: Sets the "random number" used by the AI
**Why it matters**: Controls response reproducibility
- **-1**: Random seed each time (different responses)
- **123**: Fixed seed (same response every time with same input)
- **Think of it like**: A random number generator - fixed = predictable, random = varied

### Configuration Strategy Impact

**Schema Configuration (One-Size-Fits-All)**:
```lua
schema = {
  model = { default = "codellama:13b" },
  temperature = { default = 0.3 },
  num_ctx = { default = 16384 }
}
```
- **Pros**: Simple, consistent behavior across all features
- **Cons**: Not optimized for specific use cases
- **Best for**: Beginners who want simple setup

**Strategy-Specific Configuration (Optimized)**:
```lua
chat = {
  model = "codellama:13b",    -- Detailed explanations
  temperature = 0.2,          -- Focused but thoughtful
  num_predict = -1,           -- Full-length responses
  top_k = 40                  -- Broader vocabulary
},
inline = {
  model = "codellama:7b",     -- Fast completions  
  temperature = 0.1,          -- Very precise
  num_predict = 256,          -- Brief responses
  top_k = 20                  -- Focused vocabulary
}
```
- **Pros**: Optimized performance for each use case
- **Cons**: More complex to understand and maintain
- **Best for**: Users who want maximum performance

### Quick Setup Guide

**Beginner Setup** (start here):
```lua
-- Simple, works well for most people
chat = {
  model = "codellama:13b",
  temperature = 0.2,
  num_ctx = 16384
},
inline = {
  model = "codellama:7b", 
  temperature = 0.1,
  num_ctx = 8192,
  num_predict = 256
}
```

**Advanced Setup** (when you want more control):
```lua
-- Add more parameters as you learn what they do
chat = {
  model = "codellama:13b",
  temperature = 0.2,
  top_p = 0.95,
  top_k = 40,
  num_ctx = 16384,
  num_predict = -1,
  repeat_penalty = 1.1
}
```

#### Model Installation

Before using CodeLlama models, ensure they're available:

```bash
# Install recommended models
ollama pull codellama:7b     # For inline completions
ollama pull codellama:13b    # For chat discussions

# Optional: Larger model for complex projects  
ollama pull codellama:34b    # For advanced analysis

# Verify installation
ollama list | grep codellama
```

### OpenAI Adapter Configuration

```lua
adapters = {
  openai = function()
    return require("codecompanion.adapters").extend("openai", {
      env = {
        api_key = "cmd:echo $OPENAI_API_KEY",     -- Get API key from environment
      },
      schema = {
        model = {
          default = "gpt-4",                      -- GPT model to use
        },
        max_tokens = {
          default = 4096,                         -- Max response tokens
        },
        temperature = {
          default = 0.7,                          -- Creativity level
        },
      },
    })
  end,
}
```

## Strategies

Strategies define different interaction modes (chat, inline, agent). Each strategy can use a different adapter.

### Chat Strategy

Interactive chat interface for conversations with the AI.

```lua
strategies = {
  chat = {
    adapter = "ollama",                           -- Which adapter to use
    roles = {
      llm = "Assistant",                          -- AI role name
      user = "User"                              -- User role name
    },
    variables = {
      -- Built-in variables for sharing context
      ["buffer"] = {
        callback = "strategies.chat.variables.buffer",
        description = "Share the current buffer with the LLM",
        opts = { contains_code = true }
      },
      ["viewport"] = {
        callback = "strategies.chat.variables.viewport",
        description = "Share the current viewport with the LLM",
        opts = { contains_code = true }
      },
      ["selection"] = {
        callback = "strategies.chat.variables.selection",
        description = "Share the current selection with the LLM",
        opts = { contains_code = true }
      },
    },
    slash_commands = {
      -- Custom slash commands (see detailed section below)
    }
  }
}
```

#### Chat Strategy Options

| Option | Description | Example |
|--------|-------------|---------|
| `adapter` | Which adapter to use | `"ollama"`, `"openai"` |
| `roles.llm` | Name for AI responses | `"Assistant"`, `"AI"` |
| `roles.user` | Name for user messages | `"User"`, `"Developer"` |
| `variables` | Context sharing options | Buffer, viewport, selection |
| `slash_commands` | Custom commands | `/codebase`, `/docs` |

### Inline Strategy

Quick inline code generation and editing.

```lua
strategies = {
  inline = {
    adapter = "ollama",                           -- Adapter for inline suggestions
    keymaps = {
      accept = "<Tab>",                          -- Accept suggestion
      reject = "<S-Tab>",                        -- Reject suggestion
    },
    opts = {
      auto_submit = true,                        -- Auto-submit on selection
      stop_context_insertion = true,            -- Don't insert context automatically
    }
  }
}
```

### Agent Strategy

Autonomous AI agent that can perform tasks.

```lua
strategies = {
  agent = {
    adapter = "ollama",                           -- Adapter for agent mode
    tools = {
      -- Define available tools for the agent
      file_editor = true,                        -- Can edit files
      terminal = true,                           -- Can run terminal commands
    }
  }
}
```

## Slash Commands

Slash commands provide quick access to specific functionality. They appear in chat with `/command_name`.

### Basic Slash Command Structure

```lua
slash_commands = {
  ["command_name"] = {
    callback = function(query)
      -- Process the query and return response
      return "Response text"
    end,
    description = "Command description",         -- Shows in help
    opts = { 
      contains_code = true,                      -- Whether response contains code
      hide = false,                              -- Hide from command list
    }
  }
}
```

### VectorCode Integration Example

```lua
slash_commands = {
  ["codebase"] = {
    callback = function(query)
      -- Execute VectorCode query safely
      local handle = io.popen("vectorcode query '" .. query .. "' --format json --limit 5 2>/dev/null")
      if not handle then
        return "Error: Could not execute VectorCode query"
      end
      
      local result = handle:read("*a")
      local success = handle:close()
      
      if not success or not result or result == "" then
        return "No relevant code found for: " .. query
      end

      local parsed_success, parsed = pcall(vim.json.decode, result)
      if not parsed_success or not parsed or type(parsed) ~= "table" or #parsed == 0 then
        return "No relevant code found for: " .. query
      end
      
      local context = "Here are relevant code snippets from your codebase:\n\n"
      for i, item in ipairs(parsed) do
        if i <= 5 then
          local file = item and item.file or "unknown"
          local score = item and item.score or 0
          local language = item and item.language or ""
          local content = item and item.content or ""
          
          context = context .. string.format(
            "**File: %s** (score: %.2f)\n```%s\n%s\n```\n\n",
            file, score, language, content
          )
        end
      end
      return context
    end,
    description = "Search codebase with RAG",
    opts = { contains_code = true }
  }
}
```

### Built-in Slash Commands

CodeCompanion includes several built-in slash commands:

| Command | Description | Usage |
|---------|-------------|-------|
| `/buffer` | Share current buffer | `/buffer` |
| `/file` | Share specific file | `/file path/to/file.py` |
| `/help` | Show available commands | `/help` |
| `/terminal` | Run terminal command | `/terminal ls -la` |
| `/symbols` | Share code symbols | `/symbols function_name` |

## Display Settings

Configure the UI appearance and behavior.

### Window Configuration

```lua
display = {
  action_palette = {
    width = 95,                                  -- Palette width in columns
    height = 10,                                 -- Palette height in rows
    prompt = "CodeCompanion: ",                  -- Prompt text
    border = "rounded",                          -- Border style
  },
  chat = {
    window = {
      layout = "vertical",                       -- "vertical", "horizontal", "float"
      width = 0.45,                              -- Width as fraction of screen
      height = 0.8,                              -- Height as fraction of screen
      relative = "editor",                       -- "editor", "win", "cursor"
      border = "rounded",                        -- Border style
      title = "CodeCompanion",                   -- Window title
      title_pos = "center",                      -- "left", "center", "right"
    },
    intro_message = "Welcome! Use /help for available commands.",
    show_settings = true,                        -- Show settings in chat
    show_token_count = true,                     -- Show token usage
  },
  inline = {
    layout = "buffer",                           -- "buffer", "floating"
  }
}
```

#### Window Layout Options

| Layout | Description | Use Case |
|--------|-------------|----------|
| `vertical` | Split vertically | Side-by-side with code |
| `horizontal` | Split horizontally | Above/below code |
| `float` | Floating window | Overlay on code |

#### Border Styles

- `"none"` - No border
- `"single"` - Single line border
- `"double"` - Double line border  
- `"rounded"` - Rounded corners
- `"solid"` - Solid border
- `"shadow"` - Border with shadow

## Advanced Configuration

### Global Options

```lua
opts = {
  log_level = "ERROR",                           -- "ERROR", "WARN", "INFO", "DEBUG", "TRACE"
  send_code = true,                              -- Allow sending code to AI
  use_default_actions = true,                    -- Enable default actions
  use_default_prompt_library = true,            -- Use built-in prompts
  prompt_library = {
    -- Custom prompt library
    ["explain"] = {
      description = "Explain code",
      prompts = {
        {
          role = "user",
          content = "Please explain this code: {{selection}}"
        }
      }
    }
  }
}
```

### Model-Specific Configurations

Different models may need different settings:

```lua
adapters = {
  -- Fast model for quick tasks
  ollama_fast = function()
    return require("codecompanion.adapters").extend("ollama", {
      schema = {
        model = { default = "llama3.2:1b" },     -- Smaller, faster model
        temperature = { default = 0.3 },         -- More focused responses
        num_ctx = { default = 8192 },            -- Smaller context window
      },
    })
  end,
  
  -- Powerful model for complex tasks
  ollama_powerful = function()
    return require("codecompanion.adapters").extend("ollama", {
      schema = {
        model = { default = "llama3.2:70b" },    -- Larger, more capable model
        temperature = { default = 0.8 },         -- More creative responses
        num_ctx = { default = 32768 },           -- Larger context window
      },
    })
  end,
}

strategies = {
  chat = { adapter = "ollama_powerful" },        -- Use powerful model for chat
  inline = { adapter = "ollama_fast" },          -- Use fast model for inline
}
```

### Environment Variable Configuration

Securely manage API keys and URLs:

```lua
adapters = {
  openai = function()
    return require("codecompanion.adapters").extend("openai", {
      env = {
        api_key = "cmd:echo $OPENAI_API_KEY",    -- Get from environment
        organization = "cmd:echo $OPENAI_ORG",  -- Optional organization
      },
    })
  end,
  
  ollama_remote = function()
    return require("codecompanion.adapters").extend("ollama", {
      env = {
        url = "cmd:echo $OLLAMA_URL",            -- Remote Ollama server
        api_key = "cmd:echo $OLLAMA_API_KEY",    -- API key if needed
      },
    })
  end,
}
```

## Common Patterns

### Multi-Model Setup

Use different models for different purposes:

```lua
require("codecompanion").setup({
  adapters = {
    coding = function()
      return require("codecompanion.adapters").extend("ollama", {
        schema = { model = { default = "codellama:13b" } }
      })
    end,
    writing = function()
      return require("codecompanion.adapters").extend("ollama", {
        schema = { model = { default = "llama3.2:latest" } }
      })
    end,
  },
  strategies = {
    chat = { adapter = "writing" },
    inline = { adapter = "coding" },
  }
})
```

### Custom Keybindings Integration

```lua
-- In your keymaps.lua or init.lua
vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "Open CodeCompanion" })
vim.keymap.set("v", "<leader>ce", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })

-- Quick codebase search
vim.keymap.set("n", "<leader>cs", function()
  local query = vim.fn.input("Search codebase: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/codebase " .. query, "n", false)
    end, 100)
  end
end, { desc = "Quick codebase search" })
```

### Project-Specific Configuration

```lua
-- In your project's .nvim.lua or project-specific config
local project_config = {
  adapters = {
    project_specific = function()
      return require("codecompanion.adapters").extend("ollama", {
        schema = {
          model = { default = "codellama:34b" },  -- Project needs powerful model
          temperature = { default = 0.2 },        -- More deterministic for this project
        }
      })
    end,
  },
  strategies = {
    chat = { adapter = "project_specific" },
  }
}

require("codecompanion").setup(project_config)
```

## Troubleshooting

### Configuration Validation

```lua
-- Add this to validate your configuration
local function validate_codecompanion_config(config)
  local errors = {}
  
  -- Check required sections
  if not config.adapters then
    table.insert(errors, "Missing adapters configuration")
  end
  
  if not config.strategies then
    table.insert(errors, "Missing strategies configuration")
  end
  
  -- Validate adapters
  if config.adapters then
    for name, adapter in pairs(config.adapters) do
      if type(adapter) ~= "function" then
        table.insert(errors, string.format("Adapter '%s' must be a function", name))
      end
    end
  end
  
  -- Validate strategies
  if config.strategies then
    for name, strategy in pairs(config.strategies) do
      if not strategy.adapter then
        table.insert(errors, string.format("Strategy '%s' missing adapter", name))
      elseif config.adapters and not config.adapters[strategy.adapter] then
        table.insert(errors, string.format("Strategy '%s' references unknown adapter '%s'", name, strategy.adapter))
      end
    end
  end
  
  return errors
end

-- Use in your configuration
local config = { 
  -- Your configuration here
}

local errors = validate_codecompanion_config(config)
if #errors > 0 then
  vim.notify("CodeCompanion configuration errors:\n" .. table.concat(errors, "\n"), vim.log.levels.ERROR)
else
  require("codecompanion").setup(config)
end
```

### Common Issues and Solutions

1. **Adapter not found**: Ensure adapter name in strategy matches adapter definition
2. **Model not responding**: Check Ollama is running and model is available
3. **Slash commands not working**: Verify callback functions handle errors properly
4. **UI not appearing**: Check display configuration and window dimensions

### Debug Configuration

```lua
require("codecompanion").setup({
  opts = {
    log_level = "DEBUG",                         -- Enable detailed logging
  },
  -- Rest of configuration
})

-- Check logs
-- :CodeCompanionLog
-- or check ~/.local/state/nvim/codecompanion.log
```

This configuration guide provides a comprehensive understanding of all CodeCompanion options. Start with basic configurations and gradually add advanced features as needed.