-- RAGS System Auto-commands

-- Auto-register buffers with VectorCode
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.py', '*.js', '*.ts', '*.lua', '*.go', '*.rs', '*.java', '*.cpp', '*.c', '*.h' },
  callback = function()
    -- Register buffer for RAG caching
    vim.schedule(function()
      local ok, vectorcode = pcall(require, 'vectorcode')
      if ok then
        vectorcode.register()
      end
    end)
  end,
})

-- Auto-update index when files change (debounced)
local update_timer = nil
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.py', '*.js', '*.ts', '*.lua', '*.go', '*.rs', '*.java', '*.cpp', '*.c', '*.h' },
  callback = function()
    if update_timer then
      update_timer:stop()
    end
    update_timer = vim.defer_fn(function()
      vim.system({ 'vectorcode', 'update' }, { detach = true })
    end, 5000) -- 5 second delay
  end,
})

-- Show RAGS status on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Check if all RAGS components are working
    vim.defer_fn(function()
      -- Check Ollama
      vim.system({ 'curl', '-s', 'http://127.0.0.1:11434/api/tags' }, {
        on_exit = function(obj)
          if obj.code == 0 then
            vim.notify('Ollama is running', vim.log.levels.INFO)
          else
            vim.notify('Ollama is not responding', vim.log.levels.WARN)
          end
        end,
      })

      -- Check VectorCode
      vim.system({ 'vectorcode', 'check' }, {
        on_exit = function(obj)
          if obj.code == 0 then
            vim.notify('VectorCode is working', vim.log.levels.INFO)
          else
            vim.notify('VectorCode is not working', vim.log.levels.WARN)
          end
        end,
      })
    end, 1000)
  end,
})
