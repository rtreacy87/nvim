return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            name = 'ollama',
            env = {
              url = 'http://localhost:11434',
            },
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              sync = true,
            },
            schema = {
              model = {
                default = 'codellama:7b',
                choices = {
                  'codellama:7b',
                  'codellama:13b',
                  'llama3.1:8b',
                  'codellama:7b-python',
                },
              },
              num_ctx = {
                default = 16384, -- Context window size
              },
              temperature = {
                default = 0.1, -- Lower for more consistent code
              },
              top_p = {
                default = 0.9,
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'ollama',
        },
        inline = {
          adapter = 'ollama',
        },
        agent = {
          adapter = 'ollama',
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = 'vertical', -- or 'horizontal', 'float'
            width = 0.45,
            height = 0.8,
          },
        },
      },
      opts = {
        log_level = 'ERROR', -- Change to 'DEBUG' for troubleshooting
        send_code = true, -- Include code context in messages
        use_default_actions = true,
        silence_notifications = false,
      },
    }
  end,
}
