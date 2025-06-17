return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim', -- Improves UI
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            chat = {
              model = 'codellama:13b', -- Direct model assignment
            },
            inline = {
              model = 'codellama:7b',
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'ollama',
          roles = {
            llm = 'Assistant',
            user = 'User',
          },
          variables = {
            ['buffer'] = {
              callback = 'strategies.chat.variables.buffer',
              description = 'Share the current buffer with the LLM',
              opts = { contains_code = true },
            },
            ['viewport'] = {
              callback = 'strategies.chat.variables.viewport',
              description = 'Share the current viewport with the LLM',
              opts = { contains_code = true },
            },
            ['selection'] = {
              callback = 'strategies.chat.variables.selection',
              description = 'Share the current selection with the LLM',
              opts = { contains_code = true },
            },
          },
          slash_commands = {
            -- VectorCode integration for codebase search
            ['codebase'] = {
              callback = function(query)
                -- Execute VectorCode query and return results
                local handle = io.popen("vectorcode query '" .. query .. "' --format json --limit 5 2>/dev/null")
                if not handle then
                  return 'Error: Could not execute VectorCode query'
                end
                local result = handle:read '*a'
                local success = handle:close()
                if not success or not result or result == '' then
                  return 'No relevant code found for: ' .. query
                end

                local parsed_success, parsed = pcall(vim.json.decode, result)
                if not parsed_success or not parsed or type(parsed) ~= 'table' or #parsed == 0 then
                  return 'No relevant code found for: ' .. query
                end
                local context = 'Here are relevant code snippets from your codebase:\n\n'
                for i, item in ipairs(parsed) do
                  if i <= 5 then -- Limit to top 5 results
                    local file = item and item.file or 'unknown'
                    local score = item and item.score or 0
                    local language = item and item.language or ''
                    local content = item and item.content or ''
                    context = context .. string.format('**File: %s** (score: %.2f)\n```%s\n%s\n```\n\n', file, score, language, content)
                  end
                end
                return context
              end,
              description = 'Search codebase with RAG',
              opts = { contains_code = true },
            },

            -- Quick documentation search
            ['docs'] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " documentation' --include '*.md' --format json --limit 3 2>/dev/null")
                if not handle then
                  return 'Error: Could not execute documentation search'
                end
                local result = handle:read '*a'
                local success = handle:close()
                if not success or not result or result == '' then
                  return 'No documentation found for: ' .. query
                end

                local parsed_success, parsed = pcall(vim.json.decode, result)
                if not parsed_success or not parsed or type(parsed) ~= 'table' or #parsed == 0 then
                  return 'No documentation found for: ' .. query
                end
                local context = 'Documentation search results:\n\n'
                for i, item in ipairs(parsed) do
                  if i <= 3 then
                    local file = item and item.file or 'unknown'
                    local content = item and item.content or ''
                    local truncated = content:len() > 500 and (content:sub(1, 500) .. '...') or content
                    context = context .. string.format('**%s**\n%s\n\n', file, truncated)
                  end
                end
                return context
              end,
              description = 'Search documentation',
            },

            -- Search for tests
            ['tests'] = {
              callback = function(query)
                local handle = io.popen("vectorcode query '" .. query .. " test' --include '*test*' --include '*spec*' --format json --limit 3 2>/dev/null")
                if not handle then
                  return 'Error: Could not execute test search'
                end
                local result = handle:read '*a'
                local success = handle:close()
                if not success or not result or result == '' then
                  return 'No test code found for: ' .. query
                end

                local parsed_success, parsed = pcall(vim.json.decode, result)
                if not parsed_success or not parsed or type(parsed) ~= 'table' or #parsed == 0 then
                  return 'No test code found for: ' .. query
                end
                local context = 'Test-related code:\n\n'
                for i, item in ipairs(parsed) do
                  if i <= 3 then
                    local file = item and item.file or 'unknown'
                    local language = item and item.language or ''
                    local content = item and item.content or ''
                    context = context .. string.format('**%s**\n```%s\n%s\n```\n\n', file, language, content)
                  end
                end
                return context
              end,
              description = 'Search test files',
              opts = { contains_code = true },
            },
          },
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
            layout = 'vertical',
            width = 0.45,
            height = 0.8,
            relative = 'editor',
            border = 'rounded',
            title = 'CodeCompanion',
          },
          intro_message = 'Welcome! Use /codebase to search your code repository.',
        },
      },
    }
  end,
}
