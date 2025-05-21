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

### Split Pane Navigation

Navigating between split panes in Neovim is essential for efficient workflow:

| Keybinding | Description |
|------------|-------------|
| `<C-h>` | Move focus to the left split |
| `<C-j>` | Move focus to the down split |
| `<C-k>` | Move focus to the up split |
| `<C-l>` | Move focus to the right split |
| `<C-\>` | Move to previous split (when using tmux) |

#### Creating and Managing Splits

| Keybinding | Description |
|------------|-------------|
| `<leader>oh` | Open a horizontal split |
| `<leader>ov` | Open a vertical split |
| `<leader>cw` | Close the current split |

#### Resizing Splits

| Keybinding | Description |
|------------|-------------|
| `<C-w>>` | Increase width of current split |
| `<C-w><` | Decrease width of current split |
| `<C-w>+` | Increase height of current split |
| `<C-w>-` | Decrease height of current split |
| `<C-w>=` | Make all splits equal size |

These keybindings make it easy to work with multiple files side by side, compare code, or reference documentation while coding.

### Visual Mode Selection

Neovim offers multiple visual selection modes for different editing needs:

| Mode | How to Enter | Description |
|------|-------------|-------------|
| Character-wise Visual | `v` | Select characters one by one |
| Line-wise Visual | `V` (capital V) | Select entire lines |
| Block-wise Visual | `<C-v>` (Ctrl+v) | Select in a rectangular block pattern |
| Select mode | `gh` | Similar to visual but with different behavior |

#### Block Visual Mode Tips

Block Visual mode (`<C-v>`) is particularly powerful for:

- Editing multiple lines at once
- Adding text to the beginning/end of multiple lines
- Deleting columns of text
- Creating box-like selections

Common operations in Block Visual mode:

1. Press `<C-v>` to enter Block Visual mode
2. Use movement keys (hjkl) to select a rectangular region
3. To insert text at the beginning of each line:
   - Select the block at line beginnings
   - Press `I`, type your text, then press `<Esc>`
4. To append text at the end of each line:
   - Select the block at line ends
   - Press `A`, type your text, then press `<Esc>`
5. To delete a column of text:
   - Select the block/column
   - Press `d` to delete

This mode is invaluable for tabular data editing and code alignment.

#### Troubleshooting Block Visual Mode

If `<C-v>` (Ctrl+v) pastes text instead of entering Block Visual mode, your terminal or OS is likely intercepting the keystroke before Neovim can process it. Here are solutions:

1. **Use the alternative keystroke**: Neovim also recognizes `<C-q>` (Ctrl+q) for Block Visual mode
   
2. **Use the custom mapping in this config**: 
   - `<leader>vb` is mapped to enter Block Visual mode

3. **Configure your terminal**:
   - **Windows Terminal**: Open settings and remap the paste action
   - **macOS Terminal**: Go to Preferences → Keyboard and modify Ctrl+v binding
   - **iTerm2**: Go to Preferences → Profiles → Keys and remap Ctrl+v

4. **Check existing mappings**:
   - Run `:verbose map <C-v>` in Neovim to see if Ctrl+v is mapped to something else

If you're using a remote connection (SSH) or a terminal multiplexer like tmux, you might need additional configuration to get Ctrl+v working properly for Block Visual mode.

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

### AI-Powered Coding with Augment Code

This configuration includes [Augment Code](https://augmentcode.com), an AI-powered coding assistant that provides:

- **Context-aware code completions** that understand your entire codebase
- **Interactive chat** for asking questions about your code without leaving Neovim
- **Codebase understanding** for more relevant suggestions and answers

#### Augment Code Keybindings

| Keybinding | Description |
|------------|-------------|
| `<Tab>` | Accept Augment code suggestion |
| `<leader>ac` | Start Augment chat (normal mode) or chat about selection (visual mode) |
| `<leader>an` | Start a new Augment chat conversation |
| `<leader>at` | Toggle the Augment chat panel |

#### Getting Started with Augment Code

For detailed instructions on using Augment Code in Neovim, check out the [Augment Code for Neovim Wiki](wikis/augment-neovim-wiki/README.md), which includes:

1. [Getting Started with Augment Code](wikis/augment-neovim-wiki/01-getting-started-with-augment-code.md)
2. [Setting Up Augment Code](wikis/augment-neovim-wiki/02-setting-up-augment-code.md)
3. [Configuring Workspace Context](wikis/augment-neovim-wiki/03-configuring-workspace-context.md)
4. [Using Code Completions](wikis/augment-neovim-wiki/04-using-augment-code-completions.md)
5. [Using Augment Chat](wikis/augment-neovim-wiki/05-using-augment-chat.md)
6. [Advanced Configuration](wikis/augment-neovim-wiki/06-advanced-configuration.md)

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

