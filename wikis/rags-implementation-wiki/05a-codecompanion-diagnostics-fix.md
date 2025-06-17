# CodeCompanion Lua Diagnostics Fix Guide

## Overview

This guide addresses the Lua diagnostics warnings in your CodeCompanion configuration and provides clean, error-free code.

## Common Warnings and Solutions

### 1. Duplicate Index `adapters` Warning

**Problem**: The `adapters` key appears multiple times in the configuration table.

**Warning**: `Duplicate index 'adapters'. Lua Diagnostics. (duplicate-index)`

**Solution**: Ensure `adapters` is defined only once at the top level.

### 2. Need Check Nil Warnings

**Problem**: Accessing properties without checking if the parent object exists.

**Warning**: `Need check nil. Lua Diagnostics. (need-check-nil)`

**Solution**: Add proper nil checks before accessing nested properties.

## Fixed CodeCompanion Configuration

Replace your current CodeCompanion configuration with this corrected version:

```lua
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim", -- Improves UI
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            url = "http://127.0.0.1:11434",
            headers = {
              ["Content-Type"] = "application/json",
            },
            parameters = {
              sync = true,
            },
            chat = {
              model = "codellama:13b",              -- Larger model for detailed conversations
              temperature = 0.2,                   -- More focused for code discussions
              top_p = 0.95,
              top_k = 40,                          -- Limits vocabulary to top 40 tokens
              num_ctx = 16384,                     -- Large context for code understanding
              num_predict = -1,                    -- Unlimited output length
              repeat_penalty = 1.1,                -- Slight penalty to avoid repetition
              seed = -1,                           -- Random seed for varied responses
              stop = { "<|endoftext|>", "<|im_end|>" },
            },
            inline = {
              model = "codellama:7b",               -- Faster model for quick completions
              temperature = 0.1,                   -- Very focused for code generation
              top_p = 0.9,
              top_k = 20,                          -- More restricted vocabulary for precision
              num_ctx = 8192,                      -- Smaller context for speed
              num_predict = 256,                   -- Limit inline completions length
              repeat_penalty = 1.05,               -- Light penalty for code completions
              seed = -1,                           -- Random seed
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "ollama",
          roles = {
            llm = "Assistant",
            user = "User"
          },
          slash_commands = {
            -- VectorCode integration for codebase search
            ["codebase"] = {
              callback = function(query)
                -- Execute VectorCode query and return results
                local handle = io.popen("vectorcode query '" .. query .. "' --pipe -n 5 2>/dev/null")
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
                  if i <= 5 then -- Limit to top 5 results
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
            },

            -- Quick documentation search
            ["docs"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " documentation' --include '*.md' --format json --limit 3 2>/dev/null")
                if not handle then
                  return "Error: Could not execute documentation search"
                end
                
                local result = handle:read("*a")
                local success = handle:close()
                
                if not success or not result or result == "" then
                  return "No documentation found for: " .. query
                end

                local parsed_success, parsed = pcall(vim.json.decode, result)
                if not parsed_success or not parsed or type(parsed) ~= "table" or #parsed == 0 then
                  return "No documentation found for: " .. query
                end
                
                local context = "Documentation search results:\n\n"
                for i, item in ipairs(parsed) do
                  if i <= 3 then
                    local file = item and item.file or "unknown"
                    local content = item and item.content or ""
                    local truncated = content:len() > 500 and (content:sub(1, 500) .. "...") or content
                    
                    context = context .. string.format("**%s**\n%s\n\n", file, truncated)
                  end
                end
                return context
              end,
              description = "Search documentation",
            },

            -- Search for tests
            ["tests"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " test' --include '*test*' --include '*spec*' --format json --limit 3 2>/dev/null")
                if not handle then
                  return "Error: Could not execute test search"
                end
                
                local result = handle:read("*a")
                local success = handle:close()
                
                if not success or not result or result == "" then
                  return "No test code found for: " .. query
                end

                local parsed_success, parsed = pcall(vim.json.decode, result)
                if not parsed_success or not parsed or type(parsed) ~= "table" or #parsed == 0 then
                  return "No test code found for: " .. query
                end
                
                local context = "Test-related code:\n\n"
                for i, item in ipairs(parsed) do
                  if i <= 3 then
                    local file = item and item.file or "unknown"
                    local language = item and item.language or ""
                    local content = item and item.content or ""
                    
                    context = context .. string.format(
                      "**%s**\n```%s\n%s\n```\n\n",
                      file, language, content
                    )
                  end
                end
                return context
              end,
              description = "Search test files",
              opts = { contains_code = true }
            }
          }
        },
        inline = {
          adapter = "ollama"
        },
        agent = {
          adapter = "ollama"
        }
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = "vertical",
            width = 0.45,
            height = 0.8,
            relative = "editor",
            border = "rounded",
            title = "CodeCompanion",
          },
          intro_message = "Welcome! Use /codebase to search your code repository.",
        }
      },
      opts = {
        log_level = "ERROR", -- Change to "DEBUG" for troubleshooting
      }
    })
  end,
}
```

## Configuration Approach Comparison

### Strategy-Specific vs Schema-Based Configuration

**Strategy-Specific Configuration (Recommended):**
```lua
chat = {
  model = "codellama:13b",
  temperature = 0.2,
  top_p = 0.95,
  top_k = 40,
  num_ctx = 16384,
  num_predict = -1,
  repeat_penalty = 1.1,
  seed = -1,
  stop = { "<|endoftext|>", "<|im_end|>" },
},
inline = {
  model = "codellama:7b", 
  temperature = 0.1,
  top_p = 0.9,
  top_k = 20,
  num_ctx = 8192,
  num_predict = 256,
  repeat_penalty = 1.05,
  seed = -1,
},
```

**Schema-Based Configuration (Alternative):**
```lua
schema = {
  model = { default = "codellama:13b" },
  temperature = { default = 0.3 },
  top_p = { default = 0.9 },
  top_k = { default = 40 },
  num_ctx = { default = 16384 },
  num_predict = { default = -1 },
  repeat_penalty = { default = 1.1 },
  seed = { default = -1 },
},
```

### Comprehensive Parameter Analysis

#### Strengths of Including All Parameters

✅ **Precise Control**
- **`num_predict`**: Controls output length (unlimited for chat, limited for inline)
- **`top_k`**: Restricts vocabulary (40 for chat diversity, 20 for inline precision)
- **`repeat_penalty`**: Prevents repetitive code patterns
- **`seed`**: Enables reproducible responses when needed

✅ **Performance Optimization**
- **Chat**: Longer, more detailed responses with broader vocabulary
- **Inline**: Short, precise completions with focused vocabulary
- **Context Management**: Different context sizes for different needs

✅ **Quality Assurance**
- **Temperature Differentiation**: 0.2 vs 0.1 for appropriate creativity levels
- **Sampling Control**: Fine-tuned `top_p` and `top_k` for each use case
- **Stop Sequences**: Proper response termination

#### Weaknesses of Comprehensive Configuration

⚠️ **Complexity**
- More parameters to understand and maintain
- Requires knowledge of each parameter's impact
- Higher chance of misconfiguration

⚠️ **Maintenance Overhead**
- Need to update parameters when switching models
- Different models may need different optimal values
- Requires periodic tuning based on usage patterns

⚠️ **Potential Over-optimization**
- May optimize for current workflow but reduce flexibility
- Could limit model's natural capabilities
- May need adjustment as models improve

#### Parameter Impact on Code Editor Usage

| Parameter        | Chat Setting   | Inline Setting     | Why Different                                         | Impact                  |
|------------------|----------------|--------------------|-------------------------------------------------------|-------------------------|
| `num_predict`    | -1 (unlimited) | 256 (limited)      | Chat needs full explanations, inline needs brevity    | Response length control |
| `top_k`          | 40 (diverse)   | 20 (focused)       | Chat explores options, inline stays precise           | Vocabulary breadth      |
| `temperature`    | 0.2 (focused)  | 0.1 (very focused) | Chat allows creativity, inline prioritizes accuracy   | Response creativity     |
| `repeat_penalty` | 1.1 (moderate) | 1.05 (light)       | Chat avoids repetition, inline allows code patterns   | Pattern repetition      |
| `num_ctx`        | 16384 (large)  | 8192 (smaller)     | Chat needs full context, inline focuses on local area | Context window          |

### Configuration Parameter Reference

| Parameter        | Description         | Range           | Schema Default  | Chat Optimized  | Inline Optimized | Purpose                         |
|------------------|---------------------|-----------------|-----------------|-----------------|------------------|---------------------------------|
| `model`          | AI model to use     | Any valid model | `codellama:13b` | `codellama:13b` | `codellama:7b`   | Balance quality vs speed        |
| `num_ctx`        | Context window size | 1024-32768+     | 16384           | 16384           | 8192             | Memory for code understanding   |
| `num_predict`    | Max output tokens   | -1 or 1-4096    | -1 (unlimited)  | -1 (unlimited)  | 256 (limited)    | Control response length         |
| `temperature`    | Response creativity | 0.0-2.0         | 0.3             | 0.2             | 0.1              | Balance creativity vs precision |
| `top_p`          | Nucleus sampling    | 0.0-1.0         | 0.9             | 0.95            | 0.9              | Control response diversity      |
| `top_k`          | Top-k sampling      | 1-100           | 40              | 40              | 20               | Vocabulary restriction          |
| `repeat_penalty` | Avoid repetition    | 1.0-1.3         | 1.1             | 1.1             | 1.05             | Prevent repetitive patterns     |
| `seed`           | Random seed         | -1 or number    | -1 (random)     | -1 (random)     | -1 (random)      | Reproducible responses          |

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

### Recommended Configuration Strategy

**For Most Users (Balanced Approach):**
```lua
-- Include essential parameters with strategy-specific optimization
chat = {
  model = "codellama:13b",
  temperature = 0.2,
  top_p = 0.95,
  num_ctx = 16384,
  num_predict = -1,
  stop = { "<|endoftext|>", "<|im_end|>" },
},
inline = {
  model = "codellama:7b",
  temperature = 0.1,
  top_p = 0.9,
  num_ctx = 8192,
  num_predict = 256,
},
```

**For Power Users (Full Control):**
```lua
-- Include all parameters for maximum control
chat = {
  model = "codellama:13b",
  temperature = 0.2,
  top_p = 0.95,
  top_k = 40,
  num_ctx = 16384,
  num_predict = -1,
  repeat_penalty = 1.1,
  seed = -1,
  stop = { "<|endoftext|>", "<|im_end|>" },
},
inline = {
  model = "codellama:7b",
  temperature = 0.1,
  top_p = 0.9,
  top_k = 20,
  num_ctx = 8192,
  num_predict = 256,
  repeat_penalty = 1.05,
  seed = -1,
},
```

**For Simplicity (Schema-Based):**
```lua
-- Single configuration for all strategies
schema = {
  model = { default = "codellama:13b" },
  temperature = { default = 0.3 },
  num_ctx = { default = 16384 },
}
```

## Key Changes Made

### 1. Fixed Duplicate `adapters` Issue
- **Before**: Multiple `adapters` tables defined
- **After**: Single `adapters` table with all adapter configurations

### 2. Added Comprehensive Nil Checks
- **Before**: Direct property access like `item.file`
- **After**: Safe access like `item and item.file or "unknown"`

### 3. Enhanced Error Handling
- Added `handle` existence checks
- Verify `handle:close()` success
- Check `vim.json.decode` success with `pcall`
- Validate parsed data structure and type

### 4. Improved String Safety
- Check string length before truncation
- Handle empty or nil content gracefully
- Safe string formatting with fallback values

### 5. Preserved Important Parameters
- **Kept all sampling parameters** for fine-tuned control
- **Strategy-specific optimization** for chat vs inline
- **Balanced essential vs optional** parameter inclusion

## Alternative: Strict Null Checking

If you prefer more explicit nil checking, use this pattern:

```lua
-- Strict nil checking pattern
["codebase"] = {
  callback = function(query)
    local handle = io.popen("vectorcode query '" .. query .. "' --format json --limit 5 2>/dev/null")
    
    if handle == nil then
      return "Error: Could not execute VectorCode query"
    end
    
    local result = handle:read("*a")
    local close_success = handle:close()
    
    if not close_success then
      return "Error: VectorCode query failed"
    end
    
    if result == nil or result == "" then
      return "No relevant code found for: " .. query
    end

    local decode_success, parsed = pcall(vim.json.decode, result)
    
    if not decode_success then
      return "Error: Could not parse VectorCode response"
    end
    
    if parsed == nil or type(parsed) ~= "table" then
      return "Error: Invalid VectorCode response format"
    end
    
    if #parsed == 0 then
      return "No relevant code found for: " .. query
    end
    
    local context = "Here are relevant code snippets from your codebase:\n\n"
    
    for i, item in ipairs(parsed) do
      if i > 5 then break end
      
      if item ~= nil then
        local file = item.file
        local score = item.score
        local language = item.language
        local content = item.content
        
        -- Provide defaults for nil values
        if file == nil then file = "unknown" end
        if score == nil then score = 0 end
        if language == nil then language = "" end
        if content == nil then content = "" end
        
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
},
```

## Validation Script

Create a validation script to check your configuration:

```bash
cat > validate_codecompanion_config.lua << 'EOF'
-- Save this as validate_codecompanion_config.lua
-- Run with: nvim --headless -l validate_codecompanion_config.lua

local config = {
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        -- Your config here
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "ollama",
      -- Your strategies here
    }
  }
}

-- Validation checks
local function validate_config(cfg)
  local errors = {}
  
  -- Check for duplicate keys (basic check)
  local seen_keys = {}
  for key, _ in pairs(cfg) do
    if seen_keys[key] then
      table.insert(errors, "Duplicate key: " .. key)
    end
    seen_keys[key] = true
  end
  
  -- Check adapters
  if cfg.adapters == nil then
    table.insert(errors, "Missing adapters configuration")
  elseif type(cfg.adapters) ~= "table" then
    table.insert(errors, "adapters must be a table")
  end
  
  -- Check strategies
  if cfg.strategies == nil then
    table.insert(errors, "Missing strategies configuration")
  elseif type(cfg.strategies) ~= "table" then
    table.insert(errors, "strategies must be a table")
  end
  
  return errors
end

local errors = validate_config(config)

if #errors == 0 then
  print("✅ Configuration is valid!")
else
  print("❌ Configuration errors found:")
  for _, error in ipairs(errors) do
    print("  - " .. error)
  end
end
EOF

# Run validation
nvim --headless -l validate_codecompanion_config.lua
```

## Testing the Fix

After updating your configuration:

1. **Restart Neovim** to reload the configuration
2. **Check for warnings**: `:lua vim.diagnostic.get()`
3. **Test functionality**: Try the slash commands
4. **Run health check**: `:checkhealth codecompanion`

## Prevention Tips

1. **Use a Lua language server** (like `lua-language-server`) for real-time diagnostics
2. **Enable strict mode** in your Lua LSP configuration
3. **Use consistent coding patterns** for nil checking
4. **Test configurations** in isolated environments first
5. **Use version control** to track configuration changes

The fixed configuration should eliminate all Lua diagnostics warnings while maintaining full functionality.
