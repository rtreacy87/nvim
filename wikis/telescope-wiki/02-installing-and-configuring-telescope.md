# Installing and Configuring Telescope in Neovim

This guide will walk you through the process of installing Telescope and its dependencies, and setting up a basic configuration to get you started.

## Prerequisites

Before installing Telescope, ensure you have:

1. Neovim 0.5.0 or newer (0.7.0+ recommended)
2. Git installed on your system
3. A package manager for Neovim (we'll cover several options)
4. (Optional) A C compiler for building telescope-fzf-native

## Installation Methods

### Using Lazy.nvim

If you're using the [lazy.nvim](https://github.com/folke/lazy.nvim) package manager:

```lua
-- In your plugins.lua or equivalent
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Optional dependencies
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-tree/nvim-web-devicons',
  }
}
```
Let's break down the optional dependencies:

```lua
'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
```

This is the C-compiled extension for Telescope that implements the FZF algorithm in native code. 

The `build = 'make'` parameter is essential as it tells your plugin manager to run the `make` command after downloading the plugin. This compiles the C code into a binary that Telescope can use. Without this compilation step, the extension won't work properly.

This native implementation significantly improves sorting performance compared to the Lua-only implementation, especially for large result sets. If you're on Windows, you might need a different build command as mentioned in the troubleshooting wiki - you could use the cmake option instead:

```lua
{ 'nvim-telescope/telescope-fzf-native.nvim', 
  build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' 
},
```

```lua
'nvim-tree/nvim-web-devicons'
```

This plugin provides filetype icons, enhancing the visual appearance of Telescope. It's optional but recommended for a better user experience. Generally, it's a good idea to have a Nerd Font installed in your terminal for optimal results. You can set it as optional in your plugin configuration:

```lua
{ 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
```


### Using Packer.nvim

If you're using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'nvim-telescope/telescope.nvim',
  requires = {
    {'nvim-lua/plenary.nvim'},
    -- Optional dependencies
    {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
    {'nvim-tree/nvim-web-devicons'}
  }
}
```

### Using Vim-Plug

If you're using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
" In your init.vim or .vimrc
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }
" Optional dependencies
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-tree/nvim-web-devicons'
```

## Required Dependencies

### Plenary.nvim

Plenary is a Lua library that provides useful functions used by Telescope and other Neovim plugins. It's a required dependency for Telescope.

## Optional Dependencies

### telescope-fzf-native.nvim

This extension provides better sorting performance by using the fzf algorithm implemented in C:

```lua
-- After installing, load the extension
require('telescope').load_extension('fzf')
```

### nvim-web-devicons

This plugin provides filetype icons, enhancing the visual appearance of Telescope:

```lua
-- No additional setup needed if you just want the default icons
-- For customization, refer to the nvim-web-devicons documentation
```

### telescope-ui-select.nvim

This extension replaces Neovim's built-in select UI with Telescope:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-ui-select.nvim' }

-- In your Telescope setup
require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {}
    }
  }
}
require('telescope').load_extension('ui-select')
```

## Basic Configuration

Here's a minimal configuration to get you started with Telescope:

```lua
-- In your init.lua or equivalent
require('telescope').setup {
  defaults = {
    -- Default configuration for telescope
    mappings = {
      i = {
        -- Insert mode mappings
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-c>"] = "close",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
      }
    }
  },
  pickers = {
    -- Configurations for specific pickers
    find_files = {
      -- theme = "dropdown",
      -- hidden = true,
    }
  },
  extensions = {
    -- Configurations for extensions
  }
}
```

## Setting Up Keymaps

Telescope works best with convenient keymaps. Here's a recommended set:

```lua
-- In your keymaps configuration
local builtin = require('telescope.builtin')
-- File pickers
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
-- Text search pickers
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
-- LSP pickers
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = '[S]earch [L]SP [R]eferences' })
vim.keymap.set('n', '<leader>ld', builtin.lsp_definitions, { desc = '[S]earch [L]SP [D]efinitions' })
-- Navigation pickers
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
-- Git pickers
vim.keymap.set('n', '<leader>sgc', builtin.git_commits, { desc = '[S]earch Git [C]ommits' })
vim.keymap.set('n', '<leader>sgs', builtin.git_status, { desc = '[S]earch Git [S]tatus' })
```
What is nice about the current mapping is that having everything start with s is that you can just type s and then hit tab to see all the options. 

## Verifying Your Installation

After installing and configuring Telescope, you can verify it's working correctly:

1. Open Neovim
2. Run the command `:checkhealth telescope`
3. Ensure there are no critical errors
4. Try a basic picker with `:Telescope find_files`

## Troubleshooting Common Installation Issues

### Missing Dependencies

If you see errors about missing modules:

```
Error: module 'plenary' not found
```

Ensure you've installed all required dependencies and they're loading correctly.

### FZF Native Build Issues

If telescope-fzf-native.nvim fails to build:

1. Ensure you have a C compiler installed (gcc, clang, etc.)
2. Check the build logs for specific errors
3. Try building manually:
   ```
   cd ~/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim
   make
   ```

### Icons Not Displaying

If icons aren't showing up:

1. Ensure you've installed nvim-web-devicons
2. Verify you're using a Nerd Font in your terminal
3. Check if your terminal supports the icons

## Next Steps

Now that you have Telescope installed and configured, the next guide will cover basic usage patterns and how to effectively use the built-in pickers.

Continue to [Basic Telescope Usage](03-basic-telescope-usage.md).
