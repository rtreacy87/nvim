# Advanced Telescope Features in Neovim

This guide explores advanced features and extensions that can take your Telescope experience to the next level, including popular extensions, creating custom pickers, and optimizing performance.

## Using Extensions

Telescope's functionality can be extended through a variety of community-created extensions. Here are some of the most useful ones:

### telescope-fzf-native.nvim

This extension replaces the default sorter with a faster implementation using fzf's algorithm:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }

-- In your Telescope setup
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
require('telescope').load_extension('fzf')
```

### telescope-ui-select.nvim

This extension replaces Neovim's built-in `vim.ui.select` with Telescope:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-ui-select.nvim' }

-- In your Telescope setup
require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {}
    }
  }
}
require('telescope').load_extension('ui-select')
```

### telescope-file-browser.nvim

A file browser extension that allows you to browse directories and perform file operations:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-file-browser.nvim' }

-- In your Telescope setup
require('telescope').setup {
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          -- Custom mappings
        },
        ["n"] = {
          -- Custom mappings
        },
      },
    }
  }
}
require('telescope').load_extension('file_browser')

-- Add a keymap
vim.keymap.set('n', '<leader>fb', ':Telescope file_browser<CR>', { desc = 'File Browser' })
```

### telescope-project.nvim

Manage and switch between projects:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-project.nvim' }

-- In your Telescope setup
require('telescope').load_extension('project')

-- Add a keymap
vim.keymap.set('n', '<leader>fp', ':Telescope project<CR>', { desc = 'Projects' })
```

### telescope-dap.nvim

Integration with nvim-dap for debugging:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-dap.nvim' }

-- In your Telescope setup
require('telescope').load_extension('dap')

-- Add keymaps
vim.keymap.set('n', '<leader>dc', ':Telescope dap commands<CR>', { desc = 'DAP Commands' })
vim.keymap.set('n', '<leader>db', ':Telescope dap list_breakpoints<CR>', { desc = 'DAP Breakpoints' })
```

## Creating Custom Pickers

You can create your own pickers to search and select from custom data sources.

### Basic Custom Picker

Here's a simple example that creates a picker for selecting from a list of items:

```lua
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

-- Create a custom picker
local custom_picker = function(opts)
  opts = opts or {}
  
  -- Define your data
  local data = {
    { name = "Option 1", value = "opt1" },
    { name = "Option 2", value = "opt2" },
    { name = "Option 3", value = "opt3" },
  }
  
  -- Create the picker
  pickers.new(opts, {
    prompt_title = "Custom Picker",
    finder = finders.new_table {
      results = data,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Define what happens when an item is selected
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        -- Do something with the selection
        print("Selected: " .. selection.value.name)
      end)
      return true
    end,
  }):find()
end

-- Add a command to call your picker
vim.api.nvim_create_user_command('CustomPicker', function()
  custom_picker()
end, {})

-- Or add a keymap
vim.keymap.set('n', '<leader>cp', custom_picker, { desc = 'Custom Picker' })
```

### Advanced Custom Picker with Dynamic Data

Here's a more advanced example that fetches data dynamically:

```lua
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

-- Create a picker for recent git branches
local git_branches_picker = function(opts)
  opts = opts or {}
  
  -- Get git branches using a job
  local job = require('plenary.job')
  local results = {}
  
  job:new({
    command = 'git',
    args = { 'branch', '--sort=-committerdate' },
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        print("Error getting git branches")
        return
      end
      
      -- Process the output
      for _, line in ipairs(j:result()) do
        local branch = line:gsub("^%*?%s*", "")
        table.insert(results, branch)
      end
      
      -- Create the picker with the results
      pickers.new(opts, {
        prompt_title = "Recent Git Branches",
        finder = finders.new_table {
          results = results,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry,
              ordinal = entry,
            }
          end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            -- Checkout the selected branch
            vim.cmd('!git checkout ' .. selection.value)
          end)
          return true
        end,
      }):find()
    end,
  }):start()
end

-- Add a keymap
vim.keymap.set('n', '<leader>gb', git_branches_picker, { desc = 'Git Branches' })
```

## Integration with Other Plugins

### LSP Integration

Telescope integrates well with Neovim's built-in LSP:

```lua
-- LSP references
vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = 'Go to References' })

-- LSP implementations
vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, { desc = 'Go to Implementations' })

-- LSP definitions
vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = 'Go to Definition' })

-- LSP type definitions
vim.keymap.set('n', 'gt', require('telescope.builtin').lsp_type_definitions, { desc = 'Go to Type Definition' })

-- Document symbols
vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, { desc = 'Document Symbols' })

-- Workspace symbols
vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_workspace_symbols, { desc = 'Workspace Symbols' })
```

### Treesitter Integration

Telescope can work with Treesitter for advanced code navigation:

```lua
-- Find Treesitter symbols in current buffer
vim.keymap.set('n', '<leader>ts', require('telescope.builtin').treesitter, { desc = 'Treesitter Symbols' })
```

### Git Integration

Telescope has several built-in pickers for Git:

```lua
-- Git commits for current buffer
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_bcommits, { desc = 'Git Buffer Commits' })

-- Git commits for whole repository
vim.keymap.set('n', '<leader>gC', require('telescope.builtin').git_commits, { desc = 'Git Commits' })

-- Git branches
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = 'Git Branches' })

-- Git status
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Git Status' })

-- Git stash
vim.keymap.set('n', '<leader>gS', require('telescope.builtin').git_stash, { desc = 'Git Stash' })
```

## Performance Optimization

### Using fzf-native for Better Performance

The telescope-fzf-native extension significantly improves sorting performance:

```lua
-- In your plugins configuration
{ 
  'nvim-telescope/telescope-fzf-native.nvim', 
  build = 'make',
  cond = function()
    return vim.fn.executable 'make' == 1
  end,
}

-- In your Telescope setup
require('telescope').setup {
  defaults = {
    file_sorter = require('telescope.sorters').get_fzf_sorter(),
    generic_sorter = require('telescope.sorters').get_fzf_sorter(),
  }
}
require('telescope').load_extension('fzf')
```

### Optimizing File Indexing

For large projects, you can optimize file indexing:

```lua
require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "%.lock",
      "%.min.js",
    },
    
    -- Use fd for file finding if available
    find_command = vim.fn.executable "fd" == 1 and {
      "fd",
      "--type", "f",
      "--hidden",
      "--strip-cwd-prefix",
      "--exclude", ".git",
    } or nil,
  }
}
```

### Lazy Loading Extensions

Load extensions only when needed:

```lua
-- In your plugins configuration
{
  'nvim-telescope/telescope-file-browser.nvim',
  lazy = true,
  keys = {
    { '<leader>fb', function()
      require('telescope').load_extension('file_browser')
      vim.cmd('Telescope file_browser')
    end, desc = 'File Browser' }
  }
}
```

## Next Steps

Now that you've explored advanced Telescope features, the next guide will cover how to use Telescope for efficient project management.

Continue to [Telescope for Project Management](06-telescope-for-project-management.md).
