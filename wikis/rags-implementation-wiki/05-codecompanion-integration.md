# 05 - CodeCompanion Integration

## What is CodeCompanion?

CodeCompanion is a Neovim plugin that provides an AI-powered chat interface directly in your editor. For our RAGS system, it:

- **Provides chat interface** within Neovim
- **Integrates with Ollama** for local LLM inference
- **Supports slash commands** for VectorCode RAG queries
- **Shares context** from your current buffer and viewport
- **Enables inline assistance** for code generation and explanation

## Prerequisites

Before setting up CodeCompanion, ensure you have:

```bash
# Verify Neovim version (0.9+ required)
nvim --version | head -1

# Check if Lazy.nvim is installed
ls ~/.config/nvim/lua/ | grep lazy

# Verify Ollama is running
curl -s http://127.0.0.1:11434/api/tags

# Verify VectorCode is working
vectorcode --version

# Verify ChromaDB is running
curl -s http://localhost:8000/api/v1/heartbeat
```

## Installation

### Add CodeCompanion Plugin

Create or update your CodeCompanion plugin configuration:

```bash
# Create CodeCompanion plugin file
cat > ~/.config/nvim/lua/plugins/codecompanion.lua << 'EOF'
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- Optional
    "hrsh7th/nvim-cmp", -- Optional
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "ollama",
          roles = {
            llm = "CodeLlama",
            user = "Developer"
          },
          variables = {
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
            }
          },
          slash_commands = {
            -- VectorCode integration for codebase search
            ["codebase"] = {
              callback = function(query)
                -- Execute VectorCode query and return results
                local handle = io.popen("vectorcode query '" .. query .. "' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Here are relevant code snippets from your codebase:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 5 then -- Limit to top 5 results
                        context = context .. string.format(
                          "**File: %s** (similarity: %.2f)\n```%s\n%s\n```\n\n",
                          item.file or "unknown",
                          item.similarity or 0,
                          item.language or "",
                          item.content or ""
                        )
                      end
                    end
                    return context
                  end
                end
                return "No relevant code found for: " .. query
              end,
              description = "Search codebase with RAG",
              opts = { contains_code = true }
            },
            
            -- Quick documentation search
            ["docs"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " documentation' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Documentation search results:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 3 and (item.file:match("%.md$") or item.file:match("README")) then
                        context = context .. string.format(
                          "**%s**\n%s\n\n",
                          item.file,
                          item.content:sub(1, 500) .. (item.content:len() > 500 and "..." or "")
                        )
                      end
                    end
                    return context
                  end
                end
                return "No documentation found for: " .. query
              end,
              description = "Search documentation",
            },
            
            -- Search for tests
            ["tests"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " test' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Test-related code:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 3 and (item.file:match("test") or item.file:match("spec")) then
                        context = context .. string.format(
                          "**%s**\n```%s\n%s\n```\n\n",
                          item.file,
                          item.language or "",
                          item.content
                        )
                      end
                    end
                    return context
                  end
                end
                return "No test code found for: " .. query
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
              model = "codellama:13b",
              temperature = 0.2,
              top_p = 0.95,
              stop = { "<|endoftext|>", "<|im_end|>" }
            },
            inline = {
              model = "codellama:7b",
              temperature = 0.1,
              top_p = 0.9
            }
          })
        end,
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
      }
    })
  end,
}
EOF
```

### Add VectorCode Plugin

Create the VectorCode Neovim plugin configuration:

```bash
# Create VectorCode plugin file
cat > ~/.config/nvim/lua/plugins/vectorcode.lua << 'EOF'
return {
  "Davidyz/VectorCode",
  version = "*",
  build = "pipx upgrade vectorcode",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "VectorCode",
  config = function()
    require("vectorcode").setup({
      -- Automatically register buffers for async caching
      auto_register = true,
      
      -- Update embeddings on startup
      update = false,
      
      -- Start LSP server for fast queries
      lsp = true,
      
      -- Async options for cached queries
      async_opts = {
        auto_register = true,
        update = false,
        lsp = true
      },
      
      -- CLI integration
      cli = {
        binary = "vectorcode",
        timeout = 10000, -- 10 seconds
      }
    })
  end,
}
EOF
```

### Install Plugins

```bash
# Open Neovim and install plugins
nvim -c "Lazy sync" -c "qa"

# Or manually in Neovim
# :Lazy sync
```

## Configuration

### Enhanced Keybindings

Add RAGS-specific keybindings to your configuration:

```bash
# Create or update keymaps
cat >> ~/.config/nvim/lua/keymaps.lua << 'EOF'

-- RAGS System Keybindings
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true })
end

-- CodeCompanion + VectorCode workflows
map("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", "Open CodeCompanion Chat")
map("v", "<leader>cc", "<cmd>CodeCompanionChat<cr>", "Open Chat with Selection")
map("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", "CodeCompanion Actions")

-- Quick RAG queries
map("n", "<leader>cq", function()
  local query = vim.fn.input("Query codebase: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/codebase " .. query, "n", false)
    end, 100)
  end
end, "Quick codebase query")

-- Context-aware assistance
map("n", "<leader>ce", function()
  local filename = vim.fn.expand("%:t")
  vim.cmd("CodeCompanionChat")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("/codebase how does " .. filename .. " work", "n", false)
  end, 100)
end, "Explain current file")

-- Documentation search
map("n", "<leader>cd", function()
  local query = vim.fn.input("Search docs: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/docs " .. query, "n", false)
    end, 100)
  end
end, "Search documentation")

-- Test search
map("n", "<leader>ct", function()
  local query = vim.fn.input("Search tests: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/tests " .. query, "n", false)
    end, 100)
  end
end, "Search tests")

-- VectorCode management
map("n", "<leader>vr", "<cmd>VectorCode register<cr>", "Register buffer with VectorCode")
map("n", "<leader>vu", "<cmd>VectorCode update<cr>", "Update VectorCode index")
map("n", "<leader>vq", function()
  local query = vim.fn.input("VectorCode query: ")
  if query ~= "" then
    vim.cmd("VectorCode query " .. query)
  end
end, "Direct VectorCode query")
EOF
```

### Auto-commands for RAGS

Create auto-commands for seamless integration:

```bash
# Create or update autocmds
cat >> ~/.config/nvim/lua/config/autocmds.lua << 'EOF'

-- RAGS System Auto-commands

-- Auto-register buffers with VectorCode
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java", "*.cpp", "*.c", "*.h" },
  callback = function()
    -- Register buffer for RAG caching
    vim.schedule(function()
      local ok, vectorcode = pcall(require, "vectorcode")
      if ok then
        vectorcode.register()
      end
    end)
  end,
})

-- Auto-update index when files change (debounced)
local update_timer = nil
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java", "*.cpp", "*.c", "*.h" },
  callback = function()
    if update_timer then
      update_timer:stop()
    end
    update_timer = vim.defer_fn(function()
      vim.system({ "vectorcode", "update" }, { detach = true })
    end, 5000) -- 5 second delay
  end,
})

-- Show RAGS status in statusline
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Check if all RAGS components are running
    vim.defer_fn(function()
      local function check_service(url, name)
        vim.system({ "curl", "-s", url }, {
          on_exit = function(obj)
            if obj.code == 0 then
              vim.notify(name .. " is running", vim.log.levels.INFO)
            else
              vim.notify(name .. " is not responding", vim.log.levels.WARN)
            end
          end
        })
      end
      
      check_service("http://127.0.0.1:11434/api/tags", "Ollama")
      check_service("http://localhost:8000/api/v1/heartbeat", "ChromaDB")
    end, 1000)
  end,
})
EOF
```

## Testing the Integration

### Basic Functionality Test

```bash
# Create test script
cat > test_codecompanion_integration.sh << 'EOF'
#!/bin/bash

echo "🔍 Testing CodeCompanion + RAGS Integration..."

# Test 1: Check if plugins are loaded
echo "📦 Testing plugin installation..."
nvim --headless -c "lua print('CodeCompanion loaded:', pcall(require, 'codecompanion'))" -c "qa" 2>/dev/null
nvim --headless -c "lua print('VectorCode loaded:', pcall(require, 'vectorcode'))" -c "qa" 2>/dev/null

# Test 2: Check Ollama connection
echo "🤖 Testing Ollama connection..."
if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama is responding"
else
    echo "❌ Ollama is not responding"
fi

# Test 3: Check ChromaDB connection
echo "🗄️  Testing ChromaDB connection..."
if curl -s http://localhost:8000/api/v1/heartbeat > /dev/null; then
    echo "✅ ChromaDB is responding"
else
    echo "❌ ChromaDB is not responding"
fi

# Test 4: Check VectorCode CLI
echo "🔍 Testing VectorCode CLI..."
if vectorcode --version > /dev/null 2>&1; then
    echo "✅ VectorCode CLI is working"
else
    echo "❌ VectorCode CLI is not working"
fi

# Test 5: Test slash command functionality
echo "💬 Testing slash command integration..."
cd ~/test-vectorcode
if vectorcode query "fibonacci" --output json > /dev/null 2>&1; then
    echo "✅ VectorCode queries are working"
else
    echo "❌ VectorCode queries are failing"
fi

echo "✅ Integration test complete!"
EOF

chmod +x test_codecompanion_integration.sh
./test_codecompanion_integration.sh
```

### Interactive Test in Neovim

```bash
# Create a test file to demonstrate RAGS
cat > test_rags_demo.py << 'EOF'
# RAGS Demo File
# This file demonstrates the RAGS system capabilities

def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number using recursion."""
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def calculate_factorial(n):
    """Calculate the factorial of n."""
    if n <= 1:
        return 1
    return n * calculate_factorial(n-1)

class MathUtils:
    """Utility class for mathematical operations."""
    
    @staticmethod
    def is_prime(n):
        """Check if a number is prime."""
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    @staticmethod
    def gcd(a, b):
        """Calculate the greatest common divisor using Euclidean algorithm."""
        while b:
            a, b = b, a % b
        return a

if __name__ == "__main__":
    # Test the functions
    print(f"Fibonacci(10): {calculate_fibonacci(10)}")
    print(f"Factorial(5): {calculate_factorial(5)}")
    print(f"Is 17 prime? {MathUtils.is_prime(17)}")
    print(f"GCD(48, 18): {MathUtils.gcd(48, 18)}")
EOF

# Open in Neovim for testing
echo "🚀 Opening test file in Neovim..."
echo "Try these commands in CodeCompanion:"
echo "  /codebase fibonacci function"
echo "  /codebase how to calculate factorial"
echo "  /docs mathematical functions"
echo "  /tests prime number"

nvim test_rags_demo.py
```

## Advanced Configuration

### Dynamic Model Selection

Add intelligent model selection based on query type:

```bash
# Create advanced adapter configuration
cat > ~/.config/nvim/lua/config/rags-advanced.lua << 'EOF'
-- Advanced RAGS Configuration

local M = {}

-- Dynamic model selection based on query type
function M.select_model(query, context)
  local query_lower = query:lower()
  
  if query_lower:match("explain") or query_lower:match("how does") then
    return "codellama:instruct"
  elseif query_lower:match("implement") or query_lower:match("write") then
    return "codellama:13b"
  elseif query_lower:match("fix") or query_lower:match("debug") then
    return "codellama:13b"
  elseif #context > 2000 then
    return "codellama:13b" -- Use larger model for complex context
  else
    return "codellama:7b" -- Faster for simple queries
  end
end

-- Enhanced codebase search with filtering
function M.enhanced_codebase_search(query, opts)
  opts = opts or {}
  
  -- Build vectorcode command
  local cmd = {"vectorcode", "query", query, "--output", "json"}
  
  if opts.file_type then
    table.insert(cmd, "--file-type")
    table.insert(cmd, opts.file_type)
  end
  
  if opts.max_results then
    table.insert(cmd, "--num-results")
    table.insert(cmd, tostring(opts.max_results))
  end
  
  -- Execute query
  local handle = io.popen(table.concat(cmd, " ") .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  
  if result and result ~= "" then
    local success, parsed = pcall(vim.json.decode, result)
    if success and parsed then
      return M.format_search_results(parsed, opts)
    end
  end
  
  return "No relevant code found for: " .. query
end

-- Format search results for better readability
function M.format_search_results(results, opts)
  local max_results = opts.max_results or 5
  local max_chars = opts.max_chars or 8000
  
  local context = "Here are relevant code snippets from your codebase:\n\n"
  local total_chars = 0
  
  for i, item in ipairs(results) do
    if i > max_results or total_chars > max_chars then
      break
    end
    
    local snippet = string.format(
      "**File: %s** (similarity: %.2f)\n```%s\n%s\n```\n\n",
      item.file or "unknown",
      item.similarity or 0,
      item.language or "",
      item.content or ""
    )
    
    context = context .. snippet
    total_chars = total_chars + #snippet
  end
  
  return context
end

-- Custom slash commands
M.custom_slash_commands = {
  ["python"] = {
    callback = function(query)
      return M.enhanced_codebase_search(query, {
        file_type = "python",
        max_results = 5
      })
    end,
    description = "Search Python files",
    opts = { contains_code = true }
  },
  
  ["recent"] = {
    callback = function(query)
      -- Get recently modified files
      local handle = io.popen("find . -name '*.py' -o -name '*.js' -o -name '*.ts' | xargs ls -lt | head -10 | awk '{print $NF}'")
      local recent_files = handle:read("*a")
      handle:close()
      
      return M.enhanced_codebase_search(query .. " " .. recent_files, {
        max_results = 3
      })
    end,
    description = "Search recently modified files",
  }
}

return M
EOF
```

## What's Next?

Now that CodeCompanion is integrated with your RAGS system, you can start using the complete local AI development environment. 

In the next guide, we'll cover:
1. Basic daily workflows with RAGS
2. Common usage patterns and examples
3. Tips for effective prompting
4. Keyboard shortcuts and productivity tips

---

**Continue to:** [06 - Basic Workflows](06-basic-workflows.md)

**Need help?** Check the [Troubleshooting Guide](08-troubleshooting.md) for CodeCompanion-specific issues.
