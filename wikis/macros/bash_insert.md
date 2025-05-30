# Creating a Macro to Insert Bash Code Blocks

Here's how to create a macro that inserts a bash code block with content from your register:

## Basic Implementation

Add this mapping to your Neovim configuration:

````lua path=lua/keymaps.lua mode=EDIT
-- Insert bash code block with content from register
vim.keymap.set('n', '<leader>icb', function()
  -- Get content from the default register
  local content = vim.fn.getreg('"')
  -- Create the code block with the content
  local lines = {'```bash', content, '```', ''}
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = 'Insert bash code block' })
````

## How It Works

1. When you press `<leader>icb` in normal mode:
   - The function retrieves content from your default register (`"`)
   - Creates an array with opening bash code fence, the content, closing fence, and a blank line
   - Inserts this at your cursor position

## Usage

1. Copy text to your register (using `y`, `d`, or other commands)
2. Position your cursor where you want the code block
3. Press `<leader>ib`
4. A formatted bash code block appears with your copied content

## Customization Options

### Using a Specific Register

If you want to use a specific register instead of the default one:

````lua path=lua/keymaps.lua mode=EDIT
-- Insert bash code block with content from register 'a'
vim.keymap.set('n', '<leader>ib', function()
  local content = vim.fn.getreg('a')
  local lines = {'```bash', content, '```', ''}
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = 'Insert bash code block from register a' })
````

### Adding a Prompt for Register Selection

````lua path=lua/keymaps.lua mode=EDIT
-- Insert bash code block with content from selected register
vim.keymap.set('n', '<leader>ib', function()
  local reg = vim.fn.input('Register to use: ')
  if reg == '' then reg = '"' end
  local content = vim.fn.getreg(reg)
  local lines = {'```bash', content, '```', ''}
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = 'Insert bash code block from selected register' })
````

## Traditional Macro Approach

If you prefer using a traditional Vim macro:

1. Record the macro to register `b`:
   - Press `qb` to start recording
   - Type `i```bash<CR><Esc>"+p<Esc>o```<CR><Esc>`
   - Press `q` to stop recording

2. Map it to your preferred key combination:

````lua path=lua/keymaps.lua mode=EDIT
-- Map the macro in register b to <leader>ib
vim.keymap.set('n', '<leader>ib', '@b', { desc = 'Insert bash code block (macro)' })
````

This approach uses the clipboard register (`+`), but you can modify the macro to use any register.



