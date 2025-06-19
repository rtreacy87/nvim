return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
  },
  config = function()
    -- Load custom prompts and utils
    local function_analysis = require 'cc.prompts.function_analysis'
    local examples = require 'cc.prompts.examples'
    local code_extractor = require 'cc.utils.code_extractor'
    local language_detector = require 'cc.utils.language_detection'
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
                default = 'codellama:13b',
                choices = {
                  'codellama:7b',
                  'codellama:13b',
                  'llama3.1:8b',
                  'codellama:7b-python',
                },
              },
              num_ctx = {
                default = 16384,
              },
              temperature = {
                default = 0.1,
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
      -- Enhanced function analysis action
      ['Function Analysis'] = {
        strategy = 'chat',
        description = 'Generate comprehensive function analysis with diagrams and examples',
        opts = {
          mapping = '<leader>fa',
        },
        prompts = {
          {
            role = 'system',
            content = function()
              return function_analysis.get_system_prompt()
            end,
          },
          {
            role = 'user',
            content = function()
              local selected_code = code_extractor.get_selected_code()
              local language = language_detector.detect_language(selected_code)
              local examples_text = examples.get_examples_for_language(language)
              return string.format(
                [[
Please analyze this %s function using the function analysis template provided in the system prompt.

%s

Selected Code:
```%s
%s
```

Please provide a comprehensive analysis following the template structure with ASCII diagrams, executive summary, and line-by-line breakdown.
              ]],
                language,
                examples_text,
                language,
                selected_code
              )
            end,
          },
        },
      },
      -- Code review action
      ['Code Review'] = {
        strategy = 'chat',
        description = 'Perform detailed code review with suggestions',
        opts = {
          mapping = '<leader>cr',
        },
        prompts = {
          {
            role = 'system',
            content = 'You are an expert code reviewer. Analyze code for bugs, performance, maintainability, and best practices.',
          },
          {
            role = 'user',
            content = function()
              local selected_code = code_extractor.get_selected_code()
              local language = language_detector.detect_language(selected_code)
              return string.format(
                [[
Please review this %s code and provide:
1. Overall assessment
2. Potential bugs or issues
3. Performance considerations  
4. Code quality improvements
5. Best practice recommendations

Code to review:
```%s
%s
```
              ]],
                language,
                language,
                selected_code
              )
            end,
          },
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = 'vertical',
            width = 0.45,
            height = 0.8,
          },
        },
      },
      opts = {
        log_level = 'ERROR',
        send_code = true,
        use_default_actions = true,
        silence_notifications = false,
      },
    }
    require('cc.config.keymaps').setup()
  end,
}
