# Troubleshooting and Optimization

This guide helps you resolve common issues with tmux-Neovim integration and optimize your setup for maximum performance and reliability.

## Common Integration Issues

### Code Sending Problems

**Issue: vim-slime not sending code**

```bash
# Check tmux target configuration
echo $TMUX

# Verify slime configuration in Neovim
:echo g:slime_target
:echo g:slime_default_config

# Test manual sending
:SlimeConfig
# Enter target pane (e.g., "1" or "{last}")
```

**Solution:**
```lua
-- Reset slime configuration
vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
  socket_name = "default",
  target_pane = "{last}"
}

-- Force reconfiguration
vim.keymap.set("n", "<leader>sc", ":SlimeConfig<CR>", { desc = "Configure slime" })
```

**Issue: iron.nvim REPL not starting**

```lua
-- Debug iron.nvim
local iron = require("iron.core")

-- Check if REPL is defined for current filetype
print(vim.bo.filetype)

-- Manually start REPL
iron.repl_for(vim.bo.filetype)

-- Check iron status
:IronInfo
```

**Solution:**
```lua
-- Ensure proper iron setup
require("iron.core").setup({
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = {"python3"},  -- Ensure python3 is in PATH
        format = require("iron.fts.common").bracketed_paste,
      }
    },
  },
})
```

### Terminal Navigation Issues

**Issue: Copy mode not working**

```bash
# Check tmux configuration
tmux show-options -g mode-keys
# Should show: mode-keys vi

# Test copy mode manually
tmux copy-mode
```

**Solution:**
```bash
# Add to ~/.tmux.conf
setw -g mode-keys vi

# Reload configuration
tmux source-file ~/.tmux.conf
```

**Issue: Vim motions not working in copy mode**

```bash
# Check key bindings
tmux list-keys -T copy-mode-vi

# Test specific binding
tmux list-keys -T copy-mode-vi | grep "v "
```

**Solution:**
```bash
# Ensure proper copy mode bindings in ~/.tmux.conf
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi Escape send-keys -X cancel
```

### Clipboard Integration Problems

**Issue: Copy to system clipboard not working**

**macOS:**
```bash
# Test pbcopy
echo "test" | pbcopy
pbpaste

# Check tmux configuration
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
```

**Linux (X11):**
```bash
# Install xclip
sudo apt install xclip  # Ubuntu/Debian
sudo dnf install xclip  # Fedora

# Test xclip
echo "test" | xclip -selection clipboard
xclip -selection clipboard -o

# Tmux configuration
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"
```

**Linux (Wayland):**
```bash
# Install wl-clipboard
sudo apt install wl-clipboard  # Ubuntu/Debian

# Test wl-copy
echo "test" | wl-copy
wl-paste

# Tmux configuration
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
```

**WSL:**
```bash
# Test clip.exe
echo "test" | clip.exe

# Tmux configuration
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
```

## Performance Optimization

### Tmux Performance Tuning

```bash
# Add to ~/.tmux.conf for better performance

# Reduce escape time
set -s escape-time 0

# Increase history limit (but not too high)
set -g history-limit 10000

# Disable automatic window renaming (can be slow)
set-option -g allow-rename off

# Reduce status update frequency
set -g status-interval 5

# Disable visual activity monitoring if not needed
set -g monitor-activity off
set -g visual-activity off

# Use faster terminal
set -g default-terminal "screen-256color"

# Optimize for modern terminals
set-option -ga terminal-overrides ",xterm-256color:Tc"
```

### Neovim Performance Optimization

```lua
-- Optimize Neovim for tmux integration

-- Reduce updatetime for better responsiveness
vim.opt.updatetime = 100

-- Disable swap files (can cause delays)
vim.opt.swapfile = false

-- Optimize terminal settings
vim.opt.lazyredraw = true
vim.opt.ttyfast = true

-- Reduce timeout for key sequences
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

-- Optimize for terminal use
if vim.env.TMUX then
  vim.opt.title = true
  vim.opt.titlestring = "nvim %F"
end
```

### Memory Usage Optimization

```bash
# Monitor tmux memory usage
ps aux | grep tmux

# Limit buffer sizes
# Add to ~/.tmux.conf
set -g history-limit 5000  # Reduce if memory is limited

# Clean up old sessions
tmux list-sessions | grep -v attached | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

```lua
-- Monitor Neovim memory usage
local function check_memory_usage()
  local mem_info = vim.fn.system("ps -o pid,vsz,rss,comm -p " .. vim.fn.getpid())
  print(mem_info)
end

vim.keymap.set("n", "<leader>mem", check_memory_usage, { desc = "Check memory usage" })
```

## Platform-Specific Considerations

### macOS Specific Issues

**Issue: Slow terminal rendering**
```bash
# Add to ~/.tmux.conf
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Disable mouse reporting if slow
# set -g mouse off
```

**Issue: Homebrew path issues**
```bash
# Ensure proper PATH in tmux
# Add to ~/.tmux.conf
set-environment -g PATH "/opt/homebrew/bin:/usr/local/bin:/bin:/usr/bin"
```

### Linux Specific Issues

**Issue: Terminal colors not working**
```bash
# Check TERM variable
echo $TERM

# Set proper TERM in shell profile
export TERM=xterm-256color

# Add to ~/.tmux.conf
set -g default-terminal "screen-256color"
```

**Issue: Clipboard not working in SSH**
```bash
# Forward X11 for clipboard
ssh -X user@host

# Or use tmux-yank plugin
# Add to ~/.tmux.conf
set -g @plugin 'tmux-plugins/tmux-yank'
```

### Windows/WSL Specific Issues

**Issue: Path conversion problems**
```bash
# Use wslpath for path conversion
wslpath -w /mnt/c/Users/username/project

# Add helper function to shell
win_path() {
    wslpath -w "$1"
}
```

**Issue: Performance in WSL**
```bash
# Optimize WSL performance
# Add to ~/.tmux.conf
set -g default-terminal "screen-256color"
set -s escape-time 0
set -g history-limit 5000
```

## Debugging Integration Issues

### Diagnostic Commands

```bash
# Check tmux version and features
tmux -V
tmux show-options -g

# List all tmux sessions and windows
tmux list-sessions
tmux list-windows -a
tmux list-panes -a

# Check tmux key bindings
tmux list-keys | grep copy-mode
tmux list-keys -T copy-mode-vi

# Test tmux commands manually
tmux capture-pane -p
tmux show-environment
```

```lua
-- Neovim diagnostic functions
local function diagnose_integration()
  print("=== Tmux-Neovim Integration Diagnostics ===")
  
  -- Check if running in tmux
  if vim.env.TMUX then
    print("✓ Running in tmux session")
    print("  TMUX: " .. vim.env.TMUX)
  else
    print("✗ Not running in tmux")
  end
  
  -- Check terminal capabilities
  print("Terminal: " .. (vim.env.TERM or "unknown"))
  print("Colors: " .. (vim.o.termguicolors and "true" or "false"))
  
  -- Check plugins
  local plugins = {
    "vim-slime",
    "iron.nvim", 
    "neoterm"
  }
  
  for _, plugin in ipairs(plugins) do
    local ok = pcall(require, plugin)
    print((ok and "✓" or "✗") .. " " .. plugin)
  end
end

vim.keymap.set("n", "<leader>diag", diagnose_integration, { desc = "Diagnose integration" })
```

### Log Analysis

```bash
# Enable tmux logging for debugging
tmux set -g @logging-path "$HOME/.tmux/logs"
tmux set -g @screen-capture-path "$HOME/.tmux/logs"

# Create debug log function
debug_tmux() {
    echo "$(date): $*" >> ~/.tmux/debug.log
}

# Add to shell functions for debugging
alias tmux-debug='tail -f ~/.tmux/debug.log'
```

```lua
-- Neovim logging for integration debugging
local log_file = vim.fn.stdpath("cache") .. "/tmux-integration.log"

local function log_debug(message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local log_entry = string.format("[%s] %s\n", timestamp, message)
  
  local file = io.open(log_file, "a")
  if file then
    file:write(log_entry)
    file:close()
  end
end

-- Log integration events
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    log_debug("Neovim started in tmux: " .. (vim.env.TMUX and "yes" or "no"))
  end
})

vim.keymap.set("n", "<leader>log", function()
  vim.cmd("edit " .. log_file)
end, { desc = "Open integration log" })
```

## Maintenance and Updates

### Regular Maintenance Tasks

```bash
#!/bin/bash
# save as ~/.local/bin/tmux-maintenance

echo "=== Tmux Maintenance ==="

# Clean up old sessions
echo "Cleaning up detached sessions..."
tmux list-sessions | grep -v attached | cut -d: -f1 | xargs -I {} tmux kill-session -t {}

# Clean up log files
echo "Cleaning up old logs..."
find ~/.tmux/logs -name "*.log" -mtime +7 -delete

# Update tmux plugins (if using tpm)
if [ -d ~/.tmux/plugins/tpm ]; then
    echo "Updating tmux plugins..."
    ~/.tmux/plugins/tpm/bin/update_plugins all
fi

# Check configuration
echo "Checking tmux configuration..."
tmux source-file ~/.tmux.conf && echo "✓ Configuration valid" || echo "✗ Configuration error"

echo "Maintenance complete"
```

### Configuration Backup

```bash
#!/bin/bash
# save as ~/.local/bin/backup-tmux-config

BACKUP_DIR="$HOME/.config/backups/tmux-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup tmux configuration
cp ~/.tmux.conf "$BACKUP_DIR/"

# Backup session layouts
if [ -d ~/.tmux/sessions ]; then
    cp -r ~/.tmux/sessions "$BACKUP_DIR/"
fi

# Backup custom scripts
if [ -d ~/.local/bin ]; then
    cp ~/.local/bin/tmux-* "$BACKUP_DIR/"
fi

echo "Tmux configuration backed up to $BACKUP_DIR"
```

### Update Procedures

```bash
# Update tmux
# macOS
brew upgrade tmux

# Ubuntu/Debian
sudo apt update && sudo apt upgrade tmux

# Check for breaking changes
tmux -V
man tmux | grep -A 10 "CHANGES"

# Test configuration after update
tmux source-file ~/.tmux.conf
```

```lua
-- Update Neovim plugins related to tmux integration
local function update_integration_plugins()
  -- Using lazy.nvim
  vim.cmd("Lazy update vim-slime iron.nvim neoterm")
  
  -- Check for configuration changes needed
  print("Check plugin documentation for breaking changes")
end

vim.keymap.set("n", "<leader>up", update_integration_plugins, { desc = "Update integration plugins" })
```

## Best Practices Summary

### Configuration Management
- Keep configurations in version control
- Use modular configuration files
- Document custom key bindings
- Regular backups of working configurations

### Performance Guidelines
- Monitor resource usage regularly
- Optimize history limits based on needs
- Use appropriate terminal settings
- Clean up unused sessions and logs

### Troubleshooting Approach
1. Isolate the problem (tmux vs Neovim vs integration)
2. Check basic functionality first
3. Review recent configuration changes
4. Test with minimal configuration
5. Check platform-specific issues
6. Use diagnostic tools and logging

### Security Considerations
- Be careful with shared tmux sockets
- Limit log file permissions
- Clean up sensitive data in logs
- Use secure methods for remote sessions

## Conclusion

You now have a comprehensive understanding of tmux-Neovim integration, from basic setup to advanced workflows and troubleshooting. This integration can significantly enhance your development productivity when properly configured and maintained.

Remember to:
- Start with basic configurations and gradually add complexity
- Regular maintenance prevents most issues
- Keep configurations documented and backed up
- Stay updated with both tmux and Neovim developments

For additional help, consult the official documentation and community resources mentioned in the README.
