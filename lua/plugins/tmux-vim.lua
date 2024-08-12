return {
  'christoomey/vim-tmux-navigator',
  lazy = false,
  config = function()
    vim.keymap.set('n', '<c-h>', ':<C-U>TmuxNavigateLeft<cr>', { silent = true })
    vim.keymap.set('n', '<c-j>', ':<C-U>TmuxNavigateDown<cr>', { silent = true })
    vim.keymap.set('n', '<c-k>', ':<C-U>TmuxNavigateUp<cr>', { silent = true })
    vim.keymap.set('n', '<c-l>', ':<C-U>TmuxNavigateRight<cr>', { silent = true })
    vim.keymap.set('n', '<c-\\>', ':<C-U>TmuxNavigatePrevious<cr>', { silent = true })
  end,
}
