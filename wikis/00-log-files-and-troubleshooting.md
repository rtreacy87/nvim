# Log Files and Troubleshooting Guide

## Overview
When experiencing startup issues or unexpected behavior in Neovim, checking log files is often the first step in troubleshooting. This guide covers where to find various log files and how to interpret them.

## Neovim Log Files

### Actual Log Locations
Based on the current system structure, logs are found in:
- **Cache directory**: `~/.cache/nvim/` (contains plugin-specific logs like `fidget.nvim.log`)
- **Data directory**: `~/.local/share/nvim/` (contains `lazy/`, `mason/`, `telescope_history`)
- **No default `log/` subdirectory exists** - logs are scattered in different locations

### Accessing Logs
```bash
# Check what stdpath returns for logs
:lua print(vim.fn.stdpath('log'))

# Main Neovim log file (most recent errors):
tail -50 ~/.local/state/nvim/log

# Search for all log files:
find ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim -name "*.log"

# View log file sizes and dates:
ls -la ~/.local/state/nvim/*.log
```

### Current System Structure
```
~/.local/state/nvim/
├── log              # Main Neovim log file (110MB!)
├── lsp.log          # LSP-specific logs
├── mason.log        # Mason plugin logs
└── conform.log      # Code formatter logs

~/.local/share/nvim/
├── lazy/            # Plugin installations
├── mason/           # LSP/tool installations  
└── telescope_history

~/.cache/nvim/
└── fidget.nvim.log  # Progress notifications log (empty)
```

## LSP Log Files

### Enable LSP Logging
```lua
vim.lsp.set_log_level("debug")
```

### View LSP Logs
```bash
# LSP logs may be in various locations - search for them:
find ~/.cache/nvim ~/.local/share/nvim -name "*lsp*" -type f

# View in Neovim (if available)
:LspLog
```

## Plugin-Specific Logs

### Mason Plugin
```bash
# Mason logs may be in the mason directory
find ~/.local/share/nvim/mason -name "*.log" -type f
```

### Lazy Plugin Manager
Check `:Lazy` interface for plugin loading issues and errors.

### Treesitter
```bash
:TSInstallInfo  # Check parser installation status
```

## Common Troubleshooting Commands

### Check Neovim Health
```vim
:checkhealth
```

### View Startup Time
```bash
nvim --startuptime startup.log
```

### Debug Mode
```bash
nvim -V9startup.log  # Verbose logging level 9
```

## Quick Log Viewing Functions

Add these to your config for quick log access:

```lua
-- Quick log viewers
vim.api.nvim_create_user_command('LogView', function()
  vim.cmd('edit ' .. vim.fn.stdpath('log') .. '/log')
end, {})

vim.api.nvim_create_user_command('LspLogView', function()
  vim.cmd('edit ' .. vim.fn.stdpath('log') .. '/lsp.log')
end, {})
```

## Common Log Patterns to Look For

- **Plugin loading errors**: Look for `require` or `module not found` errors
- **LSP connection issues**: Check for server startup failures or communication errors  
- **Configuration syntax errors**: Lua syntax errors in your config files
- **Performance issues**: Long execution times in startup logs

## Next Steps
After identifying issues in the logs, refer to the specific plugin wikis in this directory for detailed troubleshooting steps.