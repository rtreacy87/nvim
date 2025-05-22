# Code Navigation with Treesitter

Treesitter's understanding of code structure enables powerful navigation features. This guide will show you how to navigate your code more efficiently using Treesitter.

## Basic Navigation Concepts

Treesitter navigation is based on the syntax tree it builds from your code. This allows you to:

1. Navigate between structural elements (functions, classes, blocks)
2. Fold code based on its structure
3. Get a visual overview of your code's structure
4. Jump to specific parts of your code

## Navigating Code Structure

### Using Treesitter for Folding

Treesitter provides smart, structure-aware code folding. To enable it:

```lua
require('nvim-treesitter.configs').setup({
  fold = {
    enable = true,
  },
})
```

Then set Neovim to use Treesitter for folding:

```lua
-- In your init.lua or after/plugin/treesitter.lua
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- Start with all folds open
vim.opt.foldenable = false
```

With Treesitter folding enabled, you can:

- Use `zc` to close a fold
- Use `zo` to open a fold
- Use `za` to toggle a fold
- Use `zM` to close all folds
- Use `zR` to open all folds

Treesitter folding is aware of code structure, so it will fold functions, classes, and blocks correctly.

### Jumping Between Functions and Methods

To jump between functions and methods, you can use the built-in Treesitter navigation commands:

```vim
:TSJump function
```

This will jump to the next function in the file. You can also jump to other node types:

```vim
:TSJump class
:TSJump if_statement
:TSJump for_statement
```

For easier navigation, you can create keymaps:

```lua
-- Jump to next function
vim.keymap.set('n', ']]', function()
  require('nvim-treesitter.textobjects.move').goto_next_start('@function.outer')
end, { desc = 'Next function' })

-- Jump to previous function
vim.keymap.set('n', '[[', function()
  require('nvim-treesitter.textobjects.move').goto_previous_start('@function.outer')
end, { desc = 'Previous function' })
```

Note: This requires the `nvim-treesitter/nvim-treesitter-textobjects` plugin.

## Visualizing Code Structure

### Using Treesitter Context

The `nvim-treesitter-context` plugin shows the context of your current position in the code:

```lua
use {
  'nvim-treesitter/nvim-treesitter-context',
  requires = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('treesitter-context').setup({
      enable = true,
      max_lines = 3,
      trim_scope = 'outer',
    })
  end
}
```

With this plugin, you'll see the function, class, or block you're currently in at the top of the screen, even if it's scrolled out of view.

### Using Symbols Outline

For a more comprehensive view of your code structure, you can use the `symbols-outline.nvim` plugin:

```lua
use {
  'simrat39/symbols-outline.nvim',
  config = function()
    require('symbols-outline').setup()
  end
}
```

This plugin provides a tree-like view of symbols in your code, powered by Treesitter.

## Enhanced Code Folding

### Custom Fold Text

You can customize how folded text appears:

```lua
vim.opt.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').' ... '.trim(getline(v:foldend))]]
vim.opt.fillchars = { fold = ' ' }
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
```

### Preserving Folds

To preserve your folds between sessions:

```lua
-- Create an autocommand group for fold saving
local fold_augroup = vim.api.nvim_create_augroup('remember_folds', { clear = true })

-- Save folds when exiting a buffer
vim.api.nvim_create_autocmd('BufWinLeave', {
  pattern = '*.*',
  command = 'mkview',
  group = fold_augroup,
})

-- Load folds when entering a buffer
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*.*',
  command = 'silent! loadview',
  group = fold_augroup,
})
```

## Advanced Navigation with Treesitter Textobjects

The `nvim-treesitter-textobjects` plugin provides enhanced navigation capabilities:

```lua
use {
  'nvim-treesitter/nvim-treesitter-textobjects',
  requires = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('nvim-treesitter.configs').setup({
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
      },
    })
  end
}
```

With this configuration, you can:

- Use `]m` to jump to the next function start
- Use `]M` to jump to the next function end
- Use `[m` to jump to the previous function start
- Use `[M` to jump to the previous function end
- Use `]]` to jump to the next class start
- Use `][` to jump to the next class end
- Use `[[` to jump to the previous class start
- Use `[]` to jump to the previous class end

## Navigating with Telescope and Treesitter

The Telescope fuzzy finder can be integrated with Treesitter to navigate symbols in your code:

```lua
use {
  'nvim-telescope/telescope.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup()
    telescope.load_extension('aerial')
    
    -- Keymaps for Telescope + Treesitter navigation
    vim.keymap.set('n', '<leader>fs', require('telescope.builtin').treesitter, 
      { desc = 'Find symbols with Treesitter' })
  end
}
```

This allows you to search and navigate to symbols in your code using Telescope's fuzzy finding capabilities.

## Practical Examples

### Navigating a Large Python File

When working with a large Python file:

1. Use `]]` and `[[` to jump between functions
2. Use `:TSJump class` to jump to a class definition
3. Use Treesitter folding to collapse functions you're not working on
4. Use Treesitter context to see which function or class you're currently in

### Exploring a JavaScript Codebase

When exploring an unfamiliar JavaScript codebase:

1. Use Symbols Outline to get an overview of the file structure
2. Use Treesitter folding to focus on one section at a time
3. Use Telescope with Treesitter to find specific functions or classes
4. Use Treesitter context to maintain awareness of your location in nested callbacks

## Troubleshooting Navigation Issues

### Navigation Commands Not Working

If navigation commands aren't working:

1. Check if the Treesitter parser is installed for your language
2. Verify that the required plugins are installed and configured
3. Check for errors with `:checkhealth nvim-treesitter`

### Folding Issues

If folding doesn't work correctly:

1. Make sure you've set `foldmethod` to `expr` and `foldexpr` to `nvim_treesitter#foldexpr()`
2. Check if the Treesitter parser is installed for your language
3. Try updating the parser with `:TSUpdate`

## Next Steps

Now that you've learned how to navigate your code with Treesitter, the next guide will show you how to use Treesitter text objects for more efficient editing.

Continue to [Treesitter Text Objects](05-treesitter-text-objects.md).
