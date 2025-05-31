
# Code Block Keymaps for Markdown

This guide explains keyboard shortcuts (keymaps) that help you work with code blocks in Markdown files. These shortcuts make it easy to insert, split, and manage code blocks without typing everything manually.

## What Are Code Blocks?

Code blocks in Markdown look like this:

```python
print("Hello, World!")
```

They start and end with three backticks (```) and can specify a programming language for syntax highlighting.

## Overview of Available Shortcuts

| Shortcut | What It Does | When To Use |
|----------|--------------|-------------|
| `<leader>icb` | Insert code block with Bash content from clipboard | When you've copied Bash commands and want to paste them in a code block |
| `<leader>icp` | Insert code block with Python content from clipboard | When you've copied Python code and want to paste it in a code block |
| `<leader>ieb` | Insert empty Bash code block | When you want to type Bash commands from scratch |
| `<leader>iep` | Insert empty Python code block | When you want to type Python code from scratch |
| `<leader>scb` | Split current code block and add Bash block | When you want to separate text and add a new Bash code block |
| `<leader>scp` | Split current code block and add Python block | When you want to separate text and add a new Python code block |
| `<leader>cnf` | Create a new file | When you need to create a new file on your system |
| `<leader>icf` | Insert content to file | When you want to add content to an existing file |
| `<leader>ycb` | Copy code block content | When you want to copy just the code (without the backticks) |

**Note**: `<leader>` is typically the space bar in most Neovim configurations, but it could be different in your setup.

## Detailed Explanations

### 1. Insert Code Block with Content (`<leader>icb` and `<leader>icp`)

**What it does**: Takes content you've copied to your clipboard and wraps it in a code block.

**How to use**:
1. Copy some code to your clipboard (Ctrl+C or Cmd+C)
2. In Neovim, position your cursor where you want the code block
3. Press `<leader>icb` for Bash or `<leader>icp` for Python
4. The code appears wrapped in a proper code block

**Example**:
If you copy `echo "Hello World"` and press `<leader>icb`, you get:
```bash
echo "Hello World"
```

````lua path=lua/code_block_keymaps.lua mode=EDIT
-- Helper function to insert code block with content from register
local function insert_code_block(language)
  -- Get content from the default register
  local content = vim.fn.getreg '+'
  -- Split content by newlines
  local content_lines = vim.split(content, '\n')
  -- Create the code block with the content
  local lines = { '```' .. language }
  -- Add each line of content separately
  for _, line in ipairs(content_lines) do
    table.insert(lines, line)
  end
  --delete the emptyline before adding the ```
  table.remove(lines, #lines)
  table.insert(lines, '```')
  table.insert(lines, '')
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end
````
The four backticks (````) are part of a special syntax used in your Markdown documentation to display code blocks that themselves contain Markdown code blocks.

Here's what's happening:

1. In regular Markdown, three backticks (```) are used to create a code block
2. But when you need to show a code block that itself contains three backticks (like when documenting Markdown syntax), you need to use four backticks (````) to "escape" the inner code block

The `path=lua/code_block_keymaps.lua mode=EDIT` part is a custom annotation that appears to be used by your documentation system to:

1. Indicate which file the code belongs to (`lua/code_block_keymaps.lua`)
2. Specify that this is an editable code snippet (`mode="EDIT"`)

This annotation helps with:
- Providing context about where the code lives in your project
- Possibly enabling interactive features in your documentation system (like "click to edit this file")




````lua path=lua/code_block_keymaps.lua mode=EDIT
vim.keymap.set('n', '<leader>icb', function()
  insert_code_block 'bash'
end, { desc = '[I]nsert [C]ode [B]ash' })

vim.keymap.set('n', '<leader>icp', function()
  insert_code_block 'python'
end, { desc = '[I]nsert [C]ode [P]ython' })
````

### 2. Insert Empty Code Block (`<leader>ieb` and `<leader>iep`)

**What it does**: Creates an empty code block where you can type code from scratch.

**How to use**:
1. Position your cursor where you want the code block
2. Press `<leader>ieb` for Bash or `<leader>iep` for Python
3. An empty code block appears with your cursor positioned inside it

**Example**:
Press `<leader>iep` and you get:
```python

```
Your cursor will be positioned on the empty line between the backticks, ready for you to type.

```lua path=lua/code_block_keymaps.lua mode=EDIT
--Helper function to insert empty code block
local function insert_empty_code_block(language)
  -- Create the empty code block
  local lines = { '```' .. language, '', '```' }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end
````

````lua path=lua/code_block_keymaps.lua mode=EDIT
vim.keymap.set('n', '<leader>ieb', function()
  insert_empty_code_block 'bash'
end, { desc = '[I]nsert [E]mpty [B]ash' })

vim.keymap.set('n', '<leader>iep', function()
  insert_empty_code_block 'python'
end, { desc = '[I]nsert [E]mpty [P]ython' })
````

### 3. Split Code Block (`<leader>scb` and `<leader>scp`)

**What it does**: Ends the current code block and immediately starts a new one. This is useful when you want to separate explanatory text from code.

**How to use**:
1. Position your cursor where you want to split (usually at the end of a code block)
2. Press `<leader>scb` for Bash or `<leader>scp` for Python
3. The current code block ends, and a new one begins

**Example**:
If you're inside a code block and press `<leader>scp`, you get:
```
```

```python
```
This allows you to add text between code blocks or switch programming languages.

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Helper function to split a code block
local function split_code_block(language)
  -- Create the empty code block
  local lines = { '```', '', '```' .. language }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end
````
````lua path=lua/code_block_keymaps.lua mode=EDIT
vim.keymap.set('n', '<leader>scb', function()
  split_code_block 'bash'
end, { desc = '[S]plit [C]ode [B]ash' })

vim.keymap.set('n', '<leader>scp', function()
  split_code_block 'python'
end, { desc = '[S]plit [C]ode [P]ython' })
````

### 4. Create New File (`<leader>cnf`)

**What it does**: Creates a new file on your computer and remembers its name for later use.

**How to use**:
1. Press `<leader>cnf`
2. Type the name of the file you want to create (you can use Tab for auto-completion)
3. Press Enter
4. The file is created and its name is saved for the next command

**Example**:
Press `<leader>cnf`, type `my_script.py`, and press Enter. A new file called `my_script.py` is created.

**Why this is useful**: Often when writing documentation, you want to create files and then add content to them. This command sets up the file creation process.

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Create a new file with file completion
vim.keymap.set('n', '<leader>cnf', function()
  vim.cmd 'command! -nargs=1 -complete=file CreateNewFile !touch <args> | let @f="<args>"'
  vim.cmd 'CreateNewFile '
end, { desc = '[C]reate [N]ew [F]ile' })
````

### 5. Insert Content to File (`<leader>icf`)

**What it does**: Takes the filename you saved with `<leader>cnf` and adds content to that file.

**How to use**:
1. First, create a file with `<leader>cnf` (this saves the filename)
2. Press `<leader>icf`
3. Type the filename where you want to add content (or use the saved one)
4. Press Enter
5. The content gets added to the file

**Example workflow**:
1. Press `<leader>cnf`, type `setup.sh`, press Enter (creates file and saves name)
2. Press `<leader>icf`, press Enter (adds content to setup.sh)

**Why this is useful**: When documenting installation processes, you often want to create script files and add commands to them step by step.

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Insert content to file
-- Appends content from register f to a specified file
vim.keymap.set('n', '<leader>icf', function()
  local content = vim.fn.getreg 'f'
  vim.cmd('command! -nargs=1 -complete=file AddContentToFile !echo "' .. content .. '" >> <args>')
  vim.cmd 'AddContentToFile '
end, { desc = '[I]nsert [C]ontent to [F]ile' })
````

### 6. Copy Code Block Content (`<leader>ycb`)

**What it does**: Copies just the code inside a code block (without the backticks) to your clipboard.

**How to use**:
1. Position your cursor anywhere inside a code block
2. Press `<leader>ycb`
3. The code content is copied to your clipboard (without the ``` markers)
4. You can now paste it elsewhere with Ctrl+V or Cmd+V

**Example**:
If you have this code block:
```python
print("Hello World")
x = 5
```

And you press `<leader>ycb`, only this gets copied:
```
print("Hello World")
x = 5
```

**Why this is useful**: Sometimes you want to copy code from documentation to run it in a terminal or editor, but you don't want the markdown formatting.

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Yank code block
-- Copies the content of a markdown code block (without the fences)
vim.keymap.set('n', '<leader>ycb', function()
  vim.cmd [[normal! ?```\+?e\<CR>j0v/```/-1\<CR>y]]
end, { desc = '[Y]ank [C]ode [B]lock' })
````

**How this works step by step**:
1. Search backward for the opening code fence (```)
2. Move to the line after it (where the actual code starts)
3. Start visual mode at the beginning of that line
4. Search forward for the closing code fence
5. Move to the line before it (where the actual code ends)
6. Copy (yank) the selected text

This executes a series of Vim normal mode commands to select and yank (copy) the content inside a Markdown code block:

1. `?```\+?` - Search backward for one or more backticks (matches both ``` and ````)
2. `e` - Move to the end of the found pattern
3. `\<CR>` - Press Enter to complete the search
4. `j` - Move down one line (to the first line of actual code)
5. `0` - Move to the beginning of that line
6. `v` - Enter visual mode (start selection)
7. `/```/` - Search forward for the closing code fence
8. `-1` - Move up one line (to the last line of actual code)
9. `\<CR>` - Press Enter to complete the search
10. `y` - Yank (copy) the selected text

The command effectively:
1. Finds the start of a code block
2. Positions the cursor at the beginning of the first line of code
3. Selects from there to the last line of code
4. Copies just the code content, excluding the code fence markers


## Quick Reference

Here's a quick summary of all the shortcuts:

- **`<leader>icb`** - Insert Bash code block with clipboard content
- **`<leader>icp`** - Insert Python code block with clipboard content
- **`<leader>ieb`** - Insert empty Bash code block
- **`<leader>iep`** - Insert empty Python code block
- **`<leader>scb`** - Split and add Bash code block
- **`<leader>scp`** - Split and add Python code block
- **`<leader>cnf`** - Create new file
- **`<leader>icf`** - Insert content to file
- **`<leader>ycb`** - Copy code block content

Remember: `<leader>` is usually the space bar, but check your Neovim configuration to be sure!

