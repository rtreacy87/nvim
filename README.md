# My Neovim Configuration

## Introduction

This is a customized Neovim configuration based on kickstart.nvim. It provides:

* A modular plugin system
* Comprehensive language support
* Intuitive keybindings
* Powerful editing tools

This README will help you understand the key features and how to use them effectively, especially if you're new to Neovim.

## About This Configuration

This configuration is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), a well-documented starting point for Neovim. I've customized it to create a more modular structure where plugins are organized in separate files.

### Requirements

- Neovim (version 0.9.0 or newer)
- Git
- A terminal that supports true colors
- Optional but recommended: A [Nerd Font](https://www.nerdfonts.com/) for icons
- For Python development: Node.js (for pyright language server)

For detailed installation instructions for Neovim and its dependencies, refer to the [kickstart.nvim documentation](https://github.com/nvim-lua/kickstart.nvim).

## Keymaps and Features Guide

This section provides a comprehensive overview of the keybindings and features in this Neovim configuration. It's especially useful if you're new to Neovim or need a quick reference.

### Basic Navigation

If you're new to Vim/Neovim, here are the essential movement keys:

- `h` - Move left
- `j` - Move down
- `k` - Move up
- `l` - Move right
- `w` - Move forward by word
- `b` - Move backward by word
- `0` - Move to start of line
- `$` - Move to end of line
- `gg` - Go to top of file
- `G` - Go to bottom of file

Modes in Neovim:
- **Normal mode**: Default mode for navigation (press `Esc` to return to this mode)
- **Insert mode**: For typing text (press `i` to enter)
- **Visual mode**: For selecting text (press `v` to enter)
- **Command mode**: For entering commands (press `:` to enter)

### Key Mappings

> Note: The Space key is used as the leader key (`<leader>`) in this configuration.

#### General Keymaps

| Keybinding | Description |
|------------|-------------|
| `<Esc>` | Clear search highlighting |
| `<leader>e` | Show diagnostic error messages |
| `<leader>q` | Open diagnostic quickfix list |

#### Window Management

| Keybinding | Description |
|------------|-------------|
| `<C-h>` | Move focus to the left window |
| `<C-j>` | Move focus to the lower window |
| `<C-k>` | Move focus to the upper window |
| `<C-l>` | Move focus to the right window |
| `<leader>oh` | Open a horizontal split |
| `<leader>ov` | Open a vertical split |
| `<leader>cw` | Close the current window |

#### File Navigation

| Keybinding | Description |
|------------|-------------|
| `<C-n>` | Open file explorer on the left |
| `<C-r>` | Open file explorer on the right |

#### LSP (Language Server Protocol) Keymaps

These keybindings are available when a Language Server is active:

| Keybinding | Description |
|------------|-------------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Go to type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `K` | Show hover documentation |

#### Telescope Keymaps

Telescope is a powerful fuzzy finder:

| Keybinding | Description |
|------------|-------------|
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search keymaps |
| `<leader>sf` | Search files |
| `<leader>ss` | Search select telescope |
| `<leader>sw` | Search current word |
| `<leader>sg` | Search by grep |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume previous search |
| `<leader>s.` | Search recent files |
| `<leader><leader>` | Find existing buffers |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader>s/` | Search in open files |
| `<leader>sn` | Search Neovim config files |

#### Terminal Keymaps

| Keybinding | Description |
|------------|-------------|
| `<leader>ot` | Open a terminal window |
| `<Esc><Esc>` | Exit terminal mode |

#### Markdown Keymaps

| Keybinding | Description |
|------------|-------------|
| `<leader>om` | Open markdown preview |
| `<leader>cm` | Close markdown preview |
| `<leader>tm` | Toggle table mode (for editing markdown tables) |

### Installed Plugins

This Neovim configuration includes the following plugins:

#### Core Plugins

- **lazy.nvim**: Plugin manager that loads plugins on-demand for faster startup
- **which-key.nvim**: Displays available keybindings in a popup
- **plenary.nvim**: Utility functions used by other plugins

#### UI Enhancements

- **tokyonight.nvim**: A clean, dark color scheme
- **mini.nvim**: Collection of minimal, independent plugins including statusline
- **nvim-web-devicons**: Adds file icons (requires a Nerd Font)
- **todo-comments.nvim**: Highlights and allows searching for TODO comments

#### Code Intelligence

- **nvim-lspconfig**: Configuration for Language Server Protocol
- **mason.nvim**: Package manager for LSP servers, linters, and formatters
- **nvim-cmp**: Autocompletion plugin
- **LuaSnip**: Snippet engine
- **treesitter**: Advanced syntax highlighting and code understanding

#### File Management

- **neo-tree.nvim**: File explorer with tree view
- **telescope.nvim**: Fuzzy finder for files, buffers, and more
- **gitsigns.nvim**: Shows git changes in the sign column

#### Editing Tools

- **Comment.nvim**: Easy code commenting
- **conform.nvim**: Code formatting
- **vim-sleuth**: Automatically adjusts 'shiftwidth' and 'expandtab' based on file
- **vim-slime**: REPL integration for interactive coding
- **nvim-jqx**: JSON/YAML tools
- **table-mode**: Easy table creation and formatting in markdown

#### Language Support

- **markdown-preview**: Live preview for markdown files
- **tmux-vim-navigator**: Seamless navigation between tmux panes and vim splits

### Plugin Options and Customization

#### Telescope

Telescope is a highly customizable fuzzy finder. You can:
- Use `<C-/>` in insert mode or `?` in normal mode to see available keybindings
- Customize the appearance with themes (currently using dropdown for UI-select)
- Extend functionality with extensions (fzf and ui-select are enabled)

#### Neo-tree

Neo-tree is a file explorer that:
- Shows file icons when using a Nerd Font
- Supports git status indicators
- Can be opened on either side of the screen

#### LSP Configuration

Language servers provide intelligent code features:
- Automatic installation through Mason
- Configured for Python (pyright) and Lua (lua_ls)
- Add more language servers by modifying the `servers` table in `lua/plugins/nvim-lspconfig.lua`

#### Treesitter

Treesitter provides advanced syntax highlighting:
- Auto-installs parsers for languages you use
- Currently configured for bash, c, diff, html, lua, markdown, vim
- Add more languages by modifying the `ensure_installed` table in `lua/plugins/treesitter.lua`

### Modifying Your Configuration

This Neovim setup uses a modular structure:

1. Each plugin has its own file in `lua/plugins/`
2. Add new plugins by creating new files in this directory
3. Remove plugins by deleting their files
4. General settings are in `lua/options.lua` and keymaps in `lua/keymaps.lua`

