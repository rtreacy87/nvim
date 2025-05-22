# Neovim Integration

Now that we have a working code understanding system, we need to integrate it with Neovim to create a seamless coding experience. In this guide, we'll develop a Neovim plugin that provides code completions and an interactive chat interface.

## Understanding Neovim Plugin Development

Neovim plugins can be written in Lua or VimScript, with Lua being the preferred option for modern plugins. Our plugin will:

1. Connect to our code understanding system via its API
2. Provide code completions as you type
3. Offer an interactive chat interface for code questions
4. Integrate with Neovim's UI for a seamless experience

## Setting Up the Plugin Structure

Let's create the basic structure for our Neovim plugin:

```bash
mkdir -p ~/.local/share/nvim/site/pack/local-ai/start/local-ai.nvim
cd ~/.local/share/nvim/site/pack/local-ai/start/local-ai.nvim

# Create the plugin directory structure
mkdir -p lua/local-ai plugin doc
```

## Creating the Plugin Files

### 1. Plugin Initialization

First, let's create the main plugin file:

```lua
-- lua/local-ai/init.lua
local M = {}

-- Default configuration
M.config = {
  server = {
    host = "localhost",
    port = 8000,
  },
  models = {
    completion = "code-assistant",
    chat = "code-assistant",
  },
  keymaps = {
    accept_completion = "<Tab>",
    show_completion = "<C-Space>",
    open_chat = "<leader>ai",
    close_chat = "<leader>ac",
  },
  completion = {
    enabled = true,
    auto_trigger = true,
    trigger_characters = {".", ":", "(", ",", " "},
    max_suggestions = 3,
  },
  chat = {
    enabled = true,
    window_width = 60,
    window_position = "right", -- "left", "right", "top", "bottom"
  },
}

-- Setup function to be called by the user
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Initialize components
  require("local-ai.completion").setup(M.config)
  require("local-ai.chat").setup(M.config)
  
  -- Create user commands
  vim.api.nvim_create_user_command("LocalAIChat", function(opts)
    require("local-ai.chat").open(opts.args)
  end, { nargs = "?" })
  
  vim.api.nvim_create_user_command("LocalAIComplete", function()
    require("local-ai.completion").trigger()
  end, {})
  
  vim.api.nvim_create_user_command("LocalAIToggle", function()
    if M.config.completion.enabled then
      M.config.completion.enabled = false
      print("Local AI completions disabled")
    else
      M.config.completion.enabled = true
      print("Local AI completions enabled")
    end
  end, {})
end

return M
```

### 2. API Client

Next, let's create an API client to communicate with our code understanding system:

```lua
-- lua/local-ai/api.lua
local curl = require("plenary.curl")
local json = require("local-ai.json")

local M = {}
local config = {}

function M.setup(cfg)
  config = cfg.server
end

function M.get_completion(prompt, current_file, current_code, callback)
  local url = string.format("http://%s:%d/complete", config.host, config.port)
  
  local data = {
    prompt = prompt,
    current_file = current_file,
    current_code = current_code,
    model = config.models.completion
  }
  
  curl.post({
    url = url,
    body = json.encode(data),
    headers = {
      ["Content-Type"] = "application/json",
    },
    callback = function(response)
      if response.status ~= 200 then
        vim.schedule(function()
          callback({ error = "Failed to get completion" })
        end)
        return
      end
      
      local result = json.decode(response.body)
      vim.schedule(function()
        callback(result)
      end)
    end
  })
end

function M.chat(query, current_file, current_code, callback)
  local url = string.format("http://%s:%d/chat", config.host, config.port)
  
  local data = {
    query = query,
    current_file = current_file,
    current_code = current_code,
    model = config.models.chat
  }
  
  curl.post({
    url = url,
    body = json.encode(data),
    headers = {
      ["Content-Type"] = "application/json",
    },
    callback = function(response)
      if response.status ~= 200 then
        vim.schedule(function()
          callback({ error = "Failed to get chat response" })
        end)
        return
      end
      
      local result = json.decode(response.body)
      vim.schedule(function()
        callback(result)
      end)
    end
  })
end

return M
```

### 3. Completion Provider

Now, let's implement the completion provider:

```lua
-- lua/local-ai/completion.lua
local api = require("local-ai.api")

local M = {}
local config = {}
local ns_id = vim.api.nvim_create_namespace("local_ai_completion")
local current_completion = nil
local completion_visible = false

function M.setup(cfg)
  config = cfg
  api.setup(cfg)
  
  -- Set up autocommands for triggering completions
  if config.completion.enabled and config.completion.auto_trigger then
    vim.api.nvim_create_autocmd("InsertCharPre", {
      pattern = "*",
      callback = function()
        local char = vim.v.char
        if vim.tbl_contains(config.completion.trigger_characters, char) then
          -- Schedule completion after the character is inserted
          vim.schedule(function()
            M.trigger()
          end)
        end
      end
    })
  end
  
  -- Set up keymaps
  vim.keymap.set("i", config.keymaps.show_completion, function()
    M.trigger()
  end, { noremap = true, silent = true })
  
  vim.keymap.set("i", config.keymaps.accept_completion, function()
    if completion_visible and current_completion then
      M.accept_completion()
    else
      -- Pass through the Tab key if no completion is visible
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
    end
  end, { noremap = true, silent = true })
end

function M.trigger()
  if not config.completion.enabled then
    return
  end
  
  -- Clear any existing completion
  M.clear_completion()
  
  -- Get current buffer and cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-indexed
  
  -- Get current line and text before cursor
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  local text_before_cursor = line:sub(1, col)
  
  -- Get current file path and content
  local current_file = vim.fn.expand("%:p")
  local current_code = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  
  -- Request completion
  api.get_completion(text_before_cursor, current_file, current_code, function(result)
    if result.error then
      vim.notify("Completion error: " .. result.error, vim.log.levels.ERROR)
      return
    end
    
    if not result.completion or result.completion == "" then
      return
    end
    
    -- Store the completion
    current_completion = result.completion
    
    -- Display the completion as virtual text
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, col, {
      virt_text = {{result.completion, "Comment"}},
      virt_text_pos = "inline",
    })
    
    completion_visible = true
  end)
end

function M.accept_completion()
  if not current_completion or not completion_visible then
    return
  end
  
  -- Insert the completion text
  vim.api.nvim_put({current_completion}, "c", true, true)
  
  -- Clear the completion
  M.clear_completion()
end

function M.clear_completion()
  if completion_visible then
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    current_completion = nil
    completion_visible = false
  end
end

return M
```

### 4. Chat Interface

Finally, let's implement the chat interface:

```lua
-- lua/local-ai/chat.lua
local api = require("local-ai.api")

local M = {}
local config = {}
local chat_bufnr = nil
local chat_winid = nil
local chat_history = {}

function M.setup(cfg)
  config = cfg
  api.setup(cfg)
  
  -- Set up keymaps
  vim.keymap.set("n", config.keymaps.open_chat, function()
    M.open()
  end, { noremap = true, silent = true })
  
  vim.keymap.set("n", config.keymaps.close_chat, function()
    M.close()
  end, { noremap = true, silent = true })
end

function M.open(initial_query)
  if chat_winid and vim.api.nvim_win_is_valid(chat_winid) then
    vim.api.nvim_set_current_win(chat_winid)
    return
  end
  
  -- Create a new buffer for the chat
  chat_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(chat_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(chat_bufnr, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(chat_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(chat_bufnr, "filetype", "markdown")
  vim.api.nvim_buf_set_name(chat_bufnr, "LocalAI Chat")
  
  -- Create a window for the chat
  local width = config.chat.window_width
  local height = vim.o.lines - 4
  
  local col = 0
  local row = 0
  
  if config.chat.window_position == "right" then
    col = vim.o.columns - width
  elseif config.chat.window_position == "bottom" then
    row = vim.o.lines - height
    width = vim.o.columns
    height = math.floor(vim.o.lines / 3)
  elseif config.chat.window_position == "top" then
    width = vim.o.columns
    height = math.floor(vim.o.lines / 3)
  end
  
  chat_winid = vim.api.nvim_open_win(chat_bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(chat_winid, "wrap", true)
  vim.api.nvim_win_set_option(chat_winid, "linebreak", true)
  vim.api.nvim_win_set_option(chat_winid, "number", false)
  
  -- Initialize the chat buffer
  M.initialize_chat_buffer()
  
  -- If an initial query was provided, send it
  if initial_query and initial_query ~= "" then
    M.send_message(initial_query)
  end
end

function M.initialize_chat_buffer()
  -- Add welcome message
  local welcome_message = {
    "# Local AI Chat",
    "",
    "Welcome to Local AI Chat! Ask questions about your code or request assistance.",
    "",
    "Type your message below and press Enter to send.",
    "",
    "---",
    "",
    "> "
  }
  
  vim.api.nvim_buf_set_lines(chat_bufnr, 0, -1, false, welcome_message)
  
  -- Set cursor at the input line
  vim.api.nvim_win_set_cursor(chat_winid, {#welcome_message, 2})
  
  -- Set up buffer-local keymaps
  vim.api.nvim_buf_set_keymap(chat_bufnr, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function()
      M.handle_enter()
    end
  })
  
  vim.api.nvim_buf_set_keymap(chat_bufnr, "i", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function()
      M.handle_enter()
    end
  })
  
  -- Enter insert mode
  vim.cmd("startinsert!")
end

function M.handle_enter()
  -- Get the current line
  local line = vim.api.nvim_get_current_line()
  
  -- Check if it's an input line
  if line:sub(1, 2) == "> " then
    local message = line:sub(3)
    if message and message:gsub("%s+", "") ~= "" then
      M.send_message(message)
    end
  end
end

function M.send_message(message)
  -- Add user message to chat history
  table.insert(chat_history, {role = "user", content = message})
  
  -- Update the chat buffer
  local lines = vim.api.nvim_buf_get_lines(chat_bufnr, 0, -1, false)
  local last_line_idx = #lines
  
  -- Replace the current input line with the user message
  lines[last_line_idx] = "> " .. message
  
  -- Add a loading indicator
  table.insert(lines, "")
  table.insert(lines, "AI is thinking...")
  table.insert(lines, "")
  table.insert(lines, "> ")
  
  vim.api.nvim_buf_set_lines(chat_bufnr, 0, -1, false, lines)
  
  -- Get current file and code
  local current_file = vim.fn.expand("%:p")
  local current_code = ""
  local current_buf = vim.api.nvim_get_current_buf()
  
  if current_buf ~= chat_bufnr then
    current_code = table.concat(vim.api.nvim_buf_get_lines(current_buf, 0, -1, false), "\n")
  end
  
  -- Send the message to the API
  api.chat(message, current_file, current_code, function(result)
    if result.error then
      vim.notify("Chat error: " .. result.error, vim.log.levels.ERROR)
      return
    end
    
    -- Add AI response to chat history
    table.insert(chat_history, {role = "assistant", content = result.response})
    
    -- Update the chat buffer
    lines = vim.api.nvim_buf_get_lines(chat_bufnr, 0, -1, false)
    
    -- Remove the loading indicator
    table.remove(lines, #lines)
    table.remove(lines, #lines)
    table.remove(lines, #lines)
    
    -- Add the AI response
    table.insert(lines, "")
    table.insert(lines, "**AI:**")
    
    -- Split the response into lines and add them
    local response_lines = vim.split(result.response, "\n")
    for _, line in ipairs(response_lines) do
      table.insert(lines, line)
    end
    
    -- Add a new input line
    table.insert(lines, "")
    table.insert(lines, "> ")
    
    vim.api.nvim_buf_set_lines(chat_bufnr, 0, -1, false, lines)
    
    -- Set cursor at the new input line
    vim.api.nvim_win_set_cursor(chat_winid, {#lines, 2})
    
    -- Enter insert mode
    vim.cmd("startinsert!")
  end)
end

function M.close()
  if chat_winid and vim.api.nvim_win_is_valid(chat_winid) then
    vim.api.nvim_win_close(chat_winid, true)
    chat_winid = nil
  end
end

return M
```

### 5. Plugin Entry Point

Create a plugin entry point file:

```lua
-- plugin/local-ai.lua
if vim.g.loaded_local_ai then
  return
end
vim.g.loaded_local_ai = true

-- Defer setup to allow user configuration
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if not vim.g.local_ai_setup_done then
      require("local-ai").setup({})
      vim.g.local_ai_setup_done = true
    end
  end,
  once = true,
})
```

### 6. Documentation

Create a help file for the plugin:

```text
*local-ai.txt*  Local AI Coding Assistant for Neovim

==============================================================================
CONTENTS                                                    *local-ai-contents*

    1. Introduction ........................... |local-ai-introduction|
    2. Installation ........................... |local-ai-installation|
    3. Configuration .......................... |local-ai-configuration|
    4. Usage .................................. |local-ai-usage|
    5. Commands ............................... |local-ai-commands|
    6. Mappings ............................... |local-ai-mappings|
    7. API .................................... |local-ai-api|

==============================================================================
1. INTRODUCTION                                         *local-ai-introduction*

Local AI is a Neovim plugin that provides AI-powered code completions and chat
assistance using locally-run language models. It connects to a local API server
that provides context-aware code understanding.

==============================================================================
2. INSTALLATION                                         *local-ai-installation*

Using a plugin manager like packer.nvim:
>
    use {
        'username/local-ai.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            require('local-ai').setup({
                -- Your configuration here
            })
        end
    }
<

==============================================================================
3. CONFIGURATION                                       *local-ai-configuration*

Default configuration:
>
    require('local-ai').setup({
        server = {
            host = "localhost",
            port = 8000,
        },
        models = {
            completion = "code-assistant",
            chat = "code-assistant",
        },
        keymaps = {
            accept_completion = "<Tab>",
            show_completion = "<C-Space>",
            open_chat = "<leader>ai",
            close_chat = "<leader>ac",
        },
        completion = {
            enabled = true,
            auto_trigger = true,
            trigger_characters = {".", ":", "(", ",", " "},
            max_suggestions = 3,
        },
        chat = {
            enabled = true,
            window_width = 60,
            window_position = "right", -- "left", "right", "top", "bottom"
        },
    })
<

==============================================================================
4. USAGE                                                     *local-ai-usage*

Code Completions:
- As you type, completions will appear automatically after trigger characters
- Press <Tab> to accept a completion
- Press <C-Space> to manually trigger a completion

Chat Interface:
- Press <leader>ai to open the chat interface
- Type your question and press Enter to send
- Press <leader>ac to close the chat interface

==============================================================================
5. COMMANDS                                               *local-ai-commands*

:LocalAIChat [query]        Open the chat interface with an optional initial query
:LocalAIComplete            Manually trigger a completion
:LocalAIToggle              Toggle code completions on/off

==============================================================================
```

## Creating the API Server

To connect our Neovim plugin to our code understanding system, we need a simple API server:

```python
# api_server.py
from flask import Flask, request, jsonify
from rag_system import CodeRAG
import os
import argparse

app = Flask(__name__)
rag = None

@app.route('/complete', methods=['POST'])
def complete():
    data = request.json
    prompt = data.get('prompt', '')
    current_file = data.get('current_file', '')
    current_code = data.get('current_code', '')
    model = data.get('model', 'code-assistant')
    
    # Get a completion from the RAG system
    response = rag.process_query(
        f"Complete this code: {prompt}",
        n_results=3,
        current_file=current_file,
        current_code=current_code
    )
    
    # Extract just the completion part
    completion = response['response'].strip()
    
    # Remove any markdown code blocks
    if completion.startswith("```"):
        lines = completion.split("\n")
        if len(lines) > 1:
            # Remove the first line (```language)
            completion = "\n".join(lines[1:])
        if completion.endswith("```"):
            completion = completion[:-3]
    
    return jsonify({
        'completion': completion,
        'model': model
    })

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    query = data.get('query', '')
    current_file = data.get('current_file', '')
    current_code = data.get('current_code', '')
    model = data.get('model', 'code-assistant')
    
    # Get a response from the RAG system
    response = rag.process_query(
        query,
        n_results=5,
        current_file=current_file,
        current_code=current_code
    )
    
    return jsonify({
        'response': response['response'],
        'model': model,
        'query_type': response['processed_query']['query_type']
    })

def main():
    parser = argparse.ArgumentParser(description="Local AI API Server")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("--index-dir", default="./code_index", help="Directory where the index is stored")
    parser.add_argument("--model", default="code-assistant", help="The model to use for generation")
    parser.add_argument("--host", default="localhost", help="Host to run the server on")
    parser.add_argument("--port", type=int, default=8000, help="Port to run the server on")
    
    args = parser.parse_args()
    
    global rag
    rag = CodeRAG(args.repo_path, args.index_dir, args.model)
    
    print(f"Starting API server at http://{args.host}:{args.port}")
    app.run(host=args.host, port=args.port)

if __name__ == "__main__":
    main()
```

## Running the System

To use our local AI coding assistant:

1. Start the Ollama service:
   ```bash
   ollama serve
   ```

2. Start the API server:
   ```bash
   cd local-ai-assistant/code-understanding
   python api_server.py /path/to/your/repo --index-dir ./code_index --port 8000
   ```

3. Configure Neovim to use the plugin:
   ```lua
   -- In your init.lua
   require('local-ai').setup({
     server = {
       host = "localhost",
       port = 8000,
     },
     models = {
       completion = "code-assistant",
       chat = "code-assistant",
     },
     -- Other configuration options...
   })
   ```

4. Use the features in Neovim:
   - As you type, you'll see completions appear
   - Press `<Tab>` to accept completions
   - Press `<leader>ai` to open the chat interface
   - Ask questions about your code in the chat interface

## Next Steps

You've now built a complete local AI coding assistant with Neovim integration. In the next guide, we'll explore advanced features and optimizations to enhance your system.

Continue to [Advanced Features and Optimization](05-advanced-features.md).
