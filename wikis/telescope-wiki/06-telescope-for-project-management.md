# Telescope for Project Management in Neovim

This guide explores how to use Telescope to efficiently manage projects, navigate codebases, and streamline your development workflow.

## Navigating Codebases Efficiently

### Project-Wide File Navigation

Quickly find files across your entire project:

```lua
-- Basic file finding
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })

-- Find files including hidden ones
vim.keymap.set('n', '<leader>fa', function()
  require('telescope.builtin').find_files({
    hidden = true,
    no_ignore = true,
    prompt_title = "All Files",
  })
end, { desc = 'Find All Files' })

-- Find files in a specific directory
vim.keymap.set('n', '<leader>fd', function()
  require('telescope.builtin').find_files({
    prompt_title = "Find in Directory",
    cwd = vim.fn.input("Directory: ", "", "dir"),
  })
end, { desc = 'Find in Directory' })
```

### Project-Wide Text Search

Search for text patterns across your entire codebase:

```lua
-- Basic grep
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live Grep' })

-- Grep with type filtering
vim.keymap.set('n', '<leader>ft', function()
  local file_type = vim.fn.input("File type: ")
  if file_type and file_type ~= "" then
    require('telescope.builtin').live_grep({
      prompt_title = "Grep " .. file_type .. " files",
      type_filter = file_type,
    })
  else
    require('telescope.builtin').live_grep()
  end
end, { desc = 'Grep by File Type' })

-- Grep in a specific directory
vim.keymap.set('n', '<leader>fG', function()
  require('telescope.builtin').live_grep({
    prompt_title = "Grep in Directory",
    cwd = vim.fn.input("Directory: ", "", "dir"),
  })
end, { desc = 'Grep in Directory' })
```

### Navigating Project Structure

Use Telescope to understand and navigate your project's structure:

```lua
-- Find directories
vim.keymap.set('n', '<leader>fD', function()
  require('telescope.builtin').find_files({
    find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
    prompt_title = "Find Directories",
  })
end, { desc = 'Find Directories' })

-- Using file_browser extension
vim.keymap.set('n', '<leader>fb', function()
  require('telescope').extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = vim.fn.expand('%:p:h'),
    respect_gitignore = false,
    hidden = true,
  })
end, { desc = 'File Browser' })
```

## Managing Buffers and Windows

### Buffer Management

Efficiently manage your open buffers:

```lua
-- List and select buffers
vim.keymap.set('n', '<leader>bb', require('telescope.builtin').buffers, { desc = 'Buffers' })

-- Enhanced buffer picker with additional actions
vim.keymap.set('n', '<leader>bB', function()
  require('telescope.builtin').buffers({
    sort_lastused = true,
    sort_mru = true,
    show_all_buffers = true,
    ignore_current_buffer = false,
    mappings = {
      i = {
        ["<c-d>"] = "delete_buffer",
      },
      n = {
        ["d"] = "delete_buffer",
      },
    },
  })
end, { desc = 'Manage Buffers' })

-- Find in current buffer
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find({
    prompt_title = "Search in Current Buffer",
    previewer = false,
  })
end, { desc = 'Search in Buffer' })
```

### Window Management

Use Telescope to help with window management:

```lua
-- Jump to window by title
local function telescope_windows()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Get all windows
  local windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filename = vim.api.nvim_buf_get_name(buf)
    local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
    
    -- Skip special buffers
    if buftype == '' or buftype == 'help' then
      table.insert(windows, {
        window_id = win,
        buffer_id = buf,
        filename = filename ~= '' and vim.fn.fnamemodify(filename, ':t') or '[No Name]',
        path = filename ~= '' and vim.fn.fnamemodify(filename, ':~:.') or '',
      })
    end
  end
  
  pickers.new({}, {
    prompt_title = 'Windows',
    finder = finders.new_table({
      results = windows,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.filename .. ' (' .. entry.window_id .. ')',
          ordinal = entry.filename,
          path = entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_set_current_win(selection.value.window_id)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>fw', telescope_windows, { desc = 'Find Window' })
```

## Git Integration

### Navigating Git History

Use Telescope to explore your project's Git history:

```lua
-- Browse git commits
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = 'Git Commits' })

-- Browse git commits for current buffer
vim.keymap.set('n', '<leader>gC', require('telescope.builtin').git_bcommits, { desc = 'Git Buffer Commits' })

-- Browse git branches
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = 'Git Branches' })

-- Show git status
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Git Status' })

-- Browse git stash
vim.keymap.set('n', '<leader>gS', require('telescope.builtin').git_stash, { desc = 'Git Stash' })
```

### Custom Git Workflows

Create custom pickers for specific Git workflows:

```lua
-- Show changed files between current branch and main
local function git_changed_files()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  local main_branch = "main" -- or "master" depending on your repo
  
  -- Get the list of changed files
  local job = require('plenary.job')
  local results = {}
  
  job:new({
    command = 'git',
    args = { 'diff', '--name-only', main_branch },
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        print("Error getting changed files")
        return
      end
      
      results = j:result()
      
      pickers.new({}, {
        prompt_title = 'Changed Files vs ' .. main_branch,
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry,
              ordinal = entry,
              path = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.file_previewer({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd('edit ' .. selection.value)
          end)
          return true
        end,
      }):find()
    end,
  }):start()
end

vim.keymap.set('n', '<leader>gd', git_changed_files, { desc = 'Git Changed Files' })
```

## Project-Specific Configurations

### Managing Multiple Projects

Use the telescope-project extension to manage multiple projects:

```lua
-- In your plugins configuration
{ 'nvim-telescope/telescope-project.nvim' }

-- In your Telescope setup
require('telescope').load_extension('project')

-- Add a keymap
vim.keymap.set('n', '<leader>fp', function()
  require('telescope').extensions.project.project({})
end, { desc = 'Projects' })
```

### Project-Specific Settings

Create a custom picker to apply project-specific settings:

```lua
local function project_settings()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Define project-specific settings
  local settings = {
    {
      name = "Web Frontend",
      apply = function()
        vim.cmd('set tabstop=2 shiftwidth=2 expandtab')
        vim.cmd('let g:prettier_autoformat = 1')
        print("Applied Web Frontend settings")
      end
    },
    {
      name = "Python Backend",
      apply = function()
        vim.cmd('set tabstop=4 shiftwidth=4 expandtab')
        vim.cmd('let g:python_highlight_all = 1')
        print("Applied Python Backend settings")
      end
    },
    {
      name = "Go Project",
      apply = function()
        vim.cmd('set tabstop=4 shiftwidth=4 noexpandtab')
        print("Applied Go Project settings")
      end
    },
  }
  
  pickers.new({}, {
    prompt_title = 'Project Settings',
    finder = finders.new_table({
      results = settings,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        selection.value.apply()
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>ps', project_settings, { desc = 'Project Settings' })
```

### Workspace Management

Create a custom picker to manage workspaces:

```lua
local function manage_workspaces()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Define your workspaces
  local workspaces = {
    { name = "Neovim Config", path = "~/.config/nvim" },
    { name = "Project A", path = "~/projects/project-a" },
    { name = "Project B", path = "~/projects/project-b" },
    -- Add more workspaces as needed
  }
  
  pickers.new({}, {
    prompt_title = 'Workspaces',
    finder = finders.new_table({
      results = workspaces,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        -- Change to the selected workspace
        vim.cmd('cd ' .. vim.fn.expand(selection.value.path))
        print("Changed to workspace: " .. selection.value.name)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>fw', manage_workspaces, { desc = 'Workspaces' })
```

## Next Steps

Now that you've learned how to use Telescope for project management, the next guide will cover troubleshooting common issues and provide additional tips for getting the most out of Telescope.

Continue to [Troubleshooting and Tips](07-troubleshooting-and-tips.md).
