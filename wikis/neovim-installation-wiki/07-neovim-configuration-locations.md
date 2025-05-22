# Neovim Configuration Locations

This guide explains where Neovim stores its configuration files across different operating systems and how to set up a basic configuration structure.

## Understanding Neovim's Configuration System

Neovim follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html), which defines standard locations for configuration files, data files, and cache files.

### Key Directories

Neovim uses three main directories:

1. **Config directory**: Contains configuration files like `init.lua` or `init.vim`
2. **Data directory**: Stores persistent data like plugins, shada file, etc.
3. **State directory**: Stores state information like undo history, logs, etc.

## Configuration Locations by Platform

### Linux and macOS

On Unix-like systems (Linux, macOS, BSD), Neovim uses these default locations:

| Directory Type | Default Location | Environment Variable |
|----------------|------------------|----------------------|
| Config | `~/.config/nvim/` | `$XDG_CONFIG_HOME/nvim/` |
| Data | `~/.local/share/nvim/` | `$XDG_DATA_HOME/nvim/` |
| State | `~/.local/state/nvim/` | `$XDG_STATE_HOME/nvim/` |
| Cache | `~/.cache/nvim/` | `$XDG_CACHE_HOME/nvim/` |

### Windows

On Windows, Neovim uses these default locations:

| Directory Type | Default Location | Environment Variable |
|----------------|------------------|----------------------|
| Config | `%LOCALAPPDATA%\nvim\` | `$XDG_CONFIG_HOME\nvim\` |
| Data | `%LOCALAPPDATA%\nvim-data\` | `$XDG_DATA_HOME\nvim\` |
| State | `%LOCALAPPDATA%\nvim-data\` | `$XDG_STATE_HOME\nvim\` |
| Cache | `%LOCALAPPDATA%\nvim-data\` | `$XDG_CACHE_HOME\nvim\` |

In PowerShell, these paths typically resolve to:
- `C:\Users\<Username>\AppData\Local\nvim\`
- `C:\Users\<Username>\AppData\Local\nvim-data\`

### WSL (Windows Subsystem for Linux)

When using Neovim in WSL, it follows the Linux directory structure:

| Directory Type | Default Location |
|----------------|------------------|
| Config | `~/.config/nvim/` |
| Data | `~/.local/share/nvim/` |
| State | `~/.local/state/nvim/` |
| Cache | `~/.cache/nvim/` |

## Creating the Configuration Structure

### Basic Directory Setup

To set up the basic directory structure:

#### Linux/macOS/WSL

```bash
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site
mkdir -p ~/.local/state/nvim
mkdir -p ~/.cache/nvim
```

#### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA\nvim
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA\nvim-data\site
```

### Configuration File Options

Neovim supports two main configuration file formats:

1. **init.vim**: Traditional Vimscript configuration
2. **init.lua**: Lua-based configuration (recommended for new users)

You can choose either format based on your preference and familiarity.

#### Using init.vim

Create a basic `init.vim` file:

```bash
# Linux/macOS/WSL
touch ~/.config/nvim/init.vim

# Windows (PowerShell)
New-Item -ItemType File -Force -Path $env:LOCALAPPDATA\nvim\init.vim
```

Example content for `init.vim`:

```vim
" Basic settings
set number
set relativenumber
set mouse=a
set ignorecase
set smartcase
set nohlsearch
set wrap
set breakindent
set tabstop=2
set shiftwidth=2
set expandtab

" Set leader key to space
let mapleader = " "
let maplocalleader = " "

" Basic keymaps
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>

" Highlight on yank
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END
```

#### Using init.lua (Recommended)

Create a basic `init.lua` file:

```bash
# Linux/macOS/WSL
touch ~/.config/nvim/init.lua

# Windows (PowerShell)
New-Item -ItemType File -Force -Path $env:LOCALAPPDATA\nvim\init.lua
```

Example content for `init.lua`:

```lua
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  pattern = '*',
})
```

## Modular Configuration Structure

For larger configurations, a modular structure is recommended:

### Lua-Based Modular Structure

Create this directory structure:

```
nvim/
├── init.lua              # Main configuration file
├── lua/
│   ├── options.lua       # Vim options
│   ├── keymaps.lua       # Key mappings
│   ├── plugins.lua       # Plugin management
│   └── plugin/           # Plugin-specific configurations
│       ├── lsp.lua       # LSP configuration
│       ├── treesitter.lua # Treesitter configuration
│       └── ...
```

Example `init.lua` for modular configuration:

```lua
-- Load core modules
require('options')    -- Load lua/options.lua
require('keymaps')    -- Load lua/keymaps.lua
require('plugins')    -- Load lua/plugins.lua

-- Plugin-specific configurations are typically loaded by the plugin manager
```

Example `lua/options.lua`:

```lua
-- Set options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
-- ... more options
```

Example `lua/keymaps.lua`:

```lua
-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Define keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
-- ... more keymaps
```

## Plugin Directories

Plugins are typically installed in the data directory:

### Plugin Manager Locations

Different plugin managers use different locations:

#### vim-plug

```
Linux/macOS: ~/.local/share/nvim/plugged/
Windows: %LOCALAPPDATA%\nvim-data\plugged\
```

#### packer.nvim

```
Linux/macOS: ~/.local/share/nvim/site/pack/packer/
Windows: %LOCALAPPDATA%\nvim-data\site\pack\packer\
```

#### lazy.nvim

```
Linux/macOS: ~/.local/share/nvim/lazy/
Windows: %LOCALAPPDATA%\nvim-data\lazy\
```

## Runtime Files

Neovim also looks for runtime files in specific locations:

### Runtime Directories

Neovim searches these directories in order:

1. `$XDG_CONFIG_HOME/nvim`
2. `$XDG_DATA_HOME/nvim/site`
3. `$VIM/vimfiles`
4. `$VIMRUNTIME`
5. `$VIM/vimfiles/after`
6. `$XDG_DATA_HOME/nvim/site/after`
7. `$XDG_CONFIG_HOME/nvim/after`

### Common Runtime Files

- `colors/`: Color schemes
- `syntax/`: Syntax files
- `ftplugin/`: Filetype-specific settings
- `autoload/`: Automatically loaded functions
- `plugin/`: Plugin scripts loaded at startup

## Migration from Vim

If you're migrating from Vim to Neovim:

### Automatic Migration

Neovim can use your existing Vim configuration:

```
:help nvim-from-vim
```

Neovim will look for Vim configuration in:
- Linux/macOS: `~/.vim/` and `~/.vimrc`
- Windows: `$HOME/vimfiles/` and `$HOME/_vimrc`

### Manual Migration

To manually migrate:

1. **Copy your vimrc**:
   ```bash
   # Linux/macOS
   cp ~/.vimrc ~/.config/nvim/init.vim

   # Windows (PowerShell)
   Copy-Item -Path $HOME\_vimrc -Destination $env:LOCALAPPDATA\nvim\init.vim
   ```

2. **Update Neovim-specific settings**:
   - Replace `set` with `vim.opt` in Lua
   - Replace `let` with `vim.g` for global variables
   - Update plugin paths

## Checking Configuration Paths

To check where Neovim is looking for configuration files:

```vim
:echo stdpath('config')   " Configuration directory
:echo stdpath('data')     " Data directory
:echo stdpath('state')    " State directory
:echo stdpath('cache')    " Cache directory
```

## Next Steps

Now that you understand Neovim's configuration locations, you can:

- Set up a plugin manager to extend Neovim's functionality
- Customize your configuration based on your workflow
- Explore the other guides in this wiki series for platform-specific installation and upgrading instructions
