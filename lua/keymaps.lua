-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>nl', ':Neotree filesystem reveal left<CR>', { desc = 'Opens the filesystem menu to the left' })
vim.keymap.set('n', '<leader>nr', ':Neotree filesystem reveal right<CR>', { desc = 'Opens the filesystem menu to the right' })
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
--
--
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>ot', ':split | terminal<CR>', { desc = '[O]pen a [T]erminal window' })
vim.keymap.set('n', '<leader>oh', ':split<CR>', { desc = '[O]pen a [H]orizontal window' })
vim.keymap.set('n', '<leader>ov', ':vsplit<CR>', { desc = '[O]pen a [V]ertical window' })
vim.keymap.set('n', '<leader>cw', ':close<CR>', { desc = '[C]lose the current [W]indow' })

vim.keymap.set('n', '<leader>om', ':MarkdownPreview<CR>', { desc = '[O]pen [M]arkdown Preview' })
vim.keymap.set('n', '<leader>cm', ':MarkdownPreviewStop<CR>', { desc = '[C]lose [Markdown Preview' })

vim.keymap.set('n', '<leader>tm', ':TableModeToggle<CR>', { desc = '[T]able [M]ode toggle' })

-- Alternative mapping for block visual mode if Ctrl+v is intercepted by the terminal
vim.keymap.set('n', '<leader>vb', '<C-v>', { desc = 'Enter Block Visual mode' })

-- Send a chat message in normal mode
vim.keymap.set('n', '<leader>ac', ':Augment chat<CR>', { desc = 'Augment Chat' })
-- Send a chat message about selected text in visual mode
vim.keymap.set('v', '<leader>ac', ":'<,'>Augment chat<CR>", { desc = 'Augment Chat Selection' })

vim.keymap.set(
  'v',
  '<leader>ad',
  ":'<,'>Augment chat Create an ascii diagram of the highlighted code.<CR>",
  { desc = 'Create an ascii diagram of the highlighted code' }
)
-- Start a new chat conversation
vim.keymap.set('n', '<leader>an', ':Augment chat-new<CR>', { desc = 'Augment New Chat' })
-- Toggle the chat panel visibility
vim.keymap.set('n', '<leader>at', ':Augment chat-toggle<CR>', { desc = 'Augment Toggle Chat' })
-- Workspace management keymaps
vim.keymap.set('n', '<leader>ap', ':AugmentProject<Space>', { desc = 'Set Augment Project' })
vim.keymap.set('n', '<leader>aa', ':AugmentAddFolder<Space>', { desc = 'Add Augment Folder' })
vim.keymap.set('n', '<leader>ar', ':AugmentRemoveFolder<Space>', { desc = 'Remove Augment Folder' })

-- Insert bash code block with content from register
vim.keymap.set('n', '<leader>icb', function()
  -- Get content from the default register
  local content = vim.fn.getreg '"'
  -- Split content by newlines
  local content_lines = vim.split(content, '\n')

  -- Create the code block with the content
  local lines = { '```bash' }
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
end, { desc = '[I]nsert [C]ode [B]ash' })

vim.keymap.set('n', '<leader>icp', function()
  -- Get content from the default register
  local content = vim.fn.getreg '"'
  -- Split content by null bytes to get proper lines
  local content_lines = vim.split(content, '\n')
  -- Create the code block with the content
  local lines = { '```python' }
  -- Add each line of content separately
  for _, line in ipairs(content_lines) do
    table.insert(lines, line)
  end
  --delete the emptyline before adding the ```
  table.remove(lines, #lines)
  -- Add closing fence
  table.insert(lines, '```')
  table.insert(lines, '')
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = '[I]nsert [C]ode [P]ython' })

vim.keymap.set('n', '<leader>isb', function()
  -- Create the empty code block
  local lines = { '```', '', '', '', '```bash' }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = '[I]nsert [S]plit [B]ash' })

vim.keymap.set('n', '<leader>isp', function()
  -- Create the empty code block
  local lines = { '```', '', '', '', '```python' }
  -- Insert at current position
  vim.api.nvim_put(lines, 'l', true, true)
end, { desc = '[I]nsert [S]plit [P]ython' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
