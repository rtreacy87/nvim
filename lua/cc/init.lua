local M = {}

function M.setup(opts)
  opts = opts or {}

  -- Ensure required modules are available
  local modules = {
    'cc.prompts.function_analysis',
    'cc.prompts.examples',
    'cc.utils.code_extractor',
    'cc.utils.language_detector',
    'cc.config.keymaps',
  }

  for _, module_name in ipairs(modules) do
    local ok, _ = pcall(require, module_name)
    if not ok then
      vim.notify(string.format('CodeCompanion: Failed to load module %s', module_name), vim.log.levels.WARN)
    end
  end

  -- Set up key mappings if not disabled
  if not opts.disable_keymaps then
    require('plugins.codecompanion.config.keymaps').setup()
  end

  -- Print available commands
  if opts.show_help then
    M.show_help()
  end
end

function M.show_help()
  local keymaps = require('plugins.codecompanion.config.keymaps').get_keymap_info()

  print 'CodeCompanion Enhanced - Available Commands:'
  print '============================================'

  for keymap, description in pairs(keymaps) do
    print(string.format('  %s - %s', keymap, description))
  end

  print '\nUsage:'
  print '  1. Select code in visual mode and press the desired key combination'
  print '  2. Or position cursor in a function and use normal mode commands'
  print '  3. The analysis will appear in the CodeCompanion chat window'
end

function M.validate_setup()
  local required_plugins = {
    'codecompanion',
    'nvim-treesitter',
    'plenary',
  }

  local missing_plugins = {}

  for _, plugin in ipairs(required_plugins) do
    local ok, _ = pcall(require, plugin)
    if not ok then
      table.insert(missing_plugins, plugin)
    end
  end

  if #missing_plugins > 0 then
    vim.notify('CodeCompanion Enhanced: Missing required plugins: ' .. table.concat(missing_plugins, ', '), vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.get_status()
  local status = {
    setup_complete = false,
    modules_loaded = {},
    keymaps_active = false,
    codecompanion_available = false,
  }

  -- Check CodeCompanion availability
  local ok, _ = pcall(require, 'codecompanion')
  status.codecompanion_available = ok

  -- Check module loading
  local modules = {
    'function_analysis',
    'examples',
    'code_extractor',
    'language_detector',
    'keymaps',
  }

  for _, module in ipairs(modules) do
    local module_ok, _ = pcall(require, 'plugins.codecompanion.' .. module)
    status.modules_loaded[module] = module_ok
  end

  -- Check if keymaps are set
  local keymaps = vim.api.nvim_get_keymap 'n'
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs and keymap.lhs:match '<leader>fa' then
      status.keymaps_active = true
      break
    end
  end

  status.setup_complete = status.codecompanion_available and status.keymaps_active and status.modules_loaded.function_analysis

  return status
end

return M
