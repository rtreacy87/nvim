# Treesitter Text Objects

Text objects are one of Vim's most powerful features, allowing you to operate on meaningful chunks of text. Treesitter takes text objects to the next level by making them aware of code structure. This guide will show you how to use and customize Treesitter text objects.

## Understanding Text Objects

In Vim/Neovim, text objects are used with operators to perform actions on specific parts of text:

- `daw` - Delete a word
- `ci"` - Change inside quotes
- `ya{` - Yank (copy) around curly braces

Treesitter extends this concept to code structures like functions, classes, and parameters.

## Installing Treesitter Textobjects

To use Treesitter text objects, you need the `nvim-treesitter-textobjects` plugin:

```lua
-- Using Lazy.nvim
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
}

-- Or with a direct configuration
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-treesitter.configs').setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["a/"] = "@comment.outer",
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = true,
        },
      },
    })
  end,
}
```

## Basic Text Objects

Once configured, you can use these text objects with any operator:

| Keymap | Text Object | Example Usage |
|--------|-------------|---------------|
| `af` | Around function | `daf` - Delete a function |
| `if` | Inside function | `cif` - Change function body |
| `ac` | Around class | `yac` - Copy a class |
| `ic` | Inside class | `vic` - Select class body |
| `aa` | Around parameter | `daa` - Delete a parameter |
| `ia` | Inside parameter | `cia` - Change parameter |
| `ab` | Around block | `dab` - Delete a block |
| `ib` | Inside block | `cib` - Change block contents |
| `al` | Around loop | `dal` - Delete a loop |
| `il` | Inside loop | `cil` - Change loop body |
| `ai` | Around conditional | `dai` - Delete an if statement |
| `ii` | Inside conditional | `cii` - Change if statement body |
| `a/` | Around comment | `da/` - Delete a comment |

## Advanced Usage

### Swap Text Objects

You can swap elements like parameters or arguments:

```lua
textobjects = {
  select = { ... },
  swap = {
    enable = true,
    swap_next = {
      ["<leader>a"] = "@parameter.inner",
      ["<leader>f"] = "@function.outer",
      ["<leader>e"] = "@element",
    },
    swap_previous = {
      ["<leader>A"] = "@parameter.inner",
      ["<leader>F"] = "@function.outer",
      ["<leader>E"] = "@element",
    },
  },
}
```

With this configuration:
- `<leader>a` swaps the current parameter with the next one
- `<leader>A` swaps the current parameter with the previous one
- `<leader>f` swaps the current function with the next one
- `<leader>F` swaps the current function with the previous one

### Move Text Objects

You can move to the start or end of text objects:

```lua
textobjects = {
  select = { ... },
  swap = { ... },
  move = {
    enable = true,
    set_jumps = true, -- whether to set jumps in the jumplist
    goto_next_start = {
      ["]f"] = "@function.outer",
      ["]c"] = "@class.outer",
      ["]p"] = "@parameter.inner",
      ["]b"] = "@block.outer",
      ["]l"] = "@loop.outer",
      ["]i"] = "@conditional.outer",
    },
    goto_next_end = {
      ["]F"] = "@function.outer",
      ["]C"] = "@class.outer",
      ["]P"] = "@parameter.inner",
      ["]B"] = "@block.outer",
      ["]L"] = "@loop.outer",
      ["]I"] = "@conditional.outer",
    },
    goto_previous_start = {
      ["[f"] = "@function.outer",
      ["[c"] = "@class.outer",
      ["[p"] = "@parameter.inner",
      ["[b"] = "@block.outer",
      ["[l"] = "@loop.outer",
      ["[i"] = "@conditional.outer",
    },
    goto_previous_end = {
      ["[F"] = "@function.outer",
      ["[C"] = "@class.outer",
      ["[P"] = "@parameter.inner",
      ["[B"] = "@block.outer",
      ["[L"] = "@loop.outer",
      ["[I"] = "@conditional.outer",
    },
  },
}
```

This allows you to navigate between text objects:
- `]f` jumps to the start of the next function
- `[f` jumps to the start of the previous function
- `]F` jumps to the end of the next function
- `[F` jumps to the end of the previous function

### LSP Integration

You can integrate Treesitter text objects with LSP for even more powerful operations:

```lua
textobjects = {
  select = { ... },
  lsp_interop = {
    enable = true,
    border = 'none',
    floating_preview_opts = {},
    peek_definition_code = {
      ["<leader>df"] = "@function.outer",
      ["<leader>dF"] = "@class.outer",
    },
  },
}
```

With this configuration:
- `<leader>df` shows a floating window with the definition of the function under the cursor
- `<leader>dF` shows a floating window with the definition of the class under the cursor

## Creating Custom Text Objects

You can create custom text objects by defining them in a query file. First, create a directory for your custom queries:

```bash
mkdir -p ~/.config/nvim/after/queries/
```

Then create a file for your language, e.g., `~/.config/nvim/after/queries/python/textobjects.scm`:

```scheme
; Custom text objects for Python
(function_definition
  body: (block . "{" . (_) @_start @_end _? @_end . "}"
  (#make-range! "block.inner" @_start @_end)))

(dictionary . "{" . (_) @_start @_end _? @_end . "}"
  (#make-range! "dictionary.inner" @_start @_end))
(dictionary "{" @_start . (_)? . "}" @_end
  (#make-range! "dictionary.outer" @_start @_end))
```

Then add these to your Treesitter configuration:

```lua
textobjects = {
  select = {
    enable = true,
    keymaps = {
      -- Your existing keymaps
      ["id"] = "@dictionary.inner", -- Inside dictionary
      ["ad"] = "@dictionary.outer", -- Around dictionary
      ["ib"] = "@block.inner",      -- Inside block
    },
  },
}
```

## Practical Examples

### Editing a Function

To edit a function:

1. Place your cursor anywhere inside the function
2. Type `cif` (Change Inside Function)
3. The function body will be deleted and you'll be in insert mode
4. Type the new function body
5. Press `<Esc>` to exit insert mode

### Reordering Parameters

To swap parameters in a function call:

1. Place your cursor on a parameter
2. Type `<leader>a` to swap it with the next parameter
3. Type `<leader>A` to swap it with the previous parameter

### Copying a Class

To copy an entire class:

1. Place your cursor anywhere inside the class
2. Type `yac` (Yank Around Class)
3. The entire class will be copied to the register
4. Navigate to where you want to paste it
5. Type `p` to paste

## Language-Specific Text Objects

Different languages have different structures, and Treesitter text objects adapt accordingly:

### Python

- `af`/`if` - Function with decorators
- `ac`/`ic` - Class with decorators
- `aa`/`ia` - Parameter/argument
- `ab`/`ib` - Block (indented block)

### JavaScript/TypeScript

- `af`/`if` - Function (including arrow functions)
- `ac`/`ic` - Class
- `aa`/`ia` - Parameter/argument
- `ab`/`ib` - Block (curly braces)
- `ao`/`io` - Object literal

### HTML/JSX/TSX

- `ae`/`ie` - Element
- `aa`/`ia` - Attribute
- `ac`/`ic` - Comment

## Troubleshooting

### Text Objects Not Working

If text objects aren't working:

1. Check if the Treesitter parser is installed for your language
2. Verify that `nvim-treesitter-textobjects` is installed and configured
3. Check for errors with `:checkhealth nvim-treesitter`

### Unexpected Selection Behavior

If text objects aren't selecting what you expect:

1. Use `:TSPlaygroundToggle` to see the syntax tree (requires `nvim-treesitter/playground`)
2. Check if the node types in your configuration match the actual node types
3. Try updating the parser with `:TSUpdate`

## Next Steps

Now that you've mastered Treesitter text objects, the next guide will show you how to use advanced Treesitter modules for even more functionality.

Continue to [Advanced Treesitter Modules](06-advanced-treesitter-modules.md).
