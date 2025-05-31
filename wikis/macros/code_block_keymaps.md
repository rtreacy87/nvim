


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

````lua path=lua/code_block_keymaps.lua mode=EDIT
vim.keymap.set('n', '<leader>icb', function()
  insert_code_block 'bash'
end, { desc = '[I]nsert [C]ode [B]ash' })

vim.keymap.set('n', '<leader>icp', function()
  insert_code_block 'python'
end, { desc = '[I]nsert [C]ode [P]ython' })
````


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

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Create a new file with file completion
vim.keymap.set('n', '<leader>cnf', function()
  vim.cmd 'command! -nargs=1 -complete=file CreateNewFile !touch <args> | let @f="<args>"'
  vim.cmd 'CreateNewFile '
end, { desc = '[C]reate [N]ew [F]ile' })
````

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Insert content to file
-- Appends content from register f to a specified file
vim.keymap.set('n', '<leader>icf', function()
  local content = vim.fn.getreg 'f'
  vim.cmd('command! -nargs=1 -complete=file AddContentToFile !echo "' .. content .. '" >> <args>')
  vim.cmd 'AddContentToFile '
end, { desc = '[I]nsert [C]ontent to [F]ile' })
````

````lua path=lua/code_block_keymaps.lua mode=EDIT
--Yank code block
-- Copies the content of a markdown code block (without the fences)
vim.keymap.set('n', '<leader>ycb', function()
  vim.cmd [[normal! ?```?e+1\<CR>j0v/```/-1\<CR>y]]
end, { desc = '[Y]ank [C]ode [B]lock' })
````

This will:
1. Search backward for the opening code fence (```)
2. Move to the line after it
3. Start visual mode at the beginning of that line
4. Search forward for the closing code fence
5. Move to the line before it
6. Yank the selected text

