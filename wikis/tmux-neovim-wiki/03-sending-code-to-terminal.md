# Sending Code to Terminal

This guide covers different methods for sending code from Neovim to terminal sessions, comparing vim-slime, iron.nvim, neoterm, and built-in solutions.

## Overview of Methods

| Method | Complexity | Features | Best For |
|--------|------------|----------|----------|
| vim-slime | Low | Basic code sending | General use, stability |
| iron.nvim | Medium | REPL management | Language-specific workflows |
| neoterm | Low | Terminal management | Simple terminal operations |
| Built-in | Very Low | Basic functionality | Minimal setups |

## vim-slime: The Classic Solution

vim-slime is the most popular and stable solution for sending code to terminal multiplexers.

### Installation

Using lazy.nvim:

```lua
{
  "jpalardy/vim-slime",
  config = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = {
      socket_name = "default",
      target_pane = "{last}"
    }
  end,
}
```

Using packer.nvim:

```lua
use {
  'jpalardy/vim-slime',
  config = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = {
      socket_name = "default",
      target_pane = "{last}"
    }
  end
}
```

### Basic Configuration

Add to your Neovim configuration:

```lua
-- vim-slime configuration
vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
  socket_name = "default",
  target_pane = "{last}"
}

-- Don't ask for confirmation every time
vim.g.slime_dont_ask_default = 1

-- Preserve cursor position when sending
vim.g.slime_preserve_curpos = 1

-- Key mappings
vim.keymap.set("n", "<leader>vssc", "<Plug>SlimeSendCell", { desc = "[V]im [S]lime [S]end [C]ell" })
vim.keymap.set("v", "<leader>vss", "<Plug>SlimeRegionSend", { desc = "[V]im [S]lime [S]end" })
vim.keymap.set("n", "<leader>vssl", "<Plug>SlimeLineSend", { desc = "[V]im [S]lime [S]end [L]ine" })
vim.keymap.set("n", "<leader>vssp", "<Plug>SlimeParagraphSend", { desc = "[V]im [S]lime [S]end [P]aragraph" })
```
# Understanding vim-slime Commands

This configuration sets up vim-slime to send code from Neovim to a tmux terminal:

- `vim.g.slime_target = "tmux"` - Configures vim-slime to send code to tmux panes
- `vim.g.slime_default_config` - Sets default target to the last active tmux pane
- `socket_name = "default"` - Specifies the tmux socket name
- `target_pane = "{last}"` - Sends code to the last active pane, so if you switch panes, it will send to the new last active pane.
- `vim.g.slime_dont_ask_default = 1` - Prevents confirmation prompts when sending code
- `vim.g.slime_preserve_curpos = 1` - Keeps your cursor in the same position after sending code

The key mappings provide different ways to send code:
- `<leader>vssc` - Sends a "cell" (code between delimiters like `# %%`)
- `<leader>vss` - Sends visually selected code
- `<leader>vssl` - Sends the current line
- `<leader>vssp` - Sends the current paragraph

# Example Python Workflow

1. **Setup**: Open a tmux session with two panes:
   - Left pane: Neovim with your Python script
   - Right pane: Python interpreter

2. **Daily workflow**:

```python
# %% Import libraries
import pandas as pd
import matplotlib.pyplot as plt

# %% Load data
df = pd.read_csv('data.csv')

# %% Explore data
print(df.head())
print(df.describe())

# %% Create visualization
plt.figure(figsize=(10, 6))
df['value'].plot()
plt.title('Data Visualization')
plt.show()
```

3. **Using the commands**:
   - Place cursor in the imports cell, press `<leader>vssc` to send just that cell
   - Move to the "Load data" cell, press `<leader>vssc` to execute it
   - If you need to modify a visualization, make changes and use `<leader>vssc` again
   - To send just a specific line, place cursor on it and press `<leader>vssl`
   - To send a custom selection, visually select lines and press `<leader>vss`

This workflow lets you iteratively develop and test code sections without rerunning the entire script, perfect for data analysis and exploration.


### Advanced vim-slime Configuration

```lua
-- Language-specific configurations
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.b.slime_cell_delimiter = "# %%"
    -- Send imports automatically
    vim.keymap.set("n", "<leader>si", function()
      vim.cmd("1,/^[^#]/-1SlimeSend")
    end, { desc = "Send imports", buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "r",
  callback = function()
    vim.b.slime_cell_delimiter = "# %%"
  end,
})

-- Custom function to send and execute
local function send_and_execute()
  vim.cmd("SlimeRegionSend")
  -- Send Enter to execute
  vim.fn["slime#send"]("\r")
end

vim.keymap.set("v", "<leader>se", send_and_execute, { desc = "Send and execute" })
```

### Targeting Specific Panes

```lua
-- Function to set target pane interactively
local function set_slime_target()
  local panes = vim.fn.system("tmux list-panes -F '#{pane_index}: #{pane_title}'")
  print("Available panes:")
  print(panes)
  local target = vim.fn.input("Target pane: ")
  vim.g.slime_default_config.target_pane = target
  print("Target set to: " .. target)
end

vim.keymap.set("n", "<leader>st", set_slime_target, { desc = "Set slime target" })
```

## iron.nvim: Modern REPL Integration

iron.nvim provides advanced REPL management with language-specific features.

### Installation

```lua
{
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    
    iron.setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          python = {
            command = {"python3"},
            format = require("iron.fts.common").bracketed_paste,
          },
          javascript = {
            command = {"node"},
            format = require("iron.fts.common").bracketed_paste,
          }
        },
        repl_open_cmd = require('iron.view').right(40),
      },
      keymaps = {
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_mark = "<space>sm",
        toggle_repl = "<space>rs",
        interrupt = "<space>s<space>",
      },
    }
  end,
}
```

### Language-Specific Configuration

```lua
local iron = require("iron.core")

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = {"ipython", "--no-autoindent"},
        format = require("iron.fts.common").bracketed_paste,
      },
      r = {
        command = {"R", "--slave"},
        format = require("iron.fts.common").bracketed_paste,
      },
      julia = {
        command = {"julia"},
        format = require("iron.fts.common").bracketed_paste,
      },
      lua = {
        command = {"lua"},
        format = require("iron.fts.common").bracketed_paste,
      },
      javascript = {
        command = {"node"},
        format = require("iron.fts.common").bracketed_paste,
      },
    },
    repl_open_cmd = "vertical botright 80 split",
  },
  keymaps = {
    send_motion = "<leader>rc",
    visual_send = "<leader>rc",
    send_file = "<leader>rf",
    send_line = "<leader>rl",
    send_mark = "<leader>rm",
    toggle_repl = "<leader>rt",
    interrupt = "<leader>r<space>",
    exit = "<leader>rq",
    clear = "<leader>rx",
  },
}
```

### Advanced iron.nvim Features

```lua
-- Custom REPL commands
vim.keymap.set("n", "<leader>rr", function()
  require("iron.core").repl_restart()
end, { desc = "Restart REPL" })

vim.keymap.set("n", "<leader>rh", function()
  require("iron.core").repl_hide()
end, { desc = "Hide REPL" })

-- Send and move to next cell (Python)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set("n", "<leader>rn", function()
      require("iron.core").send_motion("ac")
      vim.cmd("normal! }")
    end, { desc = "Send cell and move to next", buffer = true })
  end,
})
```

## neoterm: Lightweight Terminal Management

neoterm provides simple terminal management with basic code sending capabilities.

### Installation and Configuration

```lua
{
  "kassio/neoterm",
  config = function()
    vim.g.neoterm_default_mod = 'vertical'
    vim.g.neoterm_autoinsert = 1
    vim.g.neoterm_autoscroll = 1
    vim.g.neoterm_size = 80
    
    -- Key mappings
    vim.keymap.set("n", "<leader>tt", ":Ttoggle<CR>", { desc = "Toggle terminal" })
    vim.keymap.set("n", "<leader>tc", ":Tclear<CR>", { desc = "Clear terminal" })
    vim.keymap.set("v", "<leader>ts", ":TREPLSendSelection<CR>", { desc = "Send selection" })
    vim.keymap.set("n", "<leader>tl", ":TREPLSendLine<CR>", { desc = "Send line" })
    vim.keymap.set("n", "<leader>tf", ":TREPLSendFile<CR>", { desc = "Send file" })
  end,
}
```

### Language-Specific neoterm Setup

```lua
-- Python REPL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set("n", "<leader>tp", ":T python3<CR>", { desc = "Start Python REPL", buffer = true })
  end,
})

-- Node.js REPL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "javascript",
  callback = function()
    vim.keymap.set("n", "<leader>tn", ":T node<CR>", { desc = "Start Node REPL", buffer = true })
  end,
})

-- R REPL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "r",
  callback = function()
    vim.keymap.set("n", "<leader>tr", ":T R<CR>", { desc = "Start R REPL", buffer = true })
  end,
})
```

## Built-in Terminal Methods

Neovim's built-in terminal can be used for basic code sending without additional plugins.

### Basic Built-in Setup

```lua
-- Terminal management functions
local function open_terminal()
  vim.cmd("vsplit | terminal")
end

local function send_to_terminal(text)
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
      term_buf = buf
      break
    end
  end
  
  if term_buf then
    local term_chan = vim.api.nvim_buf_get_var(term_buf, 'terminal_job_id')
    vim.api.nvim_chan_send(term_chan, text .. '\n')
  else
    print("No terminal found")
  end
end

-- Key mappings
vim.keymap.set("n", "<leader>to", open_terminal, { desc = "Open terminal" })

vim.keymap.set("v", "<leader>ts", function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2]-1, end_pos[2], false)
  local text = table.concat(lines, '\n')
  send_to_terminal(text)
end, { desc = "Send selection to terminal" })

vim.keymap.set("n", "<leader>tl", function()
  local line = vim.api.nvim_get_current_line()
  send_to_terminal(line)
end, { desc = "Send line to terminal" })
```

## Comparison and Recommendations

### Choose vim-slime if:
- You want maximum stability and reliability
- You work with multiple languages
- You prefer simple, predictable behavior
- You use tmux or screen regularly

### Choose iron.nvim if:
- You primarily work with supported languages (Python, R, Julia, etc.)
- You want advanced REPL features
- You prefer modern Lua-based configuration
- You need automatic REPL management

### Choose neoterm if:
- You want lightweight terminal management
- You prefer simplicity over features
- You occasionally send code to terminal
- You don't need advanced REPL features

### Choose built-in methods if:
- You want minimal plugin dependencies
- You have very basic code sending needs
- You prefer to build your own solutions
- You're just getting started

## Workflow Examples

### Data Science with vim-slime

```python
# In your Python file
import pandas as pd
import matplotlib.pyplot as plt

# %% Load data
df = pd.read_csv('data.csv')

# %% Explore data
df.head()
df.describe()

# %% Visualize
plt.figure(figsize=(10, 6))
df.plot()
plt.show()
```

Use `<leader>ss` to send each cell to your Python REPL.

### Web Development with iron.nvim

```javascript
// In your JavaScript file
const express = require('express');
const app = express();

// Test individual functions
function calculateSum(a, b) {
  return a + b;
}

// Send to Node REPL for testing
calculateSum(5, 3);
```

Use `<leader>rl` to send lines to Node.js REPL.

## Next Steps

Now that you can send code to terminal sessions, learn how to navigate and interact with terminal output using vim motions.

Continue to [Terminal Navigation with Vim Motions](04-terminal-navigation-with-vim-motions.md).
