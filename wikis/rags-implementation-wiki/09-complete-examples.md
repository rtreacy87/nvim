# 09 - Complete Examples

## Full Working Configurations

This guide provides complete, tested configurations that you can copy and use directly.

## Complete CodeCompanion Configuration

### Full Plugin Configuration

```lua
-- ~/.config/nvim/lua/plugins/codecompanion.lua
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
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
            -- Main codebase search
            ["codebase"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. "' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Here are relevant code snippets from your codebase:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 5 then
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
            
            -- Documentation search
            ["docs"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " documentation' --file-pattern '*.md' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Documentation search results:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 3 then
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
            
            -- Test search
            ["tests"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " test' --file-pattern '*test*' --file-pattern '*spec*' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Test-related code:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 3 then
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
            },
            
            -- Python-specific search
            ["python"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. "' --file-pattern '*.py' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "Python code search results:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 4 then
                        context = context .. string.format(
                          "**%s** (%.2f)\n```python\n%s\n```\n\n",
                          item.file, item.similarity or 0, item.content
                        )
                      end
                    end
                    return context
                  end
                end
                return "No Python code found for: " .. query
              end,
              description = "Search Python files only",
              opts = { contains_code = true }
            },
            
            -- JavaScript/TypeScript search
            ["js"] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. "' --file-pattern '*.js' --file-pattern '*.ts' --output json 2>/dev/null")
                local result = handle:read("*a")
                handle:close()
                
                if result and result ~= "" then
                  local success, parsed = pcall(vim.json.decode, result)
                  if success and parsed then
                    local context = "JavaScript/TypeScript search results:\n\n"
                    for i, item in ipairs(parsed) do
                      if i <= 4 then
                        local lang = item.file:match("%.ts$") and "typescript" or "javascript"
                        context = context .. string.format(
                          "**%s** (%.2f)\n```%s\n%s\n```\n\n",
                          item.file, item.similarity or 0, lang, item.content
                        )
                      end
                    end
                    return context
                  end
                end
                return "No JavaScript/TypeScript code found for: " .. query
              end,
              description = "Search JavaScript and TypeScript files",
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
```

## Complete VectorCode Configuration

### VectorCode Plugin

```lua
-- ~/.config/nvim/lua/plugins/vectorcode.lua
return {
  "Davidyz/VectorCode",
  version = "*",
  build = "pipx upgrade vectorcode",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "VectorCode",
  config = function()
    require("vectorcode").setup({
      auto_register = true,
      update = false,
      lsp = true,
      async_opts = {
        auto_register = true,
        update = false,
        lsp = true
      },
      cli = {
        binary = "vectorcode",
        timeout = 10000,
      }
    })
  end,
}
```

### VectorCode Configuration File

```json
// ~/.config/vectorcode/config.json
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "vector_store": "chromadb",
  "chromadb_config": {
    "host": "localhost",
    "port": 8000,
    "persist_directory": "~/.local/share/chromadb"
  },
  "chunk_size": 512,
  "chunk_overlap": 50,
  "supported_extensions": [
    ".py", ".js", ".ts", ".lua", ".go", ".rs", 
    ".java", ".cpp", ".c", ".h", ".hpp", ".cc",
    ".md", ".txt", ".json", ".yaml", ".yml",
    ".sh", ".bash", ".zsh", ".fish", ".rb",
    ".php", ".cs", ".swift", ".kt", ".scala"
  ],
  "ignore_patterns": [
    "node_modules/",
    ".git/",
    "__pycache__/",
    "*.pyc",
    ".DS_Store",
    "target/",
    "build/",
    "dist/",
    ".venv/",
    "venv/",
    "vendor/",
    ".next/",
    ".nuxt/",
    "coverage/",
    "*.log",
    "*.tmp"
  ],
  "max_file_size": 1048576,
  "batch_size": 100
}
```

## Complete Keybinding Configuration

### Enhanced Keymaps

```lua
-- ~/.config/nvim/lua/config/rags-keymaps.lua
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true })
end

-- Core RAGS functionality
map("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", "Open CodeCompanion Chat")
map("v", "<leader>cc", "<cmd>CodeCompanionChat<cr>", "Open Chat with Selection")
map("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", "CodeCompanion Actions")

-- Quick queries
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

-- Language-specific searches
map("n", "<leader>cp", function()
  local query = vim.fn.input("Search Python code: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/python " .. query, "n", false)
    end, 100)
  end
end, "Search Python code")

map("n", "<leader>cj", function()
  local query = vim.fn.input("Search JS/TS code: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/js " .. query, "n", false)
    end, 100)
  end
end, "Search JavaScript/TypeScript")

-- Documentation and tests
map("n", "<leader>cd", function()
  local query = vim.fn.input("Search docs: ")
  if query ~= "" then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/docs " .. query, "n", false)
    end, 100)
  end
end, "Search documentation")

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

-- Smart context queries
map("n", "<leader>cs", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%:t")
  
  vim.cmd("CodeCompanionChat")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys(string.format("/codebase %s patterns in %s", filetype, filename), "n", false)
  end, 100)
end, "Search patterns in current file type")

-- Function-specific help
map("n", "<leader>cf", function()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  
  local function_name = nil
  while node do
    if node:type() == "function_definition" or node:type() == "method_definition" then
      local name_node = node:field("name")[1]
      if name_node then
        function_name = vim.treesitter.get_node_text(name_node, 0)
        break
      end
    end
    node = node:parent()
  end
  
  if function_name then
    vim.cmd("CodeCompanionChat")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys("/codebase " .. function_name .. " function", "n", false)
    end, 100)
  else
    vim.notify("No function found at cursor", vim.log.levels.WARN)
  end
end, "Search for current function")

-- System management
map("n", "<leader>rh", "<cmd>lua require('rags-health').check_health()<cr>", "RAGS Health Check")
map("n", "<leader>rs", "<cmd>lua require('rags-health').show_stats()<cr>", "RAGS Statistics")
```

## Complete Auto-commands Configuration

### RAGS Auto-commands

```lua
-- ~/.config/nvim/lua/config/rags-autocmds.lua

-- Auto-register buffers with VectorCode
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java", "*.cpp", "*.c", "*.h" },
  callback = function()
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
local pending_updates = {}

local function schedule_update(file_path)
  pending_updates[file_path] = true
  
  if update_timer then
    update_timer:stop()
  end
  
  update_timer = vim.defer_fn(function()
    local files_to_update = {}
    for file, _ in pairs(pending_updates) do
      table.insert(files_to_update, file)
    end
    
    if #files_to_update > 0 then
      vim.notify(string.format("Updating RAGS index for %d files...", #files_to_update), vim.log.levels.INFO)
      
      vim.system({"vectorcode", "update"}, {
        on_exit = function(obj)
          if obj.code == 0 then
            vim.notify("✅ RAGS index updated", vim.log.levels.INFO)
          else
            vim.notify("❌ Failed to update RAGS index", vim.log.levels.ERROR)
          end
        end
      })
      
      pending_updates = {}
    end
  end, 5000)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java", "*.cpp", "*.c", "*.h", "*.md" },
  callback = function(ev)
    schedule_update(ev.file)
  end,
})

-- Show RAGS status on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Check Ollama
      vim.system({ "curl", "-s", "http://127.0.0.1:11434/api/tags" }, {
        on_exit = function(obj)
          if obj.code == 0 then
            vim.notify("Ollama is running", vim.log.levels.INFO)
          else
            vim.notify("Ollama is not responding", vim.log.levels.WARN)
          end
        end
      })

      -- Check VectorCode
      vim.system({ "vectorcode", "check" }, {
        on_exit = function(obj)
          if obj.code == 0 then
            vim.notify("VectorCode is working", vim.log.levels.INFO)
          else
            vim.notify("VectorCode is not working", vim.log.levels.WARN)
          end
        end
      })
    end, 1000)
  end,
})
```

## Setup Scripts

### Complete Installation Script

```bash
#!/bin/bash
# complete-rags-setup.sh

set -e

echo "🚀 Starting Complete RAGS Setup..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    command -v nvim >/dev/null 2>&1 || { log_error "Neovim is required but not installed."; exit 1; }
    command -v python3 >/dev/null 2>&1 || { log_error "Python 3.11+ is required but not installed."; exit 1; }
    command -v curl >/dev/null 2>&1 || { log_error "curl is required but not installed."; exit 1; }

    # Check Python version
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ $(echo "$python_version >= 3.11" | bc -l) -eq 0 ]]; then
        log_error "Python 3.11+ is required. Found: $python_version"
        exit 1
    fi

    log_info "✅ Prerequisites check passed"
}

# Install Ollama
install_ollama() {
    log_info "Installing Ollama..."
    
    if command -v ollama >/dev/null 2>&1; then
        log_info "Ollama already installed"
    else
        curl -fsSL https://ollama.ai/install.sh | sh
    fi
    
    # Start Ollama
    ollama serve &
    sleep 5
    
    # Download models
    log_info "Downloading Ollama models..."
    ollama pull codellama:13b
    ollama pull codellama:7b
    ollama pull codellama:instruct
    ollama pull nomic-embed-text
    
    log_info "✅ Ollama setup complete"
}

# Setup VectorCode data directory
setup_vectorcode_data() {
    log_info "Setting up VectorCode data directory..."

    # Create data directory (VectorCode will use this for ChromaDB)
    mkdir -p ~/.local/share/vectorcode/chromadb

    log_info "✅ VectorCode data directory setup complete"
}

# Install VectorCode
install_vectorcode() {
    log_info "Installing VectorCode..."
    
    # Install with pipx
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    pipx install vectorcode
    
    # Create optional configuration for Ollama embeddings
    mkdir -p ~/.config/vectorcode
    cat > ~/.config/vectorcode/config.json << 'EOF'
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "chunk_size": 2500,
  "overlap_ratio": 0.2
}
EOF
    
    log_info "✅ VectorCode setup complete"
}

# Setup Neovim plugins
setup_neovim() {
    log_info "Setting up Neovim plugins..."
    
    # Create plugin directories
    mkdir -p ~/.config/nvim/lua/plugins
    mkdir -p ~/.config/nvim/lua/config
    
    # Copy configurations (assuming they exist in current directory)
    # You would copy the actual configuration files here
    
    log_info "✅ Neovim setup complete"
    log_warn "Please copy the plugin configurations manually"
}

# Test installation
test_installation() {
    log_info "Testing installation..."

    # Test Ollama
    if curl -s http://127.0.0.1:11434/api/tags >/dev/null; then
        log_info "✅ Ollama is responding"
    else
        log_error "❌ Ollama is not responding"
    fi

    # Test VectorCode
    if vectorcode version >/dev/null 2>&1; then
        log_info "✅ VectorCode is working"
    else
        log_error "❌ VectorCode is not working"
    fi

    # Test VectorCode functionality
    if vectorcode check >/dev/null 2>&1; then
        log_info "✅ VectorCode functionality is working"
    else
        log_error "❌ VectorCode functionality is not working"
    fi
}

# Main installation flow
main() {
    check_prerequisites
    install_ollama
    setup_vectorcode_data
    install_vectorcode
    setup_neovim
    test_installation

    log_info "🎉 RAGS setup complete!"
    log_info "Next steps:"
    log_info "1. Copy the Neovim plugin configurations"
    log_info "2. Run :Lazy sync in Neovim"
    log_info "3. Index your first project with: cd /path/to/project && vectorcode init && vectorcode vectorise ."
}

main "$@"
```

## Best Practices Summary

### Performance Optimization

1. **Use appropriate models for different tasks**
   - `codellama:7b` for simple queries and inline completion
   - `codellama:13b` for complex code generation
   - `codellama:instruct` for explanations

2. **Optimize VectorCode settings**
   - Adjust chunk size based on your codebase
   - Use ignore patterns to exclude unnecessary files
   - Regular index updates for accuracy

3. **Monitor resource usage**
   - Limit concurrent models in Ollama
   - Set memory limits for ChromaDB
   - Use caching for frequent queries

### Security Considerations

1. **Local-only processing** - All data stays on your machine
2. **Network isolation** - Can work completely offline
3. **Data encryption** - Consider encrypting ChromaDB storage
4. **Access control** - Secure your development environment

### Maintenance Schedule

1. **Daily**: Auto-update indexes on file changes
2. **Weekly**: Full health check and optimization
3. **Monthly**: Clean up old embeddings and logs
4. **Quarterly**: Update models and dependencies

## Conclusion

You now have a complete, working RAGS system that provides:

- 🔒 **Complete privacy** with local processing
- 🚀 **Intelligent code assistance** from your actual codebase
- 🔍 **Semantic search** across all your projects
- 💰 **Zero ongoing costs** after setup
- 🌐 **Offline capability** for anywhere development

The system is designed to grow with your needs and can be customized extensively based on your specific development workflows.

---

**Congratulations!** You've successfully implemented a complete local AI development environment. Start exploring your codebase with natural language queries and enjoy the enhanced development experience!
