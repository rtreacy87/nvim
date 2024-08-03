vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'options'
require 'keymaps'
require 'lazy-install'

require('lazy').setup {
  require 'plugins.tokyonight',
  require 'plugins.neo-tree',
  require 'plugins.comment',
  require 'plugins.conform',
  require 'plugins.gitsigns',
  require 'plugins.mini',
  require 'plugins.nvim-cmp',
  require 'plugins.nvim-lspconfig',
  require 'plugins.telescope',
  require 'plugins.todo-comments',
  require 'plugins.treesitter',
  require 'plugins.vim-sleuth',
  require 'plugins.which-key',
  require 'plugins.vim-slime',
  require 'plugins.markdown-preview',
  require 'plugins.nvim-jqx',
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
