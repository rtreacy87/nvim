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

You can also use the XDG-compliant path `~/.config/tmux/tmux.conf` if you prefer.

# Tmux Configuration Paths: `~/.tmux.conf` vs `~/.config/tmux/tmux.conf`

## Comparison

**~/.tmux.conf (Traditional)**
- Default location that tmux checks first
- Works on all tmux versions
- Widely documented in older tutorials and examples
- Doesn't require creating directories

**~/.config/tmux/tmux.conf (XDG-compliant)**
- Follows XDG Base Directory Specification
- Keeps configuration in the standard `~/.config` directory
- Better organization with other modern tools
- Supported in newer tmux versions (2.6+)
- Can keep plugins and other tmux files in same directory

## Recommendation

I recommend using `~/.config/tmux/tmux.conf` for these reasons:

1. It follows modern configuration standards (XDG)
2. Keeps your home directory cleaner
3. Allows better organization with subdirectories for plugins, scripts, etc.
4. Consistent with other modern tools that use `~/.config/`

If you choose this path, make sure to create the directory first:

````bash
# Create tmux config directory if it doesn't exist
mkdir -p ~/.config/tmux
````
When using the `~/.config/tmux/` directory, the correct filename is just `tmux.conf` (without the leading dot).

## Correct paths:
- `~/.tmux.conf` (traditional path with dot)
- `~/.config/tmux/tmux.conf` (XDG path without dot)

## Difference:
The leading dot in `~/.tmux.conf` makes it a hidden file in your home directory, which is a Unix convention for configuration files directly in the home folder. When the file is inside the dedicated `~/.config/tmux/` directory, the dot is no longer needed since the entire `.config` directory is already hidden.

## How tmux finds your config:
Tmux automatically checks for configuration in this order:
1. `~/.tmux.conf` (checks first)
2. `~/.config/tmux/tmux.conf` (checks second)

You don't need to explicitly tell tmux which one you're using - it will use the first one it finds. If both exist, it will use `~/.tmux.conf`.

If you want to force tmux to use a specific config file regardless of the default search paths, you can use the `-f` flag when starting tmux:

```bash
tmux -f ~/.config/tmux/tmux.conf
```

For a clean setup, I recommend using only one location and removing the other to avoid confusion.



### Essential Tmux Settings

Add these settings to `~/.config/tmux/tmux.conf`:

```bash
# Set prefix key to Ctrl-a (more comfortable than Ctrl-b)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

These commands are configuring the basic tmux prefix key. Here's what each line does:

1. `unbind C-b` - Removes the default prefix key binding (Ctrl+b)
2. `set-option -g prefix C-a` - Sets the new prefix key to Ctrl+a, which is easier to reach on most keyboards
3. `bind-key C-a send-prefix` - Allows you to press Ctrl+a twice to send an actual Ctrl+a to the terminal (useful when working with applications that use Ctrl+a, like the start-of-line command in Bash)

This change makes tmux more comfortable to use since Ctrl+a is easier to press with one hand than Ctrl+b. It's also the same prefix used by GNU Screen, which some users prefer for muscle memory reasons.

#### Tmux Prefix Key Options

The prefix key in tmux is the key combination you press before any tmux command. Here's a comparison of common options:

| Prefix Option | Command | Pros | Cons |
|---------------|---------|------|------|
| `Ctrl+a` | `set-option -g prefix C-a` | - Easier to reach with one hand<br>- Same as GNU Screen<br>- Close to home row<br>- Familiar for Screen users | - Conflicts with bash/readline beginning-of-line<br>- Requires unbinding default |
| `Ctrl+b` (default) | Default setting | - Works out of the box<br>- No conflicts with common terminal shortcuts<br>- No configuration needed | - Awkward to reach with one hand<br>- Requires finger stretching |
| `Ctrl+space` | `set-option -g prefix C-Space` | - Very easy to press<br>- Minimal conflicts<br>- Ergonomic | - May conflict with IME activation on some systems<br>- Less common, so harder to use on others' systems |
| `Alt+a` | `set-option -g prefix M-a` | - Doesn't conflict with Ctrl shortcuts<br>- Easy to reach | - Alt can be inconsistent across terminals<br>- May conflict with some applications |
| `Backtick (`)` | `set-option -g prefix \`` | - Single key (no modifier)<br>- Rarely used in terminal | - Requires escaping to type actual backtick<br>- Slower for frequent commands |
| `Caps Lock` | Requires OS-level remapping | - Dedicated, easy-to-reach key<br>- Otherwise rarely used | - Requires system configuration<br>- Not portable across systems |

## Why `Ctrl+a` is Recommended

`Ctrl+a` is recommended for these reasons:

1. **Ergonomics**: It's easier to press with one hand than `Ctrl+b`, reducing strain during long sessions
2. **Consistency**: It matches GNU Screen, making it easier to switch between tools
3. **Efficiency**: The key is closer to the home row, making commands faster to execute
4. **Community adoption**: It's a very common customization, so many tutorials and users are familiar with it

The only significant downside is that it conflicts with the bash/readline beginning-of-line shortcut. However, the third line in the configuration (`bind-key C-a send-prefix`) solves this by allowing you to press `Ctrl+a` twice to send an actual `Ctrl+a` to the terminal.


```bash
# Enable mouse support
set -g mouse on
```
This enables mouse support in tmux, allowing you to resize panes and select them by clicking.

```bash
# Set default terminal mode to 256color
set -g default-terminal "screen-256color"

# Enable true color support
set-option -ga terminal-overrides ",xterm-256color:Tc"
```
These settings enable 256 color support in tmux, which is necessary for proper color rendering in Neovim and other applications.

- `set -g default-terminal "screen-256color"` sets the default terminal type to `screen-256color`, which supports 256 colors.
- `set-option -ga terminal-overrides ",xterm-256color:Tc"` adds the `Tc` flag to the `xterm-256color` terminal type, enabling true color support.

#### Comparison of Terminal Color Options

| Setting | Command | Purpose | Benefits | Potential Issues |
|---------|---------|---------|----------|-----------------|
| `screen-256color` | `set -g default-terminal "screen-256color"` | Sets the base terminal type | - Compatible with most systems<br>- Supports 256 colors<br>- Works well with screen and tmux | - Doesn't support true color by itself<br>- May not work with all terminals |
| `tmux-256color` | `set -g default-terminal "tmux-256color"` | tmux-specific terminal type | - Optimized for tmux<br>- Better integration with some terminals | - Not available on all systems<br>- May require additional packages |
| `xterm-256color` | `set -g default-terminal "xterm-256color"` | xterm-compatible type | - Widely supported<br>- Good compatibility with GUI terminals | - May cause issues inside tmux<br>- Not optimized for tmux specifically |
| True color (`Tc`) | `set-option -ga terminal-overrides ",xterm-256color:Tc"` | Enables 24-bit color | - Supports 16 million colors<br>- Better color fidelity<br>- Required for modern themes | - Not supported by all terminals<br>- May need terminal configuration |
| RGB color | `set-option -ga terminal-overrides ",xterm-256color:RGB"` | Alternative true color | - Similar to Tc but with different implementation<br>- Works better with some terminals | - Less widely used than Tc<br>- May conflict with some applications |

## Why These Recommended Settings Work Best

The combination of `screen-256color` as the default terminal and adding the `Tc` flag for true color support provides the best balance of:

1. **Compatibility**: `screen-256color` is widely available and works well with tmux
2. **Color support**: The `Tc` flag enables true color (24-bit) support for terminals that can handle it
3. **Application support**: This configuration works well with Neovim, Vim, and other terminal applications
4. **Fallback behavior**: Terminals without true color support will still work with 256 colors

This setup ensures your terminal colors will look correct in most environments while providing the richest possible color experience in modern terminals.

If you're experiencing color issues, you might need to:
- Ensure your terminal emulator supports true color
- Set `$TERM=xterm-256color` in your shell before launching tmux
- Check that your Neovim/Vim configuration has `termguicolors` enabled

```bash
# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when a window is closed
set -g renumber-windows on
```
#### Why Start at Index 1 Instead of 0

Starting window and pane numbering at 1 instead of the default 0 offers several advantages:

1. **Keyboard layout**: The number keys 1-9 are in a row on the keyboard, making it easier to reach than starting with 0
2. **Intuitive counting**: Most people naturally count starting from 1, not 0
3. **Key mapping**: The number 1 is directly above the Q key, making it faster to access than 0
4. **Mental model**: Reduces the cognitive load of translating between "first window" and "window 0"

While programmers are used to 0-based indexing in code, for interactive use, 1-based indexing is often more natural and efficient.

## What `renumber-windows on` Does

The `renumber-windows on` setting automatically reorders your window numbers to be sequential when you close a window. 

For example:
- You have windows numbered 1, 2, 3, 4
- You close window 2
- Without renumbering: Windows would be 1, 3, 4
- With renumbering: Windows become 1, 2, 3

#### Benefits of Window Renumbering

1. **Predictable access**: Window numbers always match their position in the status bar
2. **Efficient keyboard shortcuts**: You can always use the lowest possible numbers (1-9) to access windows
3. **Mental mapping**: Eliminates gaps in numbering that can cause confusion
4. **Consistent navigation**: Makes it easier to remember which number corresponds to which window

This combination of 1-based indexing and automatic renumbering creates a more intuitive and efficient window management experience, especially when you frequently open and close windows during your workflow.


```bash
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
#### Command Details

##### `set -g history-limit 10000`
- **Purpose**: Increases the number of lines tmux remembers per pane
- **Default**: 2000 lines
- **Impact**: Allows you to scroll back through more output history
- **Use case**: Particularly valuable when reviewing logs, compiler output, or long command results
- **Trade-off**: Higher memory usage (10,000 lines × number of panes)
- **Recommendation**: Increase further (20,000-50,000) if you have sufficient RAM and frequently work with verbose output

##### `setw -g mode-keys vi`
- **Purpose**: Sets copy mode to use vi-style key bindings instead of emacs-style
- **Default**: emacs
- **Impact**: Allows using familiar vim motions (h,j,k,l, /, etc.) when navigating copy mode
- **Use case**: Essential for vim/neovim users to maintain consistent muscle memory
- **Related commands**: Works with copy mode bindings like `bind-key -T copy-mode-vi v send-keys -X begin-selection`

##### `set -s escape-time 10`
- **Purpose**: Reduces the delay after pressing Escape before tmux registers it as a separate key
- **Default**: 500ms
- **Impact**: Makes tmux feel more responsive, especially when using vim/neovim
- **Technical reason**: Terminals can't distinguish between a standalone Escape key and the start of an escape sequence
- **Trade-off**: Setting too low (0) might cause issues with some key combinations
- **Recommendation**: 10ms is a good balance; some users prefer 0-5ms for maximum responsiveness

##### `set -g status-interval 5`
- **Purpose**: Sets how often the status line updates
- **Default**: 15 seconds
- **Impact**: More frequent updates for status line information (clock, system stats, etc.)
- **Use case**: Useful when displaying dynamic information like battery level or system load
- **Trade-off**: More frequent updates use slightly more CPU
- **Recommendation**: 5 seconds is good for most users; reduce to 1-2 seconds if displaying rapidly changing information

##### `set -g focus-events on`
- **Purpose**: Enables terminal focus events to be passed to applications inside tmux
- **Default**: off
- **Impact**: Allows applications like vim/neovim to detect when their window gains/loses focus
- **Use case**: Enables features like auto-saving when focus is lost or reloading files when focus is gained
- **Compatibility**: Requires a terminal that supports focus events
- **Neovim benefit**: Works with `vim.opt.autoread` and the `FocusGained` autocmd event

##### `setw -g aggressive-resize on`
- **Purpose**: Makes tmux resize windows based on smallest client actually viewing the window
- **Default**: off
- **Impact**: Maximizes screen real estate when multiple clients are attached to the same session
- **Use case**: When viewing the same session on multiple monitors with different resolutions
- **Example scenario**: If you have tmux session open on both a laptop and external monitor, windows only visible on the larger monitor can use its full size
- **Alternative name**: Sometimes called "useful-layout" in documentation

### Vim-like Pane Navigation

Add these bindings for easier pane navigation, similar to vim/neovim split navigation, starting from the default prefix of `Ctrl-a`:

```bash
# Vim-like pane switching
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

With these bindings, you can use:
- `<C-a>h` to move to the left pane
- `<C-a>j` to move to the pane below
- `<C-a>k` to move to the pane above
- `<C-a>l` to move to the right pane

This works by:
1. First pressing your prefix key (`<C-a>` if you've set it to Ctrl+a)
2. Then pressing one of the vim movement keys (h, j, k, or l)

These bindings make navigation between tmux panes feel more like navigating between Vim/Neovim splits, which creates a more consistent experience when working with both tools.

#### What These Commands Do

These four commands create key bindings in tmux that allow you to navigate between panes using vim-style movement keys:

1. `bind h select-pane -L`: Binds the `h` key to select the pane to the left of the current pane
2. `bind j select-pane -D`: Binds the `j` key to select the pane below the current pane
3. `bind k select-pane -U`: Binds the `k` key to select the pane above the current pane
4. `bind l select-pane -R`: Binds the `l` key to select the pane to the right of the current pane

#### How They Work

Each line follows this pattern:
- `bind`: The tmux command to create a key binding
- `h/j/k/l`: The key to bind (after pressing the prefix key)
- `select-pane`: The tmux command to switch focus to another pane
- `-L/-D/-U/-R`: The direction flag (Left, Down, Up, Right)

#### Usage

To use these bindings:
1. Press your tmux prefix key (typically `Ctrl+a` if you've customized it)
2. Release the prefix key
3. Press one of the direction keys (h, j, k, or l)

For example, to move to the pane on the left:
- Press and hold `Ctrl`
- While holding `Ctrl`, press `a`
- Release both keys
- Press `h`

#### Benefits

1. **Vim consistency**: These bindings mirror vim's movement keys, creating muscle memory that works in both environments
2. **Ergonomics**: The h, j, k, l keys are on the home row, making them more comfortable for frequent use
3. **Intuitive**: The keys match their directional meaning (h=left, j=down, k=up, l=right)
4. **Efficiency**: Reduces the need to use arrow keys, which often requires moving your hand away from the home row

These bindings are particularly useful if you're already familiar with vim or neovim, as they create a consistent navigation experience across your entire terminal environment.



```bash
# Vim-like pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

## What These Commands Do

These four commands create key bindings in tmux that allow you to resize panes using uppercase vim-style movement keys:

1. `bind -r H resize-pane -L 5`: Binds the `H` key to reduce the pane's width by 5 cells from the left
2. `bind -r J resize-pane -D 5`: Binds the `J` key to increase the pane's height by 5 cells from the bottom
3. `bind -r K resize-pane -U 5`: Binds the `K` key to reduce the pane's height by 5 cells from the top
4. `bind -r L resize-pane -R 5`: Binds the `L` key to increase the pane's width by 5 cells from the right

## How They Work

Each line follows this pattern:
- `bind -r`: The tmux command to create a repeatable key binding
- `H/J/K/L`: The uppercase key to bind (after pressing the prefix key)
- `resize-pane`: The tmux command to change a pane's dimensions
- `-L/-D/-U/-R`: The direction flag (Left, Down, Up, Right)
- `5`: The number of cells to resize by each time

## The `-r` Flag Explained

The `-r` flag makes the binding repeatable, meaning:
1. You press the prefix key (`Ctrl+a`) once
2. Then you can press the bound key (H, J, K, or L) multiple times without pressing the prefix again
3. The repeat functionality times out after a short period (default is 500ms)

This allows for quick, multiple resizing operations without having to press the prefix key each time.

## Usage

To resize a pane:
1. Press your tmux prefix key (typically `Ctrl+a` if you've customized it)
2. Release the prefix key
3. Press one of the uppercase direction keys (H, J, K, or L)
4. Optionally, press the same key again multiple times to resize further

For example, to make a pane wider:
- Press and hold `Ctrl`
- While holding `Ctrl`, press `a`
- Release both keys
- Press `L` one or more times

## Benefits

1. **Intuitive mapping**: Uppercase versions of the navigation keys (H, J, K, L) for related but different operations
2. **Efficient resizing**: The repeatable flag allows quick adjustments without repeatedly pressing the prefix
3. **Precise control**: The 5-cell increment provides a good balance between precision and speed
4. **Vim-like approach**: Maintains the mental model of H=left, J=down, K=up, L=right, but for resizing

These bindings complement the lowercase navigation bindings, creating a consistent system where lowercase keys move between panes and uppercase keys resize them.



```bash
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
#### Tokyo Night Theme for Tmux

To match your Neovim Tokyo Night theme in tmux, you can add the following to your tmux configuration:

```bash
# Tokyo Night theme for tmux
# Default theme
set -g mode-style "fg=#7aa2f7,bg=#3b4261"

set -g message-style "fg=#7aa2f7,bg=#3b4261"
set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#7aa2f7"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#7aa2f7,bg=#1f2335"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#15161e,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1f2335,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#1f2335] #{prefix_highlight} #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161e,bg=#7aa2f7,bold] #h "

setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-format "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#1f2335,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]"
```

#### Alternative: Using Tmux Plugin Manager (TPM)

If you prefer using a plugin, you can install the Tokyo Night theme via TPM. First, make sure you have TPM installed, then add this to your config:

```bash
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'janoamaral/tokyo-night-tmux'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

Further details on using TPM can be found in the [Tmux Plugin Manager Basics](08-tmux-plugin-manager-basics.md) section.


### Apply Configuration

Reload tmux configuration:

```bash
# Reload config file
tmux source-file ~/.config/tmux/tmux.conf

# Or add a key binding to reload
# Add this to ~/.tmux.conf:
bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
```

### Troubleshooting Configuration Issues


If you encounter issues like:
```bash
tmux source-file ~/.config/tmux/tmux.conf                                        
no server running on /private/tmp/tmux-501/default
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
