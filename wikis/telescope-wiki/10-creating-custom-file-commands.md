# Creating Custom File Commands in Neovim

This guide shows you how to create your own custom commands for file operations in Neovim. By defining custom commands, you can simplify complex workflows and make them more repeatable and reliable, especially when Telescope's interactive interface doesn't work well with macros.

## Why Create Custom File Commands?

1. **Simplify Complex Operations**: Reduce multi-step processes to a single command
2. **Ensure Consistency**: Perform operations the same way every time
3. **Improve Productivity**: Save time on repetitive tasks
4. **Enhance Macros**: Create reliable building blocks for macros
5. **Share Workflows**: Package your workflows for others to use

## Basic Command Definition Syntax

### Defining Commands in Vimscript

```vim
" Basic command syntax
command! CommandName action

" Command with arguments
command! -nargs=1 CommandName action <args>

" Command with file completion
command! -nargs=1 -complete=file CommandName action <args>

" Command with custom completion
command! -nargs=1 -complete=customlist,CompletionFunction CommandName action <args>
```

### Defining Commands in Lua (for Neovim)

```lua
-- Basic command in Lua
vim.api.nvim_create_user_command('CommandName', function()
  -- Command implementation
end, {})

-- Command with arguments
vim.api.nvim_create_user_command('CommandName', function(opts)
  local args = opts.args
  -- Command implementation using args
end, { nargs = 1 })

-- Command with file completion
vim.api.nvim_create_user_command('CommandName', function(opts)
  local file = opts.args
  -- Command implementation using file
end, { nargs = 1, complete = 'file' })
```

## Essential File Operation Commands

### File Creation Commands

```vim
" Create a new file in the same directory as the current file
command! -nargs=1 New execute 'edit ' . expand('%:h') . '/' . <q-args>

" Create a new file with boilerplate content
command! -nargs=1 NewJS execute 'edit ' . <q-args> | call setline(1, ['// ' . expand('%:t'), '', 'function main() {', '  ', '}', '', 'module.exports = { main };']) | normal! 4G

" Create a directory and a file in it
command! -nargs=1 NewDir call mkdir(fnamemodify(<q-args>, ':h'), 'p') | execute 'edit ' . <q-args>
```

### File Management Commands

```vim
" Duplicate the current file with a new name
command! -nargs=1 -complete=file Duplicate execute 'saveas ' . <q-args> | edit <args>

" Move/rename the current file
command! -nargs=1 -complete=file Move saveas <args> | call delete(expand('#'))

" Create a backup of the current file
command! Backup execute 'saveas ' . expand('%:p') . '.' . strftime('%Y%m%d%H%M%S') . '.bak'

" Delete the current file
command! DeleteFile call delete(expand('%')) | bdelete!
```

## Advanced Custom Commands

### Working with Related Files

```vim
" Switch between implementation and test file
command! ToggleTest call ToggleTestFile()

function! ToggleTestFile()
  let current_file = expand('%:p')
  let file_name = expand('%:t:r')
  let file_ext = expand('%:e')
  
  " Check if we're in a test file
  if current_file =~? '\\(_\\|\\.\)test\\.'
    " We're in a test file, switch to implementation
    let impl_name = substitute(file_name, '\\(_\\|\\.\)test$', '', '')
    let possible_files = [
          \ expand('%:h:h') . '/src/' . impl_name . '.' . file_ext,
          \ expand('%:h') . '/' . impl_name . '.' . file_ext,
          \ ]
    
    " Try to find the implementation file
    for impl_file in possible_files
      if filereadable(impl_file)
        execute 'edit ' . impl_file
        return
      endif
    endfor
    
    " If not found, create it
    execute 'edit ' . possible_files[0]
  else
    " We're in an implementation file, switch to test
    let test_name = file_name . '.test'
    let possible_files = [
          \ expand('%:h') . '/' . test_name . '.' . file_ext,
          \ expand('%:h:h') . '/tests/' . test_name . '.' . file_ext,
          \ ]
    
    " Try to find the test file
    for test_file in possible_files
      if filereadable(test_file)
        execute 'edit ' . test_file
        return
      endif
    endfor
    
    " If not found, create it
    execute 'edit ' . possible_files[0]
  endif
endfunction
```

### Project Structure Commands

```vim
" Create a new component with all related files
command! -nargs=1 Component call CreateComponent(<f-args>)

function! CreateComponent(name)
  " Create component directory
  call mkdir('src/components/' . a:name, 'p')
  
  " Create component file
  execute 'edit src/components/' . a:name . '/index.js'
  call setline(1, [
        \ 'import React from "react";',
        \ 'import "./' . a:name . '.css";',
        \ '',
        \ 'function ' . a:name . '() {',
        \ '  return (',
        \ '    <div className="' . a:name . '">',
        \ '      ',
        \ '    </div>',
        \ '  );',
        \ '}',
        \ '',
        \ 'export default ' . a:name . ';'
        \ ])
  write
  
  " Create CSS file
  execute 'edit src/components/' . a:name . '/' . a:name . '.css'
  call setline(1, [
        \ '.' . a:name . ' {',
        \ '  ',
        \ '}'
        \ ])
  write
  
  " Create test file
  execute 'edit src/components/' . a:name . '/' . a:name . '.test.js'
  call setline(1, [
        \ 'import React from "react";',
        \ 'import { render } from "@testing-library/react";',
        \ 'import ' . a:name . ' from "./index";',
        \ '',
        \ 'describe("' . a:name . '", () => {',
        \ '  it("renders correctly", () => {',
        \ '    const { container } = render(<' . a:name . ' />);',
        \ '    expect(container).toBeInTheDocument();',
        \ '  });',
        \ '});'
        \ ])
  write
  
  " Return to component file
  execute 'edit src/components/' . a:name . '/index.js'
  echo "Created component " . a:name
endfunction
```

### File Template Commands

```vim
" Create a file from a template
command! -nargs=+ -complete=custom,ListTemplates Template call CreateFromTemplate(<f-args>)

function! ListTemplates(ArgLead, CmdLine, CursorPos)
  " Get list of template files
  let templates_dir = expand('~/.config/nvim/templates')
  let templates = glob(templates_dir . '/*', 0, 1)
  let template_names = []
  
  for template in templates
    call add(template_names, fnamemodify(template, ':t'))
  endfor
  
  return join(template_names, "\n")
endfunction

function! CreateFromTemplate(template, destination)
  let template_path = expand('~/.config/nvim/templates/' . a:template)
  
  if !filereadable(template_path)
    echo "Template not found: " . a:template
    return
  endif
  
  " Create destination directory if needed
  call mkdir(fnamemodify(a:destination, ':h'), 'p')
  
  " Create the file
  execute 'edit ' . a:destination
  execute '0read ' . template_path
  
  " Replace template variables
  %s/{{filename}}/\=expand('%:t:r')/ge
  %s/{{date}}/\=strftime('%Y-%m-%d')/ge
  %s/{{year}}/\=strftime('%Y')/ge
  %s/{{author}}/Your Name/ge
  
  " Position cursor at a specific marker
  normal! gg
  if search('{{cursor}}', 'W')
    execute 's/{{cursor}}//'
  endif
  
  write
  echo "Created " . a:destination . " from template " . a:template
endfunction
```

## Creating Commands in Lua for Neovim

If you're using Lua for your Neovim configuration, here's how to create similar commands:

### Basic File Operations in Lua

```lua
-- Create a new file in the same directory as the current file
vim.api.nvim_create_user_command('New', function(opts)
  local current_dir = vim.fn.expand('%:h')
  local new_file = current_dir .. '/' .. opts.args
  vim.cmd('edit ' .. new_file)
end, { nargs = 1 })

-- Duplicate the current file with a new name
vim.api.nvim_create_user_command('Duplicate', function(opts)
  local new_file = opts.args
  vim.cmd('saveas ' .. new_file)
  vim.cmd('edit ' .. new_file)
end, { nargs = 1, complete = 'file' })

-- Move/rename the current file
vim.api.nvim_create_user_command('Move', function(opts)
  local old_file = vim.fn.expand('%')
  local new_file = opts.args
  vim.cmd('saveas ' .. new_file)
  vim.fn.delete(old_file)
end, { nargs = 1, complete = 'file' })
```

### Advanced File Operations in Lua

```lua
-- Toggle between implementation and test file
vim.api.nvim_create_user_command('ToggleTest', function()
  local current_file = vim.fn.expand('%:p')
  local file_name = vim.fn.expand('%:t:r')
  local file_ext = vim.fn.expand('%:e')
  
  -- Check if we're in a test file
  if string.match(current_file, "(_|%.)test%.") then
    -- We're in a test file, switch to implementation
    local impl_name = string.gsub(file_name, "(_|%.)test$", "")
    local possible_files = {
      vim.fn.expand('%:h:h') .. '/src/' .. impl_name .. '.' .. file_ext,
      vim.fn.expand('%:h') .. '/' .. impl_name .. '.' .. file_ext,
    }
    
    -- Try to find the implementation file
    for _, impl_file in ipairs(possible_files) do
      if vim.fn.filereadable(impl_file) == 1 then
        vim.cmd('edit ' .. impl_file)
        return
      end
    end
    
    -- If not found, create it
    vim.cmd('edit ' .. possible_files[1])
  else
    -- We're in an implementation file, switch to test
    local test_name = file_name .. '.test'
    local possible_files = {
      vim.fn.expand('%:h') .. '/' .. test_name .. '.' .. file_ext,
      vim.fn.expand('%:h:h') .. '/tests/' .. test_name .. '.' .. file_ext,
    }
    
    -- Try to find the test file
    for _, test_file in ipairs(possible_files) do
      if vim.fn.filereadable(test_file) == 1 then
        vim.cmd('edit ' .. test_file)
        return
      end
    end
    
    -- If not found, create it
    vim.cmd('edit ' .. possible_files[1])
  end
end, {})
```

## Integrating with Telescope

While these commands are designed to work well with macros where Telescope might have limitations, you can still create hybrid approaches:

```vim
" Use Telescope to find a directory, then create a file in it
command! NewInDir call NewFileInSelectedDir()

function! NewFileInSelectedDir()
  " Use Telescope to select a directory
  lua require('telescope.builtin').find_files({ find_command = { 'find', '.', '-type', 'd', '-not', '-path', '*/\\.*' } })
  
  " Store the selected directory for later use
  " (This part happens after user selects a directory in Telescope)
  " Then prompt for filename and create it
  let dir = input('Selected directory: ')
  let filename = input('New filename: ')
  execute 'edit ' . dir . '/' . filename
endfunction
```

## Organizing Your Custom Commands

As you create more custom commands, it's good to organize them:

```vim
" In your init.vim or init.lua, source a dedicated file for custom commands
source ~/.config/nvim/custom_commands.vim

" Or in Lua
vim.cmd('source ~/.config/nvim/custom_commands.vim')
```

In `custom_commands.vim`:
```vim
" File creation commands
command! -nargs=1 New execute 'edit ' . expand('%:h') . '/' . <q-args>
command! -nargs=1 NewJS execute 'edit ' . <q-args> | call setline(1, ['// ' . expand('%:t'), '', 'function main() {', '  ', '}', '', 'module.exports = { main };']) | normal! 4G

" File management commands
command! -nargs=1 -complete=file Duplicate execute 'saveas ' . <q-args> | edit <args>
command! -nargs=1 -complete=file Move saveas <args> | call delete(expand('#'))
command! Backup execute 'saveas ' . expand('%:p') . '.' . strftime('%Y%m%d%H%M%S') . '.bak'

" Project structure commands
command! -nargs=1 Component call CreateComponent(<f-args>)
command! ToggleTest call ToggleTestFile()

" Include function definitions here...
```

## Conclusion

Custom file commands provide a powerful way to enhance your Neovim workflow, especially for operations that need to be repeatable and reliable with macros. By creating your own commands, you can build a personalized file management system that complements Telescope's interactive strengths while addressing its limitations with macros.

Remember that the best approach is often a combination of tools: use Telescope for interactive exploration and selection, and custom commands for repeatable, macro-friendly operations.
