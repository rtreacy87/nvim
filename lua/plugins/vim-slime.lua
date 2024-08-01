return {
  'jpalardy/vim-slime',
  config = function()
    -- Set the target to tmux
    vim.g.slime_target = 'tmux'
    vim.g.slime_bracketed_paste = 1

    -- Default configuration for tmux
    vim.g.slime_default_config = { socket_name = 'default', target_pane = '1' }
    vim.g.slime_dont_ask_default = 1
  end,
}
