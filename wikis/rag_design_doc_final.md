# VectorCode + CodeCompanion + Ollama Integration Design Document

## Executive Summary

This document outlines the implementation of a fully local AI-powered development environment using VectorCode for repository-level RAG, CodeCompanion for chat interface, and Ollama for local LLM inference. This solution provides complete privacy, offline capability, and intelligent code assistance enhanced by semantic search across your entire codebase.

## System Architecture

### High-Level Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Local         │    │   VectorCode     │    │   Neovim        │
│   Codebase      │───▶│   (RAG System)   │◀───│   CodeCompanion │
│   Documents     │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   ChromaDB       │    │   Ollama        │
                       │   (Vector Store) │    │   (Local LLM)   │
                       └──────────────────┘    └─────────────────┘
```

### Core Components

1. **Ollama**: Local LLM inference server
2. **VectorCode**: Repository indexing and semantic search
3. **ChromaDB**: Vector database for embeddings storage
4. **CodeCompanion**: Neovim chat interface and LLM integration
5. **Integration Layer**: Slash commands and workflow orchestration

## Detailed Design

### 1. Ollama Configuration

#### 1.1 Model Selection Strategy
**Primary Models for Different Tasks:**

| Task | Model | Size | Purpose |
|------|-------|------|---------|
| Code Generation | `codellama:13b` | 7.3GB | High-quality code completion |
| Code Explanation | `codellama:instruct` | 7.3GB | Instruction-following for explanations |
| General Chat | `llama3.1:8b` | 4.7GB | Natural conversation and planning |
| Embeddings | `nomic-embed-text` | 274MB | Vector embeddings for RAG |
| Fast Completion | `codellama:7b` | 3.8GB | Quick responses for simple queries |

#### 1.2 Ollama Server Configuration
```bash
# Ollama service configuration
export OLLAMA_HOST=127.0.0.1:11434
export OLLAMA_MODELS=/path/to/local/models
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=3
export OLLAMA_KEEP_ALIVE=5m
```

#### 1.3 Model Management Scripts
```bash
#!/bin/bash
# setup-ollama-models.sh

# Download core models
ollama pull codellama:13b
ollama pull codellama:7b  
ollama pull codellama:instruct
ollama pull llama3.1:8b
ollama pull nomic-embed-text

# Verify models
ollama list
```

### 2. VectorCode Implementation

#### 2.1 Project Structure and Configuration
```json
// ~/.config/vectorcode/config.json
{
  "embedding_function": "OllamaEmbeddingFunction",
  "embedding_params": {
    "url": "http://127.0.0.1:11434/api/embeddings",
    "model_name": "nomic-embed-text"
  },
  "host": "localhost",
  "port": 8000,
  "chunk_size": 512,
  "chunk_overlap": 50,
  "supported_extensions": [
    ".py", ".js", ".ts", ".lua", ".go", ".rs", 
    ".java", ".cpp", ".c", ".h", ".md", ".txt"
  ]
}
```

#### 2.2 Indexing Workflow
```bash
# Initialize ChromaDB (runs locally)
docker run -d -p 8000:8000 --name chromadb chromadb/chroma

# Index project repositories
cd ~/projects/my-app
vectorcode vectorise --project_root . --recursive

# Update existing index (incremental)
vectorcode update

# Query for testing
vectorcode query "authentication middleware" -n 5
```

#### 2.3 Multi-Project Management
```bash
# Index multiple projects with different weights
vectorcode vectorise --project_root ~/projects/backend --collection backend
vectorcode vectorise --project_root ~/projects/frontend --collection frontend  
vectorcode vectorise --project_root ~/docs --collection documentation

# List all collections
vectorcode ls --pipe
```

### 3. CodeCompanion Integration

#### 3.1 Plugin Configuration
```lua
-- plugins/codecompanion.lua
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "Davidyz/VectorCode",
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
            }
          },
          slash_commands = {
            -- VectorCode integration
            ["codebase"] = {
              callback = require("vectorcode.integrations").codecompanion.chat.make_slash_command({
                max_num = 8,
                default_num = 5
              }),
              description = "Search codebase with RAG",
              opts = { contains_code = true }
            },
            -- Custom project-specific commands
            ["docs"] = {
              callback = function(query)
                return require("vectorcode").query(query, {
                  collection = "documentation",
                  n_query = 3
                })
              end,
              description = "Search documentation",
            },
            ["backend"] = {
              callback = function(query)
                return require("vectorcode").query(query, {
                  collection = "backend", 
                  n_query = 5
                })
              end,
              description = "Search backend code",
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

#### 3.2 VectorCode Neovim Plugin Configuration
```lua
-- plugins/vectorcode.lua
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
```

### 4. Workflow Integration

#### 4.1 Enhanced Keybindings
```lua
-- lua/config/keymaps.lua
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
  local filetype = vim.bo.filetype
  vim.cmd("CodeCompanionChat")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("/codebase how does " .. filename .. " work", "n", false)
  end, 100)
end, "Explain current file")

-- VectorCode management
map("n", "<leader>vr", "<cmd>VectorCode register<cr>", "Register buffer with VectorCode")
map("n", "<leader>vu", "<cmd>VectorCode update<cr>", "Update VectorCode index")
map("n", "<leader>vq", function()
  local query = vim.fn.input("VectorCode query: ")
  if query ~= "" then
    vim.cmd("VectorCode query " .. query)
  end
end, "Direct VectorCode query")
```

#### 4.2 Automated Workflows
```lua
-- lua/config/autocmds.lua

-- Auto-register buffers with VectorCode
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java" },
  callback = function()
    -- Register buffer for RAG caching
    vim.schedule(function()
      require("vectorcode").register()
    end)
  end,
})

-- Auto-update index when files change (debounced)
local update_timer = nil
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java" },
  callback = function()
    if update_timer then
      update_timer:stop()
    end
    update_timer = vim.defer_fn(function()
      vim.system({ "vectorcode", "update" }, { detach = true })
    end, 5000) -- 5 second delay
  end,
})
```

### 5. Advanced Features

#### 5.1 Custom Slash Commands
```lua
-- Advanced slash command implementations
local function make_custom_commands()
  return {
    -- Search specific file types
    ["tests"] = {
      callback = function(query)
        return require("vectorcode").query(query .. " test", {
          file_patterns = { "*test*", "*spec*" },
          n_query = 3
        })
      end,
      description = "Search test files",
    },
    
    -- Search by language
    ["python"] = {
      callback = function(query)
        return require("vectorcode").query(query, {
          file_patterns = { "*.py" },
          n_query = 5
        })
      end,
      description = "Search Python files",
    },
    
    -- Recent changes
    ["recent"] = {
      callback = function(query)
        -- Get files modified in last 7 days
        local recent_files = vim.fn.systemlist(
          "find . -name '*.py' -o -name '*.js' -o -name '*.ts' | xargs ls -lt | head -20"
        )
        return require("vectorcode").query(query, {
          filter_files = recent_files,
          n_query = 4
        })
      end,
      description = "Search recently modified files",
    }
  }
end
```

#### 5.2 Model Selection Logic
```lua
-- Dynamic model selection based on query type
local function select_model(query, context)
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

-- Override adapter model selection
local function dynamic_adapter()
  return require("codecompanion.adapters").extend("ollama", {
    name = "ollama_dynamic",
    url = "http://127.0.0.1:11434",
    model_selection = select_model,
    -- ... rest of config
  })
end
```

### 6. Performance Optimization

#### 6.1 Caching Strategy
```lua
-- lua/vectorcode-cache.lua
local M = {}

local cache = {}
local cache_ttl = 300 -- 5 minutes

function M.get_cached_result(query_hash)
  local entry = cache[query_hash]
  if entry and (os.time() - entry.timestamp) < cache_ttl then
    return entry.result
  end
  return nil
end

function M.cache_result(query_hash, result)
  cache[query_hash] = {
    result = result,
    timestamp = os.time()
  }
end

function M.invalidate_cache()
  cache = {}
end

return M
```

#### 6.2 Query Optimization
```lua
-- Optimize VectorCode queries for performance
local function optimized_codebase_search(query, opts)
  opts = opts or {}
  
  -- Limit context size to prevent overwhelming LLM
  local max_chunks = opts.max_chunks or 6
  local max_chars = opts.max_chars or 8000
  
  -- Use semantic similarity threshold
  local min_similarity = opts.min_similarity or 0.3
  
  -- Get results from VectorCode
  local results = require("vectorcode").query(query, {
    n_query = max_chunks * 2, -- Get extra for filtering
    project_root = opts.project_root,
    collection = opts.collection
  })
  
  -- Filter and truncate results
  local filtered_results = {}
  local total_chars = 0
  
  for _, result in ipairs(results) do
    if total_chars + #result.content < max_chars then
      table.insert(filtered_results, result)
      total_chars = total_chars + #result.content
    else
      break
    end
  end
  
  return filtered_results
end
```

### 7. Implementation Timeline

#### Phase 1: Core Setup (Week 1)
- [ ] Install and configure Ollama with required models
- [ ] Set up ChromaDB vector database
- [ ] Install VectorCode CLI and index initial projects
- [ ] Basic CodeCompanion configuration

#### Phase 2: Integration Development (Week 2)
- [ ] Configure VectorCode Neovim plugin
- [ ] Implement CodeCompanion + VectorCode integration
- [ ] Set up slash commands and basic workflows
- [ ] Test end-to-end RAG queries

#### Phase 3: Advanced Features (Week 3)
- [ ] Custom slash commands for different project types
- [ ] Dynamic model selection logic
- [ ] Performance optimization and caching
- [ ] Automated index updates

#### Phase 4: Workflow Optimization (Week 4)
- [ ] Advanced keybindings and shortcuts
- [ ] Context-aware assistance features
- [ ] Multi-project management
- [ ] Documentation and troubleshooting guides

### 8. Directory Structure

```
~/.config/nvim/
├── lua/
│   ├── plugins/
│   │   ├── codecompanion.lua
│   │   ├── vectorcode.lua
│   │   └── ollama-models.lua
│   ├── config/
│   │   ├── keymaps.lua
│   │   ├── autocmds.lua
│   │   └── vectorcode-workflows.lua
│   └── utils/
│       ├── vectorcode-cache.lua
│       └── model-selection.lua

~/.config/vectorcode/
├── config.json
└── projects/
    ├── backend.collection
    ├── frontend.collection
    └── docs.collection

~/scripts/
├── setup-ollama-models.sh
├── index-projects.sh
└── update-vectorcode.sh
```

### 9. Monitoring and Maintenance

#### 9.1 Health Checks
```lua
-- Health check command
vim.api.nvim_create_user_command("VectorCodeHealth", function()
  local health = {}
  
  -- Check Ollama connection
  local ollama_status = vim.system({"curl", "-s", "http://127.0.0.1:11434/api/tags"}):wait()
  health.ollama = ollama_status.code == 0
  
  -- Check VectorCode CLI
  local vectorcode_status = vim.system({"vectorcode", "--version"}):wait()
  health.vectorcode = vectorcode_status.code == 0
  
  -- Check ChromaDB
  local chroma_status = vim.system({"curl", "-s", "http://localhost:8000/api/v1/heartbeat"}):wait()
  health.chromadb = chroma_status.code == 0
  
  -- Display results
  for component, status in pairs(health) do
    local icon = status and "✅" or "❌"
    print(string.format("%s %s: %s", icon, component, status and "OK" or "ERROR"))
  end
end, {})
```

#### 9.2 Automated Maintenance
```bash
#!/bin/bash
# maintenance.sh - Run weekly

# Update VectorCode CLI
pipx upgrade vectorcode

# Update project indexes
for project in ~/projects/*/; do
  cd "$project"
  if [ -d ".git" ]; then
    echo "Updating index for $project"
    vectorcode update
  fi
done

# Clean up old ChromaDB data
docker exec chromadb chroma utils compact

# Restart Ollama to clear memory
systemctl --user restart ollama
```

### 10. Benefits Summary

#### **Complete Privacy & Control**
- All processing happens locally on your machine
- No data transmission to external services
- Full control over models and behavior

#### **Enhanced Development Experience**
- Context-aware code assistance from your actual codebase
- Semantic search across all your projects
- Natural language queries about your code

#### **Cost Effective**
- No API fees or subscriptions
- One-time setup with ongoing local operation
- Scales with your hardware, not your wallet

#### **Offline Capability**
- Works without internet connection
- Fast local inference and retrieval
- No dependency on external service availability

## Conclusion

This VectorCode + CodeCompanion + Ollama integration provides a powerful, private, and cost-effective AI development environment. By combining semantic code search with local LLM inference, developers get intelligent assistance that understands their specific codebase without compromising privacy or requiring ongoing costs.

The system offers the sophistication of commercial AI coding tools while maintaining complete local control and offline capability. The modular design allows for easy customization and extension based on specific development workflows and requirements.