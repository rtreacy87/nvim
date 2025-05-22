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

## Understanding Treesitter Text Objects vs. Traditional Vim Motions

### Traditional Vim Motions and Text Objects

In traditional Vim, you navigate and manipulate text using:

1. **Character-based motions**: `h`, `j`, `k`, `l`, `w`, `b`, etc.
2. **Line-based motions**: `0`, `$`, `^`, etc.
3. **Search-based motions**: `/pattern`, `?pattern`, `f`, `t`, etc.
4. **Built-in text objects**: `iw` (inner word), `i"` (inside quotes), `ip` (inner paragraph), etc.

These work well for general text editing but have limitations when working with code:

- They don't understand code structure
- They operate on syntax patterns rather than semantic units
- They require multiple commands to select complex code structures
- They can break when code formatting changes

### How Treesitter Text Objects Improve Code Editing

Treesitter text objects are fundamentally different because they operate on the **syntax tree** of your code rather than just text patterns. This provides several key advantages:

#### 1. Structure-Aware Selection

```python
def calculate_total(items, tax_rate=0.05):
    subtotal = sum(item.price for item in items)
    tax = subtotal * tax_rate
    return subtotal + tax
```

With traditional Vim:
- To select this function, you might use `V` to select the current line, then `}` to extend to the end of the paragraph
- This approach is fragile and depends on consistent formatting

With Treesitter:
- Place cursor anywhere in the function and use `vaf` (visual around function)
- Treesitter understands the function's structure regardless of formatting

#### 2. Semantic Navigation

Traditional Vim requires you to:
- Use `/def` to search for function definitions
- Use `]]` (if properly configured) to jump to section boundaries
- Manually count or search to find the "third function" or "next class"

Treesitter allows you to:
- Use `]m` to jump to the next function start
- Use `]]` to jump to the next class start
- Navigate based on code structure, not text patterns

#### 3. Nested Structure Handling

Consider this nested code:

```javascript
function processData(data) {
    if (data.isValid) {
        data.items.forEach(item => {
            if (item.quantity > 0) {
                processItem(item);
            }
        });
    }
}
```

With traditional Vim:
- Selecting the outer `if` block is challenging
- You might need to count braces or use multiple commands

With Treesitter:
- Place cursor in the `if` statement and use `vai` (visual around if-statement)
- Treesitter understands the nesting and selects precisely what you want

#### 4. Language-Specific Understanding

Treesitter understands different languages' syntax:

**Python**:
```python
class User:
    def __init__(self, name):
        self.name = name
        
    def greet(self):
        return f"Hello, {self.name}!"
```

**JavaScript**:
```javascript
class User {
    constructor(name) {
        this.name = name;
    }
    
    greet() {
        return `Hello, ${this.name}!`;
    }
}
```

Despite different syntax, `vac` (visual around class) works correctly in both languages because Treesitter understands each language's structure.

### Detailed Explanation of Key Text Objects

#### Function Objects: `af` and `if`

```lua
["af"] = "@function.outer",  -- Around function (includes function signature and body)
["if"] = "@function.inner",  -- Inside function (only the function body)
```

**Example usage**:
- `daf` - Delete an entire function including its signature
- `cif` - Change the implementation of a function while keeping its signature
- `yaf` - Yank (copy) an entire function for pasting elsewhere

**Why it's better**: Traditional Vim would require you to visually select the function or use multiple commands like `V}d` to delete a function.

#### Class Objects: `ac` and `ic`

```lua
["ac"] = "@class.outer",  -- Around class (includes the entire class definition)
["ic"] = "@class.inner",  -- Inside class (only the class body, not the declaration)
```

**Example usage**:
- `dac` - Delete an entire class
- `cic` - Change the implementation of a class while keeping its declaration
- `yac` - Yank an entire class definition

**Why it's better**: Traditional Vim has no built-in understanding of classes, so you'd need to use multiple commands or visual selection.

#### Parameter Objects: `aa` and `ia`

```lua
["aa"] = "@parameter.outer",  -- Around parameter (includes commas if present)
["ia"] = "@parameter.inner",  -- Inside parameter (just the parameter itself)
```

**Example usage**:
- `daa` - Delete a parameter and its separator (comma)
- `cia` - Change a parameter while keeping its position in the parameter list
- `yia` - Yank just the parameter without commas

**Why it's better**: Traditional Vim would require precise cursor positioning and multiple commands to manipulate function parameters.

#### Block Objects: `ab` and `ib`

```lua
["ab"] = "@block.outer",  -- Around block (includes braces/indentation)
["ib"] = "@block.inner",  -- Inside block (only the block contents)
```

**Example usage**:
- `dab` - Delete an entire code block including braces
- `cib` - Change the contents of a block while keeping the structure
- `>ib` - Indent the contents of a block

**Why it's better**: While Vim has `a{` and `i{`, Treesitter's block objects work with any block structure in any language, even without braces (like Python).

#### Conditional Objects: `ai` and `ii`

```lua
["ai"] = "@conditional.outer",  -- Around conditional (if/else/switch statement)
["ii"] = "@conditional.inner",  -- Inside conditional (body only)
```

**Example usage**:
- `dai` - Delete an entire if statement
- `cii` - Change the body of an if statement
- `yai` - Yank an entire conditional block

**Why it's better**: Traditional Vim has no concept of conditional statements as text objects.

#### Loop Objects: `al` and `il`

```lua
["al"] = "@loop.outer",  -- Around loop (for/while/do-while)
["il"] = "@loop.inner",  -- Inside loop (loop body only)
```

**Example usage**:
- `dal` - Delete an entire loop
- `cil` - Change the body of a loop
- `yal` - Yank an entire loop

**Why it's better**: Traditional Vim has no concept of loops as text objects.

### Advanced Movement with Treesitter

The movement capabilities are equally powerful:

```lua
goto_next_start = {
  ["]m"] = "@function.outer",  -- Jump to next function start
  ["]]"] = "@class.outer",     -- Jump to next class start
},
```

**Example workflow**:
1. Use `]]` to jump to the next class
2. Use `]m` to jump to the first function in that class
3. Use `vaf` to select the function
4. Use `d` to delete it

This allows for rapid, precise navigation and editing that would require multiple steps with traditional Vim motions.

### Practical Examples: Treesitter vs. Traditional Vim

#### Example 1: Refactoring a Function

**Task**: Extract the body of a function to create a new helper function

**Traditional Vim**:
1. Navigate to the function with `/def`
2. Enter visual mode with `V`
3. Move to the end of the function with `}`
4. Yank with `y`
5. Navigate to where you want the new function
6. Paste with `p`
7. Edit manually to create the new function signature

**With Treesitter**:
1. Navigate to the function with `[m` or `]m`
2. Select the function body with `vif`
3. Yank with `y`
4. Navigate to where you want the new function
5. Paste with `p`
6. Add the function signature

#### Example 2: Swapping Parameters

**Task**: Swap two parameters in a function call

**Traditional Vim**:
1. Manually identify parameter boundaries
2. Use visual mode to select first parameter
3. Cut with `d`
4. Navigate to second parameter
5. Use visual mode to select it
6. Use `p` to replace with first parameter
7. Navigate back to where first parameter was
8. Paste second parameter

**With Treesitter**:
1. Place cursor on first parameter
2. Use `<leader>a` to swap with next parameter (using the swap feature)

#### Example 3: Navigating a Large Codebase

**Task**: Find and edit the third method in the second class in a file

**Traditional Vim**:
1. Use `/class` to find the first class
2. Use `n` to find the second class
3. Use `/def` or `/function` to find methods
4. Press `n` repeatedly to get to the third method

**With Treesitter**:
1. Use `]]` to jump to the first class
2. Use `]]` again to jump to the second class
3. Use `]m` three times to reach the third method

The Treesitter approach is more precise, requires fewer keystrokes, and works reliably regardless of comments, string contents, or other text that might contain the search terms.

## Conclusion: Why Treesitter Text Objects Are Game-Changing

Treesitter text objects transform code editing by:

1. **Making editing structure-aware**: Operations work on logical code units, not just text
2. **Reducing keystrokes**: Complex selections require fewer commands
3. **Improving precision**: Selections are exact, regardless of formatting
4. **Working across languages**: The same keybindings work consistently in different programming languages
5. **Enabling advanced refactoring**: Makes complex code transformations simpler

While traditional Vim motions are still valuable for general text editing, Treesitter text objects provide a higher-level, more semantic way to interact with code that dramatically improves editing efficiency for programmers.

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

