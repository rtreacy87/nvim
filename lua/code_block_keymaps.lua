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
