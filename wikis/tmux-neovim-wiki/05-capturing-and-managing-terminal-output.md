# Capturing and Managing Terminal Output

This guide covers various methods for capturing terminal output, saving it to files, and analyzing it with Neovim for improved debugging and analysis workflows.

## Understanding Tmux Capture Methods

Tmux provides several ways to capture terminal content, from simple pane snapshots to continuous logging.

### Basic Capture Commands

```bash
# Capture visible pane content
tmux capture-pane

# Capture with scrollback history
tmux capture-pane -S -1000    # Last 1000 lines
tmux capture-pane -S -        # All available history

# Capture to file directly
tmux capture-pane -S - -p > output.txt

# Capture specific pane
tmux capture-pane -t 1 -S - -p > pane1_output.txt
```

### Advanced Capture Options

```bash
# Include escape sequences (colors, formatting)
tmux capture-pane -e -S - -p > output_with_colors.txt

# Join wrapped lines
tmux capture-pane -J -S - -p > output_joined.txt

# Capture only printed content (no empty lines at end)
tmux capture-pane -S - -E - -p > output_trimmed.txt

# Capture with timestamps (requires additional setup)
tmux capture-pane -S - -p | while read line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done > timestamped_output.txt
```

## Automated Capture Configuration

### Tmux Key Bindings for Capture

Add these bindings to `~/.tmux.conf`:

```bash
# Quick capture bindings
bind-key C-s capture-pane -S - \; save-buffer ~/tmux-capture.txt \; display-message "Captured to ~/tmux-capture.txt"

# Capture with timestamp
bind-key C-t run-shell 'tmux capture-pane -S - -p | sed "s/^/$(date "+%Y-%m-%d %H:%M:%S") /" > ~/tmux-capture-$(date "+%Y%m%d-%H%M%S").txt' \; display-message "Timestamped capture saved"

# Capture specific number of lines
bind-key C-l command-prompt -p "Lines to capture:" "capture-pane -S -%% \; save-buffer ~/tmux-capture-lines.txt \; display-message 'Captured %% lines'"

# Append to existing log file
bind-key C-a capture-pane -S - \; save-buffer -a ~/tmux-session.log \; display-message "Appended to session log"

# Capture and open in Neovim
bind-key C-v capture-pane -S - \; save-buffer /tmp/tmux-capture.txt \; new-window 'nvim /tmp/tmux-capture.txt'
```

### Automatic Logging Setup

```bash
# Enable automatic logging for all panes
# Add to ~/.tmux.conf:

# Create log directory
run-shell 'mkdir -p ~/.tmux/logs'

# Start logging for new panes
set-hook -g after-new-session 'pipe-pane -o "cat >> ~/.tmux/logs/session-#S-#{window_index}-#{pane_index}.log"'
set-hook -g after-new-window 'pipe-pane -o "cat >> ~/.tmux/logs/session-#S-#{window_index}-#{pane_index}.log"'
set-hook -g after-split-window 'pipe-pane -o "cat >> ~/.tmux/logs/session-#S-#{window_index}-#{pane_index}.log"'

# Toggle logging for current pane
bind-key P pipe-pane -o "cat >> ~/.tmux/logs/session-#S-#{window_index}-#{pane_index}.log" \; display-message "Logging toggled"
```

## Neovim Integration for Output Analysis

### Quick Analysis Functions

Add these functions to your Neovim configuration:

```lua
-- Capture and analyze terminal output
local function capture_and_analyze()
  -- Capture tmux pane
  os.execute("tmux capture-pane -S - -p > /tmp/tmux-analysis.txt")
  
  -- Open in new buffer
  vim.cmd("edit /tmp/tmux-analysis.txt")
  
  -- Set up for analysis
  vim.bo.filetype = "log"
  vim.bo.readonly = true
  vim.wo.number = true
  vim.wo.wrap = false
  
  -- Jump to bottom
  vim.cmd("normal! G")
end

-- Quick error analysis
local function analyze_errors()
  capture_and_analyze()
  
  -- Search for common error patterns
  vim.cmd("silent! /\\c\\(error\\|exception\\|failed\\|traceback\\)")
  vim.cmd("nohlsearch")
  
  -- Set up folding for better navigation
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "getline(v:lnum) =~ '^\\s*$' ? 0 : 1"
end

-- Analyze command output
local function analyze_command_output(command)
  local filename = "/tmp/command-output-" .. os.time() .. ".txt"
  os.execute("tmux capture-pane -S - -p > " .. filename)
  
  vim.cmd("edit " .. filename)
  vim.bo.filetype = "log"
  
  -- Add command as comment at top
  vim.api.nvim_buf_set_lines(0, 0, 0, false, {
    "# Command output analysis",
    "# Generated: " .. os.date(),
    "# Command: " .. (command or "unknown"),
    "",
  })
end

-- Key mappings
vim.keymap.set("n", "<leader>ta", capture_and_analyze, { desc = "Capture and analyze terminal" })
vim.keymap.set("n", "<leader>te", analyze_errors, { desc = "Analyze terminal errors" })
vim.keymap.set("n", "<leader>to", function()
  local cmd = vim.fn.input("Command context: ")
  analyze_command_output(cmd)
end, { desc = "Analyze command output" })
```

### Log File Management

```lua
-- Log file utilities
local function open_session_log()
  local session = vim.fn.system("tmux display-message -p '#S'"):gsub("\n", "")
  local window = vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("\n", "")
  local pane = vim.fn.system("tmux display-message -p '#{pane_index}'"):gsub("\n", "")
  
  local logfile = string.format("~/.tmux/logs/session-%s-%s-%s.log", session, window, pane)
  vim.cmd("edit " .. logfile)
  
  -- Set up for log viewing
  vim.bo.filetype = "log"
  vim.wo.wrap = false
  vim.cmd("normal! G")  -- Go to end
end

local function tail_session_log()
  local session = vim.fn.system("tmux display-message -p '#S'"):gsub("\n", "")
  local window = vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("\n", "")
  local pane = vim.fn.system("tmux display-message -p '#{pane_index}'"):gsub("\n", "")
  
  local logfile = string.format("~/.tmux/logs/session-%s-%s-%s.log", session, window, pane)
  vim.cmd("terminal tail -f " .. logfile)
end

-- Key mappings
vim.keymap.set("n", "<leader>tl", open_session_log, { desc = "Open session log" })
vim.keymap.set("n", "<leader>tT", tail_session_log, { desc = "Tail session log" })
```

## Advanced Output Processing

### Filtering and Processing Scripts

Create useful shell scripts for processing captured output:

```bash
#!/bin/bash
# save as ~/.local/bin/tmux-filter-errors

# Filter errors from tmux capture
tmux capture-pane -S - -p | grep -i -E "(error|exception|failed|traceback)" > /tmp/filtered-errors.txt

# Open in Neovim if errors found
if [ -s /tmp/filtered-errors.txt ]; then
    nvim /tmp/filtered-errors.txt
else
    echo "No errors found in terminal output"
fi
```

```bash
#!/bin/bash
# save as ~/.local/bin/tmux-extract-commands

# Extract commands and their outputs
tmux capture-pane -S - -p | awk '
/^\$ / { 
    if (cmd) print cmd "\n" output "\n---"
    cmd = $0
    output = ""
    next
}
{ 
    output = output $0 "\n"
}
END {
    if (cmd) print cmd "\n" output
}' > /tmp/commands-output.txt

nvim /tmp/commands-output.txt
```

### Automated Analysis with Neovim

```lua
-- Advanced output analysis
local function analyze_performance_output()
  capture_and_analyze()
  
  -- Look for performance indicators
  local patterns = {
    "time:",
    "duration:",
    "elapsed:",
    "ms",
    "seconds",
    "memory:",
    "cpu:",
  }
  
  for _, pattern in ipairs(patterns) do
    vim.cmd("silent! /" .. pattern)
  end
  
  -- Create quickfix list of performance metrics
  vim.cmd("vimgrep /\\c\\(time\\|duration\\|elapsed\\|memory\\|cpu\\)/ %")
  vim.cmd("copen")
end

local function analyze_test_output()
  capture_and_analyze()
  
  -- Search for test results
  vim.cmd("silent! /\\c\\(passed\\|failed\\|error\\|ok\\|not ok\\)")
  
  -- Count test results
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local passed = 0
  local failed = 0
  
  for _, line in ipairs(lines) do
    if line:match("passed") or line:match("ok") then
      passed = passed + 1
    elseif line:match("failed") or line:match("error") then
      failed = failed + 1
    end
  end
  
  print(string.format("Test Results: %d passed, %d failed", passed, failed))
end

-- Key mappings
vim.keymap.set("n", "<leader>tp", analyze_performance_output, { desc = "Analyze performance output" })
vim.keymap.set("n", "<leader>tt", analyze_test_output, { desc = "Analyze test output" })
```

## Output Organization Strategies

### Structured Logging

```bash
# Add to ~/.tmux.conf for structured logging
bind-key L command-prompt -p "Log name:" "capture-pane -S - \; save-buffer ~/logs/%%_$(date '+%Y%m%d_%H%M%S').log \; display-message 'Saved to ~/logs/%%_$(date '+%Y%m%d_%H%M%S').log'"

# Create log directories
run-shell 'mkdir -p ~/logs/{debug,error,performance,test}'

# Specialized capture commands
bind-key D capture-pane -S - \; save-buffer ~/logs/debug/debug_$(date '+%Y%m%d_%H%M%S').log
bind-key E run-shell 'tmux capture-pane -S - -p | grep -i error > ~/logs/error/error_$(date '+%Y%m%d_%H%M%S').log'
```

### Project-Specific Logging

```lua
-- Project-specific output management
local function setup_project_logging()
  local project_root = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(project_root, ":t")
  local log_dir = project_root .. "/logs"
  
  -- Create logs directory
  vim.fn.mkdir(log_dir, "p")
  
  -- Set up tmux logging for this project
  local log_file = log_dir .. "/" .. project_name .. "_" .. os.date("%Y%m%d") .. ".log"
  os.execute("tmux pipe-pane -o 'cat >> " .. log_file .. "'")
  
  print("Project logging enabled: " .. log_file)
end

vim.keymap.set("n", "<leader>tP", setup_project_logging, { desc = "Setup project logging" })
```

## Integration with Analysis Tools

### Connecting with External Tools

```lua
-- Send output to external analysis tools
local function send_to_analysis_tool(tool)
  local temp_file = "/tmp/tmux-output-" .. os.time() .. ".txt"
  os.execute("tmux capture-pane -S - -p > " .. temp_file)
  
  if tool == "less" then
    vim.cmd("terminal less " .. temp_file)
  elseif tool == "grep" then
    local pattern = vim.fn.input("Grep pattern: ")
    vim.cmd("terminal grep -n '" .. pattern .. "' " .. temp_file)
  elseif tool == "awk" then
    local script = vim.fn.input("AWK script: ")
    vim.cmd("terminal awk '" .. script .. "' " .. temp_file)
  end
end

-- Key mappings for analysis tools
vim.keymap.set("n", "<leader>tg", function() send_to_analysis_tool("grep") end, { desc = "Grep terminal output" })
vim.keymap.set("n", "<leader>tw", function() send_to_analysis_tool("awk") end, { desc = "AWK terminal output" })
vim.keymap.set("n", "<leader>tv", function() send_to_analysis_tool("less") end, { desc = "View terminal output" })
```

## Troubleshooting Capture Issues

### Common Problems

**Capture is empty:**
```bash
# Check if pane has content
tmux capture-pane -p | wc -l

# Increase history limit
set -g history-limit 50000
```

**Missing recent output:**
```bash
# Ensure you're capturing the right pane
tmux list-panes -F "#{pane_index}: #{pane_title}"

# Capture with larger history
tmux capture-pane -S -10000
```

**Colors not preserved:**
```bash
# Use -e flag to preserve escape sequences
tmux capture-pane -e -S - -p > output.txt

# Or strip colors for clean text
tmux capture-pane -S - -p | sed 's/\x1b\[[0-9;]*m//g' > clean_output.txt
```

## Next Steps

Now that you can effectively capture and analyze terminal output, learn about advanced integration workflows that combine all these techniques.

Continue to [Advanced Integration Workflows](06-advanced-integration-workflows.md).
