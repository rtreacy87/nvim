return {
  'jpalardy/vim-slime',
  config = function()
    -- Set the target to tmux
    vim.g.slime_target = 'tmux'
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_preserve_curpos = 1
    -- Default configuration for tmux
    vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }
    vim.g.slime_dont_ask_default = 1
    -- Key mappings
    vim.keymap.set('n', '<leader>vssc', '<Plug>SlimeSendCell', { desc = '[V]im [S]lime [S]end [C]ell' })
    vim.keymap.set('v', '<leader>vss', '<Plug>SlimeRegionSend', { desc = '[V]im [S]lime [S]end' })
    vim.keymap.set('n', '<leader>vssl', '<Plug>SlimeLineSend', { desc = '[V]im [S]lime [S]end [L]ine' })
    vim.keymap.set('n', '<leader>vssp', '<Plug>SlimeParagraphSend', { desc = '[V]im [S]lime [S]end [P]aragraph' })
  end,
}
