# Advanced Treesitter Modules

Treesitter's functionality can be extended with various modules that provide additional features. This guide will explore some of the most useful advanced Treesitter modules and how to use them effectively.

## Incremental Selection

Incremental selection allows you to progressively select larger syntactic units of your code.

### Setting Up Incremental Selection

```lua
require('nvim-treesitter.configs').setup({
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<S-CR>",
      node_decremental = "<BS>",
    },
  },
})
```

### Using Incremental Selection

With this configuration:

1. Press `<CR>` (Enter) to start selection at the current node
2. Press `<CR>` again to expand the selection to the next containing node
3. Press `<S-CR>` (Shift+Enter) to expand selection to the next scope
4. Press `<BS>` (Backspace) to shrink the selection

This is incredibly useful for quickly selecting syntactic elements without having to use text objects repeatedly.

## Treesitter Context

The Treesitter Context module shows you the context of your current position in the code, even when it's scrolled out of view.

### Setting Up Treesitter Context

First, install the plugin:

```lua
-- Using Lazy.nvim
return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesitter-context').setup({
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,
      zindex = 20,
    })
  end,
}
```

### Using Treesitter Context

Once configured, Treesitter Context will automatically show the context of your current position at the top of the window. This is especially useful when:

- Working with deeply nested functions or blocks
- Navigating large files
- Editing code with many levels of indentation

You can also use these commands:

- `:TSContextToggle` - Toggle context display
- `:TSContextEnable` - Enable context display
- `:TSContextDisable` - Disable context display

## Treesitter Playground

The Playground module allows you to inspect the syntax tree that Treesitter builds for your code, which is useful for debugging and creating custom queries.

### Setting Up Treesitter Playground

```lua
-- Using Lazy.nvim
return {
  'nvim-treesitter/playground',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-treesitter.configs').setup({
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = 'o',
          toggle_hl_groups = 'i',
          toggle_injected_languages = 't',
          toggle_anonymous_nodes = 'a',
          toggle_language_display = 'I',
          focus_language = 'f',
          unfocus_language = 'F',
          update = 'R',
          goto_node = '<cr>',
          show_help = '?',
        },
      }
    })
  end,
}
```

### Using Treesitter Playground

To open the playground:

```vim
:TSPlaygroundToggle
```

This will open a split showing the syntax tree of your current buffer. You can:

- Navigate the tree with normal Vim movements
- Press `<CR>` on a node to highlight it in the source code
- Press `o` to toggle the query editor
- Press `i` to toggle highlight groups
- Press `?` for help

The playground is invaluable for:
- Understanding how Treesitter parses your code
- Developing custom queries for highlighting or text objects
- Debugging issues with Treesitter

## Treesitter Refactor

The Refactor module provides smart renaming, highlighting, and navigation.

### Setting Up Treesitter Refactor

```lua
require('nvim-treesitter.configs').setup({
  refactor = {
    highlight_definitions = {
      enable = true,
      clear_on_cursor_move = true,
    },
    highlight_current_scope = { enable = true },
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr",
      },
    },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gnd",
        list_definitions = "gnD",
        list_definitions_toc = "gO",
        goto_next_usage = "<a-*>",
        goto_previous_usage = "<a-#>",
      },
    },
  },
})
```

### Using Treesitter Refactor

With this configuration:

- `grr` - Smart rename the symbol under the cursor
- `gnd` - Go to the definition of the symbol under the cursor
- `gnD` - List all definitions in the current file
- `gO` - Show table of contents (list of definitions)
- `<a-*>` - Go to next usage of the symbol under the cursor
- `<a-#>` - Go to previous usage of the symbol under the cursor

Note: Some of these features overlap with LSP functionality. If you're using LSP, you might prefer to use LSP for these operations.

## Treesitter Queries

Queries are how Treesitter extracts information from the syntax tree. Understanding and writing queries allows you to customize Treesitter's behavior.

### Basic Query Syntax

Queries are written in S-expressions and match patterns in the syntax tree:

```scheme
; Match function definitions
(function_definition
  name: (identifier) @function)

; Match class definitions
(class_definition
  name: (identifier) @class)
```

### Creating Custom Queries

You can create custom queries for highlighting, text objects, or other purposes:

1. Create a directory for your queries:
   ```bash
   mkdir -p ~/.config/nvim/after/queries/
   ```

2. Create a file for your language, e.g., `~/.config/nvim/after/queries/python/highlights.scm`:
   ```scheme
   ; Custom highlighting for Python
   (decorator "@" @decorator)
   ((identifier) @constant
    (#match? @constant "^[A-Z][A-Z_0-9]*$"))
   ```

3. Reload Treesitter with `:TSReload`

### Using the Query Editor

The Playground's query editor allows you to test queries interactively:

1. Open the playground with `:TSPlaygroundToggle`
2. Press `o` to open the query editor
3. Write your query
4. Press `R` to run the query and see the results

## Treesitter and LSP Integration

Treesitter and LSP are complementary technologies that work well together.

### Combining Treesitter and LSP

```lua
-- Example of using both Treesitter and LSP
use {
  'neovim/nvim-lspconfig',
  requires = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    -- LSP setup
    local lspconfig = require('lspconfig')
    lspconfig.pyright.setup{}
    
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
      highlight = { enable = true },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          },
        },
        lsp_interop = {
          enable = true,
          border = 'none',
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
          },
        },
      },
    })
    
    -- Keymaps that use both
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition (LSP)' })
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename symbol (LSP)' })
    vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { desc = 'Code action (LSP)' })
  end
}
```

This configuration uses:
- LSP for definitions, references, and semantic operations
- Treesitter for syntax highlighting and text objects
- Treesitter's LSP interop for peeking at definitions

## Autopairs with Treesitter

You can use Treesitter to make autopairs smarter with the `nvim-autopairs` plugin:

```lua
use {
  'windwp/nvim-autopairs',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-autopairs').setup({
      check_ts = true,
      ts_config = {
        lua = {'string'},
        javascript = {'template_string'},
        java = false,
      }
    })
  end
}
```

With `check_ts = true`, autopairs will use Treesitter to avoid adding pairs in certain contexts, like inside strings.

## Rainbow Parentheses with Treesitter

The `nvim-ts-rainbow` plugin uses Treesitter to provide rainbow parentheses:

```lua
use {
  'p00f/nvim-ts-rainbow',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-treesitter.configs').setup({
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 1000,
      }
    })
  end
}
```

This will color matching parentheses, brackets, and braces in different colors, making it easier to see which ones match.

## Next Steps

Now that you've explored advanced Treesitter modules, the final guide will cover troubleshooting and optimization to ensure your Treesitter setup runs smoothly.

Continue to [Troubleshooting and Optimization](07-troubleshooting-and-optimization.md).
