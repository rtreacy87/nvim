# Installing and Configuring Treesitter in Neovim

This guide will walk you through the process of installing and configuring Treesitter in your Neovim setup. By the end, you'll have Treesitter up and running with your preferred languages.

## Prerequisites

Before installing Treesitter, make sure you have:

1. **Neovim 0.5.0 or newer** - Treesitter requires Neovim 0.5.0+
2. **Git** - Required for installing parsers
3. **A C compiler** - Needed to build the parsers:
   - Windows: MinGW or Visual Studio Build Tools
   - macOS: Xcode Command Line Tools
   - Linux: GCC or Clang

## Installation Methods

### Method 1: Using a Plugin Manager (Recommended)

The easiest way to install Treesitter is through a plugin manager like Lazy.nvim, Packer, or vim-plug.

#### Using Lazy.nvim

If you're using Lazy.nvim (as in your current setup), create or edit the file `lua/plugins/treesitter.lua`:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}
```

#### Using Packer

```lua
use {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end
}
```

#### Using vim-plug

```vim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" In your init.vim, after plug#end():
lua <<EOF
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
  auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
EOF
```

### Method 2: Manual Installation

If you prefer to install manually:

1. Clone the repository into your Neovim packages directory:

```bash
git clone https://github.com/nvim-treesitter/nvim-treesitter.git \
  ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter
```

2. Add the configuration to your `init.lua` or `init.vim`:

```lua
-- In init.lua
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
  auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
```

## Basic Configuration Options

Let's break down the basic configuration options:

### ensure_installed

This option specifies which language parsers to install:

```lua
ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown', 'python', 'javascript' }
```

You can also use `ensure_installed = "all"` to install all available parsers, but this is not recommended as it will use a lot of disk space.

### auto_install

When set to `true`, Treesitter will automatically install parsers for files you open:

```lua
auto_install = true
```

### highlight

Enables syntax highlighting:

```lua
highlight = {
  enable = true,
  -- Disable for specific languages
  disable = { "latex" },
  -- Use additional vim regex highlighting for specific languages
  additional_vim_regex_highlighting = { 'ruby' },
}
```

### indent

Enables indentation based on Treesitter:

```lua
indent = {
  enable = true,
  -- Disable for languages with problematic indentation
  disable = { 'python', 'ruby' },
}
```

## Installing Language Parsers

### Method 1: Using :TSInstall Command

Once Treesitter is installed, you can install parsers for specific languages using the `:TSInstall` command:

```
:TSInstall python javascript typescript lua
```

To see all available parsers:

```
:TSInstallInfo
```

### Method 2: Automatic Installation

If you've set `auto_install = true`, parsers will be installed automatically when you open a file of that type.

### Method 3: Ensuring Installation in Configuration

The `ensure_installed` option in your configuration will install the specified parsers when Neovim starts.

## Configuring Parser Installation Method

By default, Treesitter uses `curl` to download parsers. If you're having connectivity issues, you can configure it to use Git instead:

```lua
require('nvim-treesitter.install').prefer_git = true
```

## Checking Installation Status

To check which parsers are installed and their status:

```
:TSInstallInfo
```

This will show a list of all available parsers, whether they're installed, and their versions.

## Updating Parsers

To update all installed parsers:

```
:TSUpdate
```

To update a specific parser:

```
:TSUpdate python
```

## Complete Configuration Example

Here's a more comprehensive configuration example:

```lua
require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all"
  ensure_installed = { 
    'bash', 'c', 'cpp', 'css', 'html', 'javascript', 
    'json', 'lua', 'markdown', 'python', 'rust', 
    'typescript', 'vim', 'vimdoc', 'yaml'
  },
  
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  
  -- List of parsers to ignore installing (for "all")
  ignore_install = { "phpdoc" },
  
  -- Highlighting configuration
  highlight = {
    enable = true,
    
    -- Disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    additional_vim_regex_highlighting = false,
  },
  
  -- Indentation based on treesitter for the = operator
  indent = {
    enable = true,
    disable = { "yaml" },
  },
})
```

## Next Steps

Now that you have Treesitter installed and configured, the next guide will show you how to use Treesitter for syntax highlighting and customize it to your preferences.

Continue to [Syntax Highlighting with Treesitter](03-syntax-highlighting-with-treesitter.md).
