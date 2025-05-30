# 07 - Advanced Features

## Custom Slash Commands

Create specialized slash commands for your specific development needs.

### Language-Specific Commands

```lua
-- Add to your CodeCompanion configuration
slash_commands = {
  -- Python-specific search
  ["python"] = {
    callback = function(query)
      local handle = io.popen("vectorcode query '" .. query .. "' --file-type python --output json 2>/dev/null")
      local result = handle:read("*a")
      handle:close()
      
      if result and result ~= "" then
        local success, parsed = pcall(vim.json.decode, result)
        if success and parsed then
          local context = "Python code search results:\n\n"
          for i, item in ipairs(parsed) do
            if i <= 5 then
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
      local cmd = string.format(
        "vectorcode query '%s' --file-pattern '*.js' --file-pattern '*.ts' --output json 2>/dev/null",
        query
      )
      local handle = io.popen(cmd)
      local result = handle:read("*a")
      handle:close()
      
      if result and result ~= "" then
        local success, parsed = pcall(vim.json.decode, result)
        if success and parsed then
          local context = "JavaScript/TypeScript search results:\n\n"
          for i, item in ipairs(parsed) do
            if i <= 5 then
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
```

### Project-Specific Commands

```lua
-- Commands tailored to your project structure
slash_commands = {
  -- Backend API search
  ["api"] = {
    callback = function(query)
      local cmd = string.format(
        "vectorcode query '%s API endpoint route' --collection backend --output json 2>/dev/null",
        query
      )
      local handle = io.popen(cmd)
      local result = handle:read("*a")
      handle:close()
      
      if result and result ~= "" then
        local success, parsed = pcall(vim.json.decode, result)
        if success and parsed then
          local context = "API endpoint search results:\n\n"
          for i, item in ipairs(parsed) do
            if i <= 3 and (item.file:match("routes") or item.file:match("api") or item.file:match("controller")) then
              context = context .. string.format(
                "**%s**\n```%s\n%s\n```\n\n",
                item.file, item.language or "", item.content
              )
            end
          end
          return context
        end
      end
      return "No API endpoints found for: " .. query
    end,
    description = "Search API endpoints and routes",
    opts = { contains_code = true }
  },
  
  -- Database/Model search
  ["db"] = {
    callback = function(query)
      local cmd = string.format(
        "vectorcode query '%s database model schema' --output json 2>/dev/null",
        query
      )
      local handle = io.popen(cmd)
      local result = handle:read("*a")
      handle:close()
      
      if result and result ~= "" then
        local success, parsed = pcall(vim.json.decode, result)
        if success and parsed then
          local context = "Database/Model search results:\n\n"
          for i, item in ipairs(parsed) do
            if i <= 4 and (item.file:match("model") or item.file:match("schema") or item.file:match("migration")) then
              context = context .. string.format(
                "**%s**\n```%s\n%s\n```\n\n",
                item.file, item.language or "", item.content
              )
            end
          end
          return context
        end
      end
      return "No database/model code found for: " .. query
    end,
    description = "Search database models and schemas",
    opts = { contains_code = true }
  }
}
```

## Dynamic Model Selection

Automatically choose the best model based on query complexity and type.

### Intelligent Model Router

```lua
-- Create model selection logic
local function create_dynamic_adapter()
  local function select_model(query, context)
    local query_lower = query:lower()
    local context_length = context and #context or 0
    
    -- Code explanation queries
    if query_lower:match("explain") or query_lower:match("how does") or query_lower:match("what is") then
      return "codellama:instruct"
    end
    
    -- Code generation queries
    if query_lower:match("implement") or query_lower:match("write") or query_lower:match("create") then
      return "codellama:13b"
    end
    
    -- Debugging and fixing
    if query_lower:match("fix") or query_lower:match("debug") or query_lower:match("error") then
      return "codellama:13b"
    end
    
    -- Complex analysis (large context)
    if context_length > 3000 then
      return "codellama:13b"
    end
    
    -- Simple queries and quick responses
    if context_length < 1000 and (
      query_lower:match("quick") or 
      query_lower:match("simple") or 
      #query < 50
    ) then
      return "codellama:7b"
    end
    
    -- Default to balanced model
    return "codellama:13b"
  end
  
  return require("codecompanion.adapters").extend("ollama", {
    name = "ollama_dynamic",
    url = "http://127.0.0.1:11434",
    headers = {
      ["Content-Type"] = "application/json",
    },
    parameters = {
      sync = true,
    },
    chat = {
      model = function(query, context)
        return select_model(query, context)
      end,
      temperature = 0.2,
      top_p = 0.95,
      stop = { "<|endoftext|>", "<|im_end|>" }
    },
    inline = {
      model = "codellama:7b", -- Always use fast model for inline
      temperature = 0.1,
      top_p = 0.9
    }
  })
end
```

## Performance Optimization

### Query Result Caching

```lua
-- Implement intelligent caching for VectorCode queries
local query_cache = {}
local cache_ttl = 300 -- 5 minutes

local function get_cache_key(query, options)
  local opts_str = vim.json.encode(options or {})
  return vim.fn.sha256(query .. opts_str)
end

local function get_cached_result(cache_key)
  local entry = query_cache[cache_key]
  if entry and (os.time() - entry.timestamp) < cache_ttl then
    return entry.result
  end
  return nil
end

local function cache_result(cache_key, result)
  query_cache[cache_key] = {
    result = result,
    timestamp = os.time()
  }
  
  -- Limit cache size
  local cache_size = 0
  for _ in pairs(query_cache) do
    cache_size = cache_size + 1
  end
  
  if cache_size > 100 then
    -- Remove oldest entries
    local oldest_key = nil
    local oldest_time = os.time()
    
    for key, entry in pairs(query_cache) do
      if entry.timestamp < oldest_time then
        oldest_time = entry.timestamp
        oldest_key = key
      end
    end
    
    if oldest_key then
      query_cache[oldest_key] = nil
    end
  end
end
```

## Workflow Automation

### Auto-Update System

```lua
-- Automatic index updates based on file changes
local update_timer = nil
local pending_updates = {}

local function schedule_update(file_path)
  -- Add to pending updates
  pending_updates[file_path] = true
  
  -- Cancel existing timer
  if update_timer then
    update_timer:stop()
  end
  
  -- Schedule batch update
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
      
      -- Clear pending updates
      pending_updates = {}
    end
  end, 5000) -- 5 second delay
end

-- Auto-update on file save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.py", "*.js", "*.ts", "*.lua", "*.go", "*.rs", "*.java", "*.cpp", "*.c", "*.h", "*.md" },
  callback = function(ev)
    schedule_update(ev.file)
  end,
})
```

## Advanced Keybindings

### Context-Aware Shortcuts

```lua
-- Advanced keybinding system
local function create_advanced_keybindings()
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true })
  end
  
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
    -- Get current function name using treesitter
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
  
  -- Error-specific help
  map("n", "<leader>ch", function()
    -- Get current line and look for error patterns
    local line = vim.api.nvim_get_current_line()
    local error_patterns = {
      "Error:", "Exception:", "Failed:", "Cannot:", "Unable:", "Invalid:"
    }
    
    local error_text = nil
    for _, pattern in ipairs(error_patterns) do
      local match = line:match(pattern .. "([^%s].*)")
      if match then
        error_text = match:gsub("^%s+", ""):gsub("%s+$", "")
        break
      end
    end
    
    if error_text then
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.api.nvim_feedkeys("/codebase fix " .. error_text, "n", false)
      end, 100)
    else
      vim.notify("No error pattern found on current line", vim.log.levels.WARN)
    end
  end, "Help with error on current line")
end

create_advanced_keybindings()
```

## What's Next?

You now have access to advanced RAGS features including custom slash commands, dynamic model selection, and workflow automation. 

In the next guide, we'll cover:
1. Common troubleshooting scenarios
2. Performance optimization tips
3. Maintenance and monitoring
4. Recovery procedures

---

**Continue to:** [08 - Troubleshooting](08-troubleshooting.md)

**Need help?** The troubleshooting guide covers advanced configuration issues.
