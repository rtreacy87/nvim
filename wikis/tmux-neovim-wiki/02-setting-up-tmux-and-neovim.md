# Setting Up Tmux and Neovim

This guide walks you through installing and configuring tmux and Neovim to create a solid foundation for integration.

## Installing Tmux

### macOS

Using Homebrew (recommended):
```bash
brew install tmux
```

Using MacPorts:
```bash
sudo port install tmux
```

### Linux

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install tmux
```

**CentOS/RHEL/Fedora:**
```bash
# CentOS/RHEL
sudo yum install tmux

# Fedora
sudo dnf install tmux
```

**Arch Linux:**
```bash
sudo pacman -S tmux
```

### Windows

**Using WSL (recommended):**
```bash
# Install in your WSL distribution
sudo apt install tmux
```

**Using Windows Package Manager:**
```powershell
winget install tmux
```

### Verify Installation

```bash
tmux -V
# Should output something like: tmux 3.3a
```

## Installing Neovim

### macOS

```bash
# Homebrew
brew install neovim

# MacPorts
sudo port install neovim
```

### Linux

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install neovim
```

**CentOS/RHEL/Fedora:**
```bash
# CentOS/RHEL
sudo yum install neovim

# Fedora
sudo dnf install neovim
```

**Arch Linux:**
```bash
sudo pacman -S neovim
```

### Windows

```powershell
# Windows Package Manager
winget install Neovim.Neovim

# Chocolatey
choco install neovim

# Scoop
scoop install neovim
```

### Verify Installation

```bash
nvim --version
# Should output version information
```

## Basic Tmux Configuration

Create or edit your tmux configuration file:

```bash
# Create the config file
touch ~/.tmux.conf
```

### Essential Tmux Settings

Add these settings to `~/.tmux.conf`:

```bash
# Set prefix key to Ctrl-a (more comfortable than Ctrl-b)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support
set -g mouse on

# Set default terminal mode to 256color
set -g default-terminal "screen-256color"

# Enable true color support
set-option -ga terminal-overrides ",xterm-256color:Tc"

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when a window is closed
set -g renumber-windows on

# Increase scrollback buffer size
set -g history-limit 10000

# Enable vi mode for copy mode
setw -g mode-keys vi

# Faster command sequences
set -s escape-time 10

# Refresh status line every 5 seconds
set -g status-interval 5

# Focus events enabled for terminals that support them
set -g focus-events on

# Super useful when using "grouped sessions" and multi-monitor setup
setw -g aggressive-resize on
```

### Vim-like Pane Navigation

Add these bindings for easier pane navigation:

```bash
# Vim-like pane switching
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Vim-like pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %
```

### Copy Mode Configuration

Configure copy mode to work like vim:

```bash
# Copy mode vim bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

# Copy to system clipboard (macOS)
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# Copy to system clipboard (Linux)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"

# Copy to system clipboard (WSL)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
```

### Status Bar Configuration

Customize the status bar for better information:

```bash
# Status bar configuration
set -g status-position bottom
set -g status-bg colour234
set -g status-fg colour137
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20

# Window status
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
```

### Apply Configuration

Reload tmux configuration:

```bash
# Reload config file
tmux source-file ~/.tmux.conf

# Or add a key binding to reload
# Add this to ~/.tmux.conf:
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
```

## Basic Neovim Configuration

Create your Neovim configuration directory:

```bash
# Create config directory
mkdir -p ~/.config/nvim
```

### Essential Neovim Settings

Create `~/.config/nvim/init.lua` with basic settings:

```lua
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Set leader key
vim.g.mapleader = " "

-- Terminal settings for tmux integration
vim.opt.title = true
vim.opt.titlestring = "nvim %F"

-- Enable mouse support
vim.opt.mouse = "a"

-- Better completion experience
vim.opt.completeopt = "menuone,noselect"

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
```

### Terminal Integration Settings

Add these settings for better terminal integration:

```lua
-- Terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- Terminal key mappings
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to below window" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to above window" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
```

## Testing the Setup

### Test Tmux

1. Start a new tmux session:
```bash
tmux new-session -s test
```

2. Create a vertical split:
```bash
# Press Ctrl-a then |
```

3. Navigate between panes:
```bash
# Press Ctrl-a then h/j/k/l
```

4. Enter copy mode:
```bash
# Press Ctrl-a then [
# Use vim motions to navigate
# Press q to exit
```

### Test Neovim

1. Open Neovim in one tmux pane:
```bash
nvim
```

2. Open a terminal in another pane:
```bash
# In the other tmux pane
python3
# or
node
# or any other interpreter
```

3. Test window navigation:
```bash
# In Neovim, try Ctrl-h/j/k/l to move between tmux panes
```

## Common Issues and Solutions

### Colors Not Working

If colors appear wrong, add this to your shell configuration:

```bash
# For bash (~/.bashrc) or zsh (~/.zshrc)
export TERM=xterm-256color

# Or for tmux specifically
alias tmux='tmux -2'
```

### Escape Key Delay

If there's a delay when pressing Escape, add to `~/.tmux.conf`:

```bash
set -s escape-time 0
```

### Mouse Not Working

Ensure mouse support is enabled in both tmux and Neovim:

```bash
# In ~/.tmux.conf
set -g mouse on

# In ~/.config/nvim/init.lua
vim.opt.mouse = "a"
```

## Next Steps

Now that you have tmux and Neovim properly configured, you're ready to learn about sending code from Neovim to terminal sessions.

Continue to [Sending Code to Terminal](03-sending-code-to-terminal.md).
