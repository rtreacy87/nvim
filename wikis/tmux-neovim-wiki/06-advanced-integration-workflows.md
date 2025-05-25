# Advanced Integration Workflows

This guide covers sophisticated workflows that combine tmux and Neovim for maximum productivity, including multi-pane setups, session management, debugging workflows, and specialized development scenarios.

## Multi-Pane Development Setups

### The Classic Four-Pane Layout

Create a comprehensive development environment:

```bash
#!/bin/bash
# save as ~/.local/bin/dev-setup

SESSION_NAME="development"

# Create session
tmux new-session -d -s $SESSION_NAME

# Split into four panes
tmux split-window -h -t $SESSION_NAME:0
tmux split-window -v -t $SESSION_NAME:0.0
tmux split-window -v -t $SESSION_NAME:0.1

# Set up each pane
tmux send-keys -t $SESSION_NAME:0.0 'nvim' Enter
tmux send-keys -t $SESSION_NAME:0.1 'python3' Enter
tmux send-keys -t $SESSION_NAME:0.2 'git status' Enter
tmux send-keys -t $SESSION_NAME:0.3 'tail -f logs/app.log' Enter

# Focus on editor
tmux select-pane -t $SESSION_NAME:0.0

# Attach to session
tmux attach-session -t $SESSION_NAME
```

### Data Science Layout

```bash
#!/bin/bash
# save as ~/.local/bin/data-science-setup

SESSION_NAME="datascience"

tmux new-session -d -s $SESSION_NAME

# Create windows for different purposes
tmux new-window -t $SESSION_NAME:1 -n "analysis"
tmux new-window -t $SESSION_NAME:2 -n "visualization"
tmux new-window -t $SESSION_NAME:3 -n "notebook"

# Analysis window (main work)
tmux split-window -h -t $SESSION_NAME:1
tmux send-keys -t $SESSION_NAME:1.0 'nvim analysis.py' Enter
tmux send-keys -t $SESSION_NAME:1.1 'ipython' Enter

# Visualization window
tmux split-window -h -t $SESSION_NAME:2
tmux send-keys -t $SESSION_NAME:2.0 'nvim plots.py' Enter
tmux send-keys -t $SESSION_NAME:2.1 'python3 -c "import matplotlib.pyplot as plt; plt.ion()"' Enter

# Notebook window
tmux send-keys -t $SESSION_NAME:3 'jupyter lab' Enter

tmux select-window -t $SESSION_NAME:1
tmux attach-session -t $SESSION_NAME
```

## Session Management and Persistence

### Advanced Session Configuration

Add to `~/.tmux.conf`:

```bash
# Session management
bind-key S command-prompt -p "New session name:" "new-session -d -s %%"
bind-key K confirm-before -p "Kill session #S? (y/n)" kill-session
bind-key R command-prompt -p "Rename session to:" "rename-session %%"

# Save and restore sessions
bind-key C-s run-shell "~/.local/bin/tmux-save-session"
bind-key C-r run-shell "~/.local/bin/tmux-restore-session"

# Quick session switching
bind-key w choose-tree -Zs
bind-key s choose-tree -Zw
```

### Session Save/Restore Scripts

```bash
#!/bin/bash
# save as ~/.local/bin/tmux-save-session

SESSION_DIR="$HOME/.tmux/sessions"
mkdir -p "$SESSION_DIR"

for session in $(tmux list-sessions -F "#{session_name}"); do
    echo "Saving session: $session"
    
    # Save session layout
    tmux list-windows -t "$session" -F "#{window_index}:#{window_name}:#{window_layout}" > "$SESSION_DIR/$session.layout"
    
    # Save pane commands (simplified)
    tmux list-panes -t "$session" -F "#{pane_index}:#{pane_current_command}" > "$SESSION_DIR/$session.commands"
    
    # Save working directories
    tmux list-panes -t "$session" -F "#{pane_index}:#{pane_current_path}" > "$SESSION_DIR/$session.paths"
done

echo "Sessions saved to $SESSION_DIR"
```

```bash
#!/bin/bash
# save as ~/.local/bin/tmux-restore-session

SESSION_DIR="$HOME/.tmux/sessions"

if [ ! -d "$SESSION_DIR" ]; then
    echo "No saved sessions found"
    exit 1
fi

for layout_file in "$SESSION_DIR"/*.layout; do
    session_name=$(basename "$layout_file" .layout)
    
    echo "Restoring session: $session_name"
    
    # Create session
    tmux new-session -d -s "$session_name"
    
    # Restore windows and layout
    while IFS=':' read -r window_index window_name window_layout; do
        if [ "$window_index" != "0" ]; then
            tmux new-window -t "$session_name:$window_index" -n "$window_name"
        else
            tmux rename-window -t "$session_name:0" "$window_name"
        fi
        tmux select-layout -t "$session_name:$window_index" "$window_layout"
    done < "$layout_file"
    
    # Restore working directories (simplified)
    if [ -f "$SESSION_DIR/$session_name.paths" ]; then
        while IFS=':' read -r pane_index pane_path; do
            tmux send-keys -t "$session_name:0.$pane_index" "cd '$pane_path'" Enter
        done < "$SESSION_DIR/$session_name.paths"
    fi
done

echo "Sessions restored"
```

## Debugging Workflows

### Interactive Debugging Setup

```lua
-- Neovim debugging integration
local function setup_debug_environment()
  -- Create debug layout in tmux
  os.execute([[
    tmux split-window -h -p 30
    tmux split-window -v
    tmux select-pane -t 0
  ]])
  
  -- Set up panes
  -- Pane 0: Neovim (current)
  -- Pane 1: Debugger
  -- Pane 2: Logs/Output
  
  print("Debug environment ready")
end

local function start_python_debugger()
  -- Send debugger command to pane 1
  os.execute("tmux send-keys -t 1 'python -m pdb " .. vim.fn.expand("%") .. "' Enter")
  
  -- Set up log monitoring in pane 2
  os.execute("tmux send-keys -t 2 'tail -f debug.log' Enter")
end

local function debug_send_command(cmd)
  os.execute("tmux send-keys -t 1 '" .. cmd .. "' Enter")
end

-- Debug key mappings
vim.keymap.set("n", "<leader>ds", setup_debug_environment, { desc = "Setup debug environment" })
vim.keymap.set("n", "<leader>dp", start_python_debugger, { desc = "Start Python debugger" })
vim.keymap.set("n", "<leader>dn", function() debug_send_command("n") end, { desc = "Debug next" })
vim.keymap.set("n", "<leader>dc", function() debug_send_command("c") end, { desc = "Debug continue" })
vim.keymap.set("n", "<leader>db", function()
  local line = vim.fn.line(".")
  debug_send_command("b " .. line)
end, { desc = "Set breakpoint" })
```

### GDB Integration

```bash
# Add to ~/.tmux.conf for GDB debugging
bind-key g split-window -h -p 40 \; send-keys 'gdb' Enter

# GDB-specific tmux setup
bind-key G run-shell '
  tmux split-window -h -p 40
  tmux split-window -v -t 1
  tmux send-keys -t 1 "gdb ./program" Enter
  tmux send-keys -t 2 "tail -f gdb.log" Enter
  tmux select-pane -t 0
'
```

## Remote Development Scenarios

### SSH Session Management

```bash
#!/bin/bash
# save as ~/.local/bin/remote-dev

HOST="$1"
PROJECT="$2"

if [ -z "$HOST" ] || [ -z "$PROJECT" ]; then
    echo "Usage: remote-dev <host> <project>"
    exit 1
fi

SESSION_NAME="remote-$HOST-$PROJECT"

# Create local session that connects to remote
tmux new-session -d -s "$SESSION_NAME"

# Main development pane
tmux send-keys -t "$SESSION_NAME:0" "ssh $HOST -t 'cd ~/projects/$PROJECT && tmux new-session -s $PROJECT || tmux attach-session -t $PROJECT'" Enter

# Local monitoring pane
tmux split-window -h -t "$SESSION_NAME:0"
tmux send-keys -t "$SESSION_NAME:0.1" "ssh $HOST 'tail -f ~/projects/$PROJECT/logs/*.log'" Enter

# Local git pane
tmux split-window -v -t "$SESSION_NAME:0.1"
tmux send-keys -t "$SESSION_NAME:0.2" "cd ~/local-projects/$PROJECT && git status" Enter

tmux select-pane -t "$SESSION_NAME:0.0"
tmux attach-session -t "$SESSION_NAME"
```

### Synchronized Development

```lua
-- Neovim remote development helpers
local function sync_to_remote()
  local current_file = vim.fn.expand("%:p")
  local relative_path = vim.fn.expand("%:.")
  local remote_host = vim.g.remote_host or "remote-server"
  local remote_path = vim.g.remote_project_path or "~/projects/current"
  
  -- Save current file
  vim.cmd("write")
  
  -- Sync to remote
  local cmd = string.format("rsync -av '%s' %s:%s/%s", 
    current_file, remote_host, remote_path, relative_path)
  os.execute(cmd)
  
  print("Synced to remote: " .. relative_path)
end

local function run_remote_tests()
  local test_command = vim.g.remote_test_command or "python -m pytest"
  local tmux_cmd = string.format("tmux send-keys -t remote 'cd %s && %s' Enter", 
    vim.g.remote_project_path, test_command)
  os.execute(tmux_cmd)
end

vim.keymap.set("n", "<leader>rs", sync_to_remote, { desc = "Sync to remote" })
vim.keymap.set("n", "<leader>rt", run_remote_tests, { desc = "Run remote tests" })
```

## Plugin Integration Workflows

### Integration with Popular Plugins

```lua
-- Integration with telescope.nvim
local function tmux_session_picker()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Get tmux sessions
  local sessions = {}
  local handle = io.popen("tmux list-sessions -F '#{session_name}:#{session_windows}:#{session_attached}'")
  for line in handle:lines() do
    local name, windows, attached = line:match("([^:]+):([^:]+):([^:]+)")
    table.insert(sessions, {
      name = name,
      windows = windows,
      attached = attached == "1",
      display = name .. " (" .. windows .. " windows)" .. (attached == "1" and " [attached]" or "")
    })
  end
  handle:close()
  
  pickers.new({}, {
    prompt_title = 'Tmux Sessions',
    finder = finders.new_table({
      results = sessions,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        os.execute("tmux switch-client -t " .. selection.value.name)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", "<leader>ts", tmux_session_picker, { desc = "Switch tmux session" })

-- Integration with nvim-dap (Debug Adapter Protocol)
local function setup_dap_tmux()
  local dap = require('dap')
  
  -- Override dap terminal to use tmux
  dap.defaults.fallback.terminal = function(cmd)
    os.execute("tmux split-window -h 'cd " .. vim.fn.getcwd() .. " && " .. cmd .. "'")
  end
end

-- Integration with toggleterm.nvim
local function setup_toggleterm_tmux()
  require("toggleterm").setup({
    open_mapping = [[<c-\>]],
    direction = 'horizontal',
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    on_create = function(term)
      -- Send tmux commands when terminal is created
      if vim.g.tmux_integration then
        os.execute("tmux send-keys -t " .. term.id .. " 'echo Terminal " .. term.id .. " ready' Enter")
      end
    end,
  })
end
```

## Performance Optimization Workflows

### Resource Monitoring Setup

```bash
#!/bin/bash
# save as ~/.local/bin/monitor-setup

SESSION_NAME="monitoring"

tmux new-session -d -s $SESSION_NAME

# System monitoring window
tmux new-window -t $SESSION_NAME:1 -n "system"
tmux split-window -h -t $SESSION_NAME:1
tmux split-window -v -t $SESSION_NAME:1.0
tmux split-window -v -t $SESSION_NAME:1.1

tmux send-keys -t $SESSION_NAME:1.0 'htop' Enter
tmux send-keys -t $SESSION_NAME:1.1 'iotop' Enter
tmux send-keys -t $SESSION_NAME:1.2 'nethogs' Enter
tmux send-keys -t $SESSION_NAME:1.3 'watch -n 1 "df -h"' Enter

# Application monitoring window
tmux new-window -t $SESSION_NAME:2 -n "app"
tmux split-window -h -t $SESSION_NAME:2
tmux send-keys -t $SESSION_NAME:2.0 'tail -f app.log' Enter
tmux send-keys -t $SESSION_NAME:2.1 'watch -n 5 "ps aux | grep myapp"' Enter

tmux select-window -t $SESSION_NAME:1
tmux attach-session -t $SESSION_NAME
```

### Automated Performance Analysis

```lua
-- Performance analysis integration
local function analyze_performance_logs()
  -- Capture current tmux pane output
  os.execute("tmux capture-pane -S - -p > /tmp/perf-analysis.txt")
  
  -- Open in new buffer
  vim.cmd("edit /tmp/perf-analysis.txt")
  
  -- Set up for performance analysis
  vim.bo.filetype = "log"
  
  -- Search for performance indicators
  vim.cmd("silent! /\\c\\(slow\\|timeout\\|memory\\|cpu\\|performance\\)")
  
  -- Create quickfix list of performance issues
  vim.cmd("vimgrep /\\c\\(slow\\|timeout\\|high.*memory\\|high.*cpu\\)/ %")
  vim.cmd("copen")
  
  print("Performance analysis complete. Check quickfix list.")
end

vim.keymap.set("n", "<leader>pa", analyze_performance_logs, { desc = "Analyze performance" })
```

## Collaborative Development

### Shared Session Setup

```bash
#!/bin/bash
# save as ~/.local/bin/pair-programming

SESSION_NAME="pair-${1:-default}"
SOCKET_PATH="/tmp/tmux-pair"

# Create shared socket
tmux -S "$SOCKET_PATH" new-session -d -s "$SESSION_NAME"

# Set permissions for sharing
chmod 777 "$SOCKET_PATH"

# Set up development environment
tmux -S "$SOCKET_PATH" split-window -h -t "$SESSION_NAME:0"
tmux -S "$SOCKET_PATH" send-keys -t "$SESSION_NAME:0.0" 'nvim' Enter
tmux -S "$SOCKET_PATH" send-keys -t "$SESSION_NAME:0.1" 'echo "Pair programming session ready"' Enter

echo "Pair programming session created: $SESSION_NAME"
echo "Others can join with: tmux -S $SOCKET_PATH attach-session -t $SESSION_NAME"

# Attach to session
tmux -S "$SOCKET_PATH" attach-session -t "$SESSION_NAME"
```

## Next Steps

You now have a comprehensive understanding of advanced tmux-Neovim integration workflows. The final guide will help you troubleshoot common issues and optimize your setup.

Continue to [Troubleshooting and Optimization](07-troubleshooting-and-optimization.md).
