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

## SSH Key Issues

SSH keys typically require entering your passphrase each time you open a new shell, which becomes tedious. A better approach is using ssh-agent with a time limit, so you only enter your passphrase once every few hours while maintaining security. This allows opening multiple shells without repeated passphrase prompts.

```bash
# Function to start ssh-agent if needed
start_ssh_agent() {
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
        # Kill any existing ssh-agent processes
        pkill -u "$USER" ssh-agent 2>/dev/null
        
        # Start new ssh-agent
        eval "$(ssh-agent -t 8h -s)" > /dev/null
        
        # Add key if it exists
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
            ssh-add -t 8h "$HOME/.ssh/id_ed25519" 2>/dev/null
        fi
    fi
}
```
The following code block is setting up SSH agent management with a focus on tmux integration. Here's what it does:

 - `start_ssh_agent()` is a function that checks if an SSH agent is already running and starts one if not.
 - `if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then` checks if the `SSH_AUTH_SOCK` environment variable is not set or if the SSH agent doesn't have any keys added.
 - `pkill -u "$USER" ssh-agent 2>/dev/null` kills any existing SSH agent processes for the current user.
 - `eval "$(ssh-agent -t 8h -s)" > /dev/null` starts a new SSH agent with a 8-hour timeout.
 - `if [ -f "$HOME/.ssh/id_ed25519" ]; then` checks if the SSH key file exists.
 - `ssh-add -t 8h "$HOME/.ssh/id_ed25519" 2>/dev/null` adds the SSH key to the agent with a 8-hour timeout. 

Let me explain this code block in detail:

1. `start_ssh_agent() {`
   - Defines a shell function named `start_ssh_agent` that can be called later
   - Functions in shell scripts group commands for reuse

2. `if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then`
   - `-z "$SSH_AUTH_SOCK"` tests if the SSH_AUTH_SOCK variable is empty
   - The `-z` flag tests if a string is empty
   - `SSH_AUTH_SOCK` is the environment variable that points to the SSH agent socket
   - `||` is logical OR - the condition is true if either test is true
   - `! ssh-add -l >/dev/null 2>&1` tests if listing SSH keys fails
   - `ssh-add -l` lists keys in the SSH agent
   - `>/dev/null 2>&1` redirects both standard output and error output to /dev/null
   - This condition checks if either no SSH agent is running or the agent has no keys

3. `pkill -u "$USER" ssh-agent 2>/dev/null`
   - `pkill` sends a signal to processes matching a pattern
   - `-u "$USER"` limits to processes owned by the current user
   - `ssh-agent` is the process pattern to match
   - `2>/dev/null` suppresses error messages
   - This kills any existing SSH agent processes to avoid conflicts

4. `eval "$(ssh-agent -t 8h -s)" > /dev/null`
   - `ssh-agent -t 8h -s` starts a new SSH agent with an 8-hour timeout
   - `-t 8h` sets the lifetime of identities added to the agent to 8 hours
   - `-s` makes ssh-agent output shell commands for Bourne shell
   - `$()` captures the command output
   - `eval` executes the captured shell commands
   - `> /dev/null` suppresses standard output
   - This starts a new SSH agent and sets up the environment variables

5. `if [ -f "$HOME/.ssh/id_ed25519" ]; then`
   - `-f` tests if a file exists and is a regular file
   - `$HOME/.ssh/id_ed25519` is the path to an Ed25519 SSH key
   - This checks if the specified SSH key file exists

6. `ssh-add -t 8h "$HOME/.ssh/id_ed25519" 2>/dev/null`
   - `ssh-add` adds private key identities to the SSH agent
   - `-t 8h` sets an 8-hour timeout for this specific key
   - `"$HOME/.ssh/id_ed25519"` is the path to the key file
   - `2>/dev/null` suppresses error messages
   - This adds the SSH key to the agent with an 8-hour timeout

7. The nested `fi` statements close their respective `if` blocks

This function efficiently manages the SSH agent by:
- Only starting a new agent if needed
- Setting timeouts to balance security and convenience
- Automatically adding your SSH key
- Suppressing unnecessary output for cleaner shell experience


```bash
# Handle tmux sessions differently
if [ -n "$TMUX" ]; then # In tmux, try to use the forwarded agent first
    tmux_auth_sock=$(tmux show-environment 2>/dev/null | grep "^SSH_AUTH_SOCK=" | cut -d= -f2-)
    if [ -n "$tmux_auth_sock" ] && [ -S "$tmux_auth_sock" ]; then
        export SSH_AUTH_SOCK="$tmux_auth_sock"
    fi
    
    # Test if the agent is working, if not start a new one
    if ! ssh-add -l >/dev/null 2>&1; then
        start_ssh_agent
        # Update tmux environment with new agent
        tmux set-environment SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
    fi
else
    # Not in tmux, use regular logic
    start_ssh_agent
fi
```
The following code block is setting up SSH agent management with a focus on tmux integration. Here's what it does:

 - `if [ -n "$TMUX" ]; then` checks if the `TMUX` environment variable is set, which indicates that we are inside a tmux session.
 - `tmux_auth_sock=$(tmux show-environment 2>/dev/null | grep "^SSH_AUTH_SOCK=" | cut -d= -f2-)` gets the SSH agent socket from the tmux environment.
 - `if [ -n "$tmux_auth_sock" ] && [ -S "$tmux_auth_sock" ]; then` checks if the tmux agent socket exists and is a valid socket.
 - `export SSH_AUTH_SOCK="$tmux_auth_sock"` sets the `SSH_AUTH_SOCK` environment variable to the tmux agent socket.
 - `if ! ssh-add -l >/dev/null 2>&1; then` checks if the SSH agent is working by listing the keys.
 - `start_ssh_agent` starts a new SSH agent if the current one is not working.
 - `tmux set-environment SSH_AUTH_SOCK "$SSH_AUTH_SOCK"` updates the tmux environment with the new SSH agent socket.
 - `else` handles the case when not in a tmux session.
 - `start_ssh_agent` starts a new SSH agent if needed.

Breaking it down line by line:

1. `if [ -n "$TMUX" ]; then`
   - The `-n` flag tests if a string is non-empty
   - `$TMUX` is an environment variable that exists only when inside a tmux session
   - This condition checks if we're currently running inside a tmux session

2. `tmux_auth_sock=$(tmux show-environment 2>/dev/null | grep "^SSH_AUTH_SOCK=" | cut -d= -f2-)`
   - `tmux show-environment` displays tmux's environment variables
   - `2>/dev/null` redirects error output to /dev/null (suppresses errors)
   - `grep "^SSH_AUTH_SOCK="` filters for lines starting with "SSH_AUTH_SOCK="
   - `cut -d= -f2-` splits the line at "=" and returns everything after it
   - The result is stored in the `tmux_auth_sock` variable

3. `if [ -n "$tmux_auth_sock" ] && [ -S "$tmux_auth_sock" ]; then`
   - `-n "$tmux_auth_sock"` checks if we found an SSH_AUTH_SOCK in tmux's environment
   - `-S "$tmux_auth_sock"` tests if the path exists and is a socket file
   - `&&` is logical AND - both conditions must be true

4. `export SSH_AUTH_SOCK="$tmux_auth_sock"`
   - Sets the SSH_AUTH_SOCK environment variable to use tmux's socket
   - This connects the current shell to the existing SSH agent

5. `if ! ssh-add -l >/dev/null 2>&1; then`
   - `ssh-add -l` lists keys in the SSH agent
   - `>/dev/null 2>&1` redirects both standard and error output to /dev/null
   - `!` negates the result - this condition is true if the command fails
   - This tests if the SSH agent is working properly

6. `start_ssh_agent`
   - Calls the function defined earlier to start a new SSH agent
   - Only runs if the existing agent isn't working

7. `tmux set-environment SSH_AUTH_SOCK "$SSH_AUTH_SOCK"`
   - Updates tmux's environment with the new SSH agent socket
   - This makes the new agent available to other tmux panes/windows

8. `else` and `start_ssh_agent`
   - If not in tmux, simply start/check the SSH agent normally

This code solves the "lost SSH agent" problem in tmux by ensuring the SSH agent socket is properly shared across all tmux panes and windows, while also handling non-tmux shells appropriately.


```bash
export PASSWORD_STORE_ENABLE_GIT=true
export PATH="$HOME/bin:$PATH"
```
The highlighted code is setting two environment variables:

1. `export PASSWORD_STORE_ENABLE_GIT=true` - This enables Git integration for the `pass` password manager (Password Store). When set to true, it allows the password store to automatically commit changes to a Git repository, providing version control for your passwords.

2. `export PATH="$HOME/bin:$PATH"` - This adds the `~/bin` directory to your PATH environment variable. The PATH variable tells your shell where to look for executable files. By adding `$HOME/bin` at the beginning of the PATH, you're giving priority to executables in your personal bin directory over system-wide executables with the same name.

These lines are unrelated to the SSH agent configuration above them and appear to be additional environment settings that would typically be found in a shell configuration file like `.bashrc` or `.zshrc`.



The selected code is setting up SSH agent management with a focus on tmux integration. Here's what it does:

1. The `start_ssh_agent()` function:
   - Checks if SSH agent is running or accessible
   - Kills any existing SSH agent processes for the current user
   - Starts a new SSH agent with an 8-hour timeout (`-t 8h`)
   - Adds your SSH key (if it exists) with the same 8-hour timeout

2. The tmux-specific handling:
   - Detects if you're running inside a tmux session (`if [ -n "$TMUX" ]`)
   - If in tmux, it tries to use the SSH agent socket that tmux knows about
   - Checks if that agent is working, and if not, starts a new one
   - Updates tmux's environment with the new SSH agent socket

3. The non-tmux case:
   - If not running in tmux, simply calls the `start_ssh_agent` function

This setup solves two common SSH agent problems:
- It prevents you from having to enter your passphrase for every new shell by using timeouts
- It handles the "lost SSH agent" problem in tmux sessions (where new panes/windows can't access the agent)

The 8-hour timeout means you'll only need to enter your passphrase once per 8-hour period, rather than every time you open a new shell or tmux pane.


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
