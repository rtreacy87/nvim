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

vim.keymap.set('n', '<leader>icb', function()
  insert_code_block 'bash'
end, { desc = '[I]nsert [C]ode [B]ash' })

vim.keymap.set('n', '<leader>icp', function()
  insert_code_block 'python'
end, { desc = '[I]nsert [C]ode [P]ython' })

--Helper function to insert empty code block
local function insert_empty_code_block(language)
  -- Create the empty code block
  local lines = { '```' .. language, '', '```' }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end

vim.keymap.set('n', '<leader>ieb', function()
  insert_empty_code_block 'bash'
end, { desc = '[I]nsert [E]mpty [B]ash' })

vim.keymap.set('n', '<leader>iep', function()
  insert_empty_code_block 'python'
end, { desc = '[I]nsert [E]mpty [P]ython' })

--Helper function to split a code block
local function split_code_block(language)
  -- Create the empty code block
  local lines = { '```', '', '```' .. language }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end

vim.keymap.set('n', '<leader>scb', function()
  split_code_block 'bash'
end, { desc = '[S]plit [C]ode [B]ash' })

vim.keymap.set('n', '<leader>scp', function()
  split_code_block 'python'
end, { desc = '[S]plit [C]ode [P]ython' })

-- Create a new file and save filename to the 'f' register
vim.api.nvim_create_user_command('CreateNewFile', function(opts)
  local filename = opts.args
  -- Save filename to the 'f' register
  vim.fn.setreg('f', filename)
  -- Create and open the new file
  vim.cmd('edit ' .. filename)
  -- Optional: You can also save to buffer for immediate writing if needed
  vim.cmd 'write'
end, {
  nargs = 1,
  complete = 'file',
  desc = 'Create a new file and save filename to f register',
})

--Create a new file with file completion
vim.keymap.set('n', '<leader>cnf', ':CreateNewFile ', { desc = '[C]reate [N]ew [F]ile' })

-- Define the command once (put this in your config, not in the keymap)
vim.api.nvim_create_user_command('AddContentToFile', function(opts)
  local content = vim.fn.getreg '+' -- Get content from + register (clipboard)
  local filename = vim.fn.getreg 'f' -- Get filename from f register
  if filename == '' then
    vim.notify('No filename found in f register', vim.log.levels.ERROR)
    return
  end
  -- Use Vim's writefile function instead of shell command
  local lines = vim.split(content, '\n')
  vim.fn.writefile(lines, filename, 'a') -- 'a' flag appends to file
  vim.fn.writefile({ '' }, filename, 'a') -- Add a newlines
  vim.notify('Content appended to ' .. filename)
end, {
  nargs = 0,
  desc = 'Add content from + register to file path stored in f register',
})

-- Then your keymap becomes:
vim.keymap.set('n', '<leader>icf', ':AddContentToFile<CR>', { desc = '[I]nsert [C]ontent to [F]ile' })

vim.keymap.set('n', '<leader>ycb', function()
  -- Find the start of the code block (backward search for ```)
  local start_line = vim.fn.search('```\\+', 'bn')
  if start_line == 0 then
    return
  end
  -- Find the end of the code block (forward search for ```)
  local end_line = vim.fn.search('```', 'n')
  if end_line == 0 then
    return
  end
  -- Yank the content between the markers (excluding the markers)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  if #lines > 0 then
    -- Remove the first line if it contains the opening fence with language
    table.remove(lines, 1)
    -- Join the lines and set to register
    local content = table.concat(lines, '\n')
    vim.fn.setreg('+', content)
    vim.notify 'Code block content copied to clipboard'
  end
end, { desc = '[Y]ank [C]ode [B]lock' })
