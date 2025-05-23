# Troubleshooting and Tips for Telescope in Neovim

This guide covers common issues you might encounter when using Telescope, along with solutions and advanced tips to enhance your experience.

## Common Issues and Solutions

### Installation Problems

#### Missing Dependencies

**Issue**: Telescope fails to load with errors about missing modules.

**Solution**:
1. Ensure all required dependencies are installed:
   ```lua
   -- Required dependency
   { 'nvim-lua/plenary.nvim' }
   ```

2. Check if your package manager is properly installing dependencies:
   ```
   :checkhealth telescope
   ```

3. Try reinstalling Telescope and its dependencies:
   ```
   :Lazy sync  -- For lazy.nvim
   :PackerSync -- For packer.nvim
   ```

#### Build Failures for telescope-fzf-native

**Issue**: The telescope-fzf-native extension fails to build.

**Solution**:
1. Ensure you have a C compiler installed:
   - On macOS: `xcode-select --install`
   - On Ubuntu/Debian: `sudo apt install build-essential`
   - On Windows: Install MinGW or use WSL

2. Try building manually:
   ```bash
   cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim  # Path may vary
   make
   ```

3. If using Windows, try the cmake option:
   ```lua
   { 
     'nvim-telescope/telescope-fzf-native.nvim',
     build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
   }
   ```

### Performance Issues

#### Slow File Finding

**Issue**: Finding files is slow, especially in large projects.

**Solution**:
1. Install and use the fzf-native extension:
   ```lua
   { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
   require('telescope').load_extension('fzf')
   ```

2. Use fd instead of find for faster file indexing:
   ```lua
   require('telescope').setup {
     defaults = {
       find_command = vim.fn.executable "fd" == 1 and {
         "fd", "--type", "f", "--strip-cwd-prefix"
       } or nil,
     }
   }
   ```

3. Add appropriate file ignore patterns:
   ```lua
   require('telescope').setup {
     defaults = {
       file_ignore_patterns = {
         "node_modules",
         ".git/",
         "dist/",
         "build/",
         "target/",
       },
     }
   }
   ```

#### Slow Text Search

**Issue**: Live grep is slow or hangs on large codebases.

**Solution**:
1. Ensure ripgrep is installed and available in your PATH.

2. Add ignore patterns for ripgrep:
   ```lua
   require('telescope').setup {
     defaults = {
       vimgrep_arguments = {
         "rg",
         "--color=never",
         "--no-heading",
         "--with-filename",
         "--line-number",
         "--column",
         "--smart-case",
         "--glob=!node_modules/",
         "--glob=!.git/",
       },
     }
   }
   ```

3. Limit the search to specific directories:
   ```lua
   vim.keymap.set('n', '<leader>fg', function()
     local dir = vim.fn.input("Search directory: ", "", "dir")
     if dir ~= "" then
       require('telescope.builtin').live_grep({ cwd = dir })
     else
       require('telescope.builtin').live_grep()
     end
   end, { desc = 'Live Grep' })
   ```

### UI and Display Issues

#### Missing or Broken Icons

**Issue**: Icons don't display correctly in Telescope.

**Solution**:
1. Ensure you have a Nerd Font installed and configured in your terminal.

2. Install nvim-web-devicons:
   ```lua
   { 'nvim-tree/nvim-web-devicons' }
   ```

3. If you don't want to use a Nerd Font, disable icons:
   ```lua
   require('telescope').setup {
     defaults = {
       color_devicons = false,
     }
   }
   ```

#### Layout Problems

**Issue**: Telescope window appears too small or too large.

**Solution**:
1. Customize the layout configuration:
   ```lua
   require('telescope').setup {
     defaults = {
       layout_strategy = 'horizontal',
       layout_config = {
         width = 0.9,
         height = 0.8,
         preview_width = 0.5,
       },
     }
   }
   ```

2. Try different layout strategies:
   ```lua
   -- Options: horizontal, vertical, center, cursor
   layout_strategy = 'vertical',
   ```

3. Use a built-in theme:
   ```lua
   require('telescope.themes').get_dropdown()
   ```

## Platform-Specific Considerations

### Windows

1. Use WSL for better performance and compatibility.

2. If using native Windows:
   - Ensure you have the correct build tools for extensions
   - Use PowerShell instead of cmd for better Unicode support
   - Consider using `cmake` for building fzf-native

3. Path handling:
   ```lua
   require('telescope').setup {
     defaults = {
       path_display = function(_, path)
         -- Convert Windows paths to use forward slashes
         return path:gsub("\\", "/")
       end,
     }
   }
   ```

### macOS

1. Install dependencies via Homebrew:
   ```bash
   brew install ripgrep fd
   ```

2. For Apple Silicon (M1/M2) users, ensure your terminal and tools are running in the correct architecture.

### Linux

1. Install dependencies via your package manager:
   ```bash
   # Debian/Ubuntu
   sudo apt install ripgrep fd-find
   
   # Arch
   sudo pacman -S ripgrep fd
   ```

2. Create symlinks if needed:
   ```bash
   # On some systems, fd is installed as fdfind
   ln -s $(which fdfind) ~/.local/bin/fd
   ```

## Advanced Usage Patterns

### Telescope for Code Reviews

Create a custom picker for reviewing changed files:

```lua
local function review_changes()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  local results = {}
  local job = require('plenary.job')
  
  job:new({
    command = 'git',
    args = { 'diff', '--name-only' },
    on_exit = function(j, return_val)
      results = j:result()
      
      pickers.new({}, {
        prompt_title = 'Changed Files for Review',
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
          -- Open file on Enter
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd('edit ' .. selection.value)
          end)
          
          -- Show diff on Ctrl-d
          map('i', '<C-d>', function()
            local selection = action_state.get_selected_entry()
            vim.cmd('DiffviewOpen -- ' .. selection.value)
          end)
          
          return true
        end,
      }):find()
    end,
  }):start()
end

vim.keymap.set('n', '<leader>cr', review_changes, { desc = 'Code Review' })
```

### Task Management with Telescope

Create a simple task management system:

```lua
local function task_manager()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Load tasks from a file
  local tasks_file = vim.fn.expand('~/.config/nvim/tasks.json')
  local tasks = {}
  
  if vim.fn.filereadable(tasks_file) == 1 then
    local content = vim.fn.readfile(tasks_file)
    tasks = vim.fn.json_decode(table.concat(content, '\n'))
  else
    tasks = { { title = "Example task", status = "TODO" } }
  end
  
  local function save_tasks()
    local content = vim.fn.json_encode(tasks)
    vim.fn.writefile({content}, tasks_file)
  end
  
  pickers.new({}, {
    prompt_title = 'Task Manager',
    finder = finders.new_table({
      results = tasks,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.status .. ": " .. entry.title,
          ordinal = entry.status .. " " .. entry.title,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      -- Add new task
      map('i', '<C-n>', function()
        actions.close(prompt_bufnr)
        local title = vim.fn.input("Task title: ")
        if title ~= "" then
          table.insert(tasks, { title = title, status = "TODO" })
          save_tasks()
          task_manager()
        end
      end)
      
      -- Toggle task status
      map('i', '<C-t>', function()
        local selection = action_state.get_selected_entry()
        if selection.value.status == "TODO" then
          selection.value.status = "DONE"
        else
          selection.value.status = "TODO"
        end
        save_tasks()
        actions.close(prompt_bufnr)
        task_manager()
      end)
      
      -- Delete task
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        for i, task in ipairs(tasks) do
          if task == selection.value then
            table.remove(tasks, i)
            break
          end
        end
        save_tasks()
        actions.close(prompt_bufnr)
        task_manager()
      end)
      
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>tt', task_manager, { desc = 'Task Manager' })
```

### Session Management

Create a session management system with Telescope:

```lua
local function session_manager()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  local sessions_dir = vim.fn.expand('~/.config/nvim/sessions')
  
  -- Create sessions directory if it doesn't exist
  if vim.fn.isdirectory(sessions_dir) == 0 then
    vim.fn.mkdir(sessions_dir, 'p')
  end
  
  -- Get list of session files
  local session_files = vim.fn.glob(sessions_dir .. '/*.vim', false, true)
  local sessions = {}
  
  for _, file in ipairs(session_files) do
    table.insert(sessions, {
      name = vim.fn.fnamemodify(file, ':t:r'),
      path = file,
    })
  end
  
  pickers.new({}, {
    prompt_title = 'Sessions',
    finder = finders.new_table({
      results = sessions,
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
      -- Load session
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd('source ' .. selection.value.path)
        print("Loaded session: " .. selection.value.name)
      end)
      
      -- Save current session
      map('i', '<C-s>', function()
        actions.close(prompt_bufnr)
        local name = vim.fn.input("Session name: ")
        if name ~= "" then
          local path = sessions_dir .. '/' .. name .. '.vim'
          vim.cmd('mksession! ' .. path)
          print("Saved session: " .. name)
        end
      end)
      
      -- Delete session
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.fn.delete(selection.value.path)
        print("Deleted session: " .. selection.value.name)
      end)
      
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>fs', session_manager, { desc = 'Sessions' })
```

## Conclusion

Telescope is a powerful tool that can significantly enhance your Neovim workflow. By understanding how to troubleshoot common issues and leveraging advanced usage patterns, you can make the most of what Telescope has to offer.

Remember that Telescope is highly extensible, so don't hesitate to create custom pickers for your specific needs or explore the growing ecosystem of community extensions.

For more information and updates, visit the [official Telescope repository](https://github.com/nvim-telescope/telescope.nvim) and join the Neovim community on platforms like Reddit and Discord.
