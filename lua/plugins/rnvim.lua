return {
  'R-nvim/R.nvim',
  lazy = true,
},
  {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  },
  'R-nvim/cmp-r',
  {
    'hrsh7th/nvim-cmp',
    config = function()
      require('cmp').setup { sources = { { name = 'cmp_r' } } }
      require('cmp_r').setup {}
    end,
  }
