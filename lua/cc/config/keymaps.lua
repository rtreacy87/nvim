local M = {}

function M.setup()
  local opts = { noremap = true, silent = true }

  -- Function Analysis - Comprehensive breakdown
  vim.keymap.set('v', '<leader>fa', function()
    vim.cmd 'CodeCompanion Function Analysis'
  end, vim.tbl_extend('force', opts, { desc = 'Function Analysis - Comprehensive breakdown' }))

  vim.keymap.set('n', '<leader>fa', function()
    -- Try to select current function first
    local code_extractor = require 'plugins.codecompanion.utils.code_extractor'
    local current_func = code_extractor.get_current_function()

    if current_func and current_func ~= '' then
      vim.cmd 'CodeCompanion Function Analysis'
    else
      print 'No function found at cursor. Please select code manually.'
    end
  end, vim.tbl_extend('force', opts, { desc = 'Function Analysis - Current function' }))

  -- Code Review - Detailed review with suggestions
  vim.keymap.set('v', '<leader>cr', function()
    vim.cmd 'CodeCompanion Code Review'
  end, vim.tbl_extend('force', opts, { desc = 'Code Review - Detailed analysis' }))

  vim.keymap.set('n', '<leader>cr', function()
    vim.cmd 'CodeCompanion Code Review'
  end, vim.tbl_extend('force', opts, { desc = 'Code Review - Current selection' }))

  -- Basic Explanation - Simple, quick explanation
  vim.keymap.set('v', '<leader>ce', function()
    vim.cmd 'CodeCompanion Explain Code'
  end, vim.tbl_extend('force', opts, { desc = 'Explain Code - Simple explanation' }))

  vim.keymap.set('n', '<leader>ce', function()
    vim.cmd 'CodeCompanion Explain Code'
  end, vim.tbl_extend('force', opts, { desc = 'Explain Code - Current line/selection' }))

  -- Additional helpful mappings
  vim.keymap.set('n', '<leader>cc', function()
    vim.cmd 'CodeCompanion'
  end, vim.tbl_extend('force', opts, { desc = 'Open CodeCompanion' }))

  vim.keymap.set('n', '<leader>ct', function()
    vim.cmd 'CodeCompanionChat Toggle'
  end, vim.tbl_extend('force', opts, { desc = 'Toggle CodeCompanion' }))

  -- Quick access to different analysis types
  vim.keymap.set('v', '<leader>cfa', function()
    vim.cmd 'CodeCompanion Function Analysis'
  end, vim.tbl_extend('force', opts, { desc = 'Function Analysis' }))

  vim.keymap.set('v', '<leader>cfr', function()
    vim.cmd 'CodeCompanion Code Review'
  end, vim.tbl_extend('force', opts, { desc = 'Code Review' }))

  vim.keymap.set('v', '<leader>cfe', function()
    vim.cmd 'CodeCompanion Explain Code'
  end, vim.tbl_extend('force', opts, { desc = 'Explain Code' }))
end

function M.get_keymap_info()
  return {
    ['<leader>fa'] = 'Function Analysis - Comprehensive code breakdown with diagrams',
    ['<leader>cr'] = 'Code Review - Detailed review with improvement suggestions',
    ['<leader>ce'] = 'Explain Code - Simple, clear explanation',
    ['<leader>cc'] = 'Open CodeCompanion chat',
    ['<leader>ct'] = 'Toggle CodeCompanion window',
    ['<leader>cfa'] = 'Function Analysis (visual mode)',
    ['<leader>cfr'] = 'Code Review (visual mode)',
    ['<leader>cfe'] = 'Explain Code (visual mode)',
  }
end

return M
