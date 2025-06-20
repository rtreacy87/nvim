return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      {
        'github/copilot.vim',
        config = function()
          vim.g.copilot_no_tab_map = true -- Disable default tab mapping
          -- Optional: Set alternative mapping for copilot suggestions
          vim.api.nvim_set_keymap('i', '<S-Tab>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
        end,
      }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      mappings = {
        complete = {
          insert = '<S-Tab>',
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
