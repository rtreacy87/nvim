return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
  },
  config = function()
    -- Load custom prompts and utils with error handling
    local function_analysis_mod, examples_mod, code_extractor_mod, language_detector_mod
    local ok1, fa = pcall(require, 'cc.prompts.function_analysis')
    if ok1 then
      function_analysis_mod = fa
    end

    local ok2, ex = pcall(require, 'cc.prompts.examples')
    if ok2 then
      examples_mod = ex
    end

    local ok3, ce = pcall(require, 'cc.utils.code_extractor')
    if ok3 then
      code_extractor_mod = ce
    end

    local ok4, ld = pcall(require, 'cc.utils.language_detection')
    if ok4 then
      language_detector_mod = ld
    end

    require('codecompanion').setup {
      adapters = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            env = {
              url = 'http://localhost:11434',
            },
            schema = {
              model = {
                default = 'deepseek-coder:33b-instruct-q4_K_M',
                choices = {
                  'codellama:7b',
                  'codellama:13b',
                  'deepseek-coder:33b-instruct-q4_K_M',
                  'codellama:instruct',
                  'llama3.1:8b',
                },
              },
              num_ctx = {
                default = 16384,
              },
              temperature = {
                default = 0.1,
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
      prompt_library = {
        -- Enhanced function analysis action
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
                if function_analysis_mod then
                  return function_analysis_mod.get_system_prompt()
                else
                  return 'You are an expert programming analyst. Provide detailed function analysis with ASCII diagrams, executive summary, and line-by-line breakdown.'
                end
              end,
            },
            {
              role = 'user',
              content = function()
                local selected_code = ''
                local language = 'unknown'
                local examples_text = ''

                -- Try to get code using custom extractor with fallback
                if code_extractor_mod then
                  selected_code = code_extractor_mod.get_selected_code()
                else
                  -- Fallback to simple selection
                  local mode = vim.fn.mode()
                  if mode == 'v' or mode == 'V' or mode == '\22' then
                    local start_pos = vim.fn.getpos "'<"
                    local end_pos = vim.fn.getpos "'>"
                    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
                    selected_code = table.concat(lines, '\n')
                  else
                    selected_code = vim.api.nvim_get_current_line()
                  end
                end

                if not selected_code or selected_code == '' then
                  return 'No code selected. Please select a function to analyze.'
                end

                -- Try to get language and examples
                if language_detector_mod then
                  language = language_detector_mod.detect_language(selected_code)
                end

                if examples_mod then
                  examples_text = examples_mod.get_examples_for_language(language)
                end

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
        -- Basic code explanation (original functionality)
        ['Explain Code'] = {
          strategy = 'chat',
          description = 'Simple explanation of selected code',
          opts = {
            mapping = '<leader>ce',
          },
          prompts = {
            {
              role = 'system',
              content = 'You are a programming teacher. Explain code clearly and concisely.',
            },
            {
              role = 'user',
              content = function()
                local selected_code = ''

                -- Try custom extractor first
                if code_extractor_mod then
                  selected_code = code_extractor_mod.get_selected_code()
                else
                  -- Simple fallback
                  local mode = vim.fn.mode()
                  if mode == 'v' or mode == 'V' or mode == '\22' then
                    local start_pos = vim.fn.getpos "'<"
                    local end_pos = vim.fn.getpos "'>"
                    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
                    selected_code = table.concat(lines, '\n')
                  else
                    selected_code = vim.api.nvim_get_current_line()
                  end
                end

                if not selected_code or selected_code == '' then
                  return 'Please explain what a function is in programming.'
                end

                return 'Please explain this code:\n\n```\n' .. selected_code .. '\n```'
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
                local selected_code = ''
                local language = 'unknown'

                -- Try custom extractor first
                if code_extractor_mod then
                  selected_code = code_extractor_mod.get_selected_code()
                else
                  -- Simple fallback
                  local mode = vim.fn.mode()
                  if mode == 'v' or mode == 'V' or mode == '\22' then
                    local start_pos = vim.fn.getpos "'<"
                    local end_pos = vim.fn.getpos "'>"
                    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
                    selected_code = table.concat(lines, '\n')
                  else
                    selected_code = vim.api.nvim_get_current_line()
                  end
                end

                if not selected_code or selected_code == '' then
                  return 'No code selected. Please select code to review.'
                end

                if language_detector_mod then
                  language = language_detector_mod.detect_language(selected_code)
                end

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
