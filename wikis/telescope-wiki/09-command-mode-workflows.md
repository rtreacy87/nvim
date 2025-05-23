# Command Mode Workflows in Neovim

This guide presents practical workflows that combine command mode operations, registers, and macros to efficiently manage files in Neovim. These workflows are particularly useful when Telescope's interactive interface doesn't work well with automation or macros.

## Workflow 1: Project File Structure Generation

Creating a consistent file structure for new components or modules is a common task. Here's how to automate it with command mode:

### Creating a React Component Structure

```vim
" Define a function to create a React component structure
function! CreateReactComponent(name)
  " Store the name in a register
  let @n=a:name
  
  " Create the directory if it doesn't exist
  execute 'silent !mkdir -p src/components/' . @n
  
  " Create the component file
  execute 'edit src/components/' . @n . '/' . @n . '.jsx'
  
  " Add boilerplate code
  execute 'normal! i' . "import React from 'react';\n\nfunction " . @n . "() {\n  return (\n    <div>\n      \n    </div>\n  );\n}\n\nexport default " . @n . ";"
  
  " Save the file
  write
  
  " Create the styles file
  execute 'edit src/components/' . @n . '/' . @n . '.css'
  execute 'normal! i' . "." . @n . " {\n  \n}"
  write
  
  " Create the test file
  execute 'edit src/components/' . @n . '/' . @n . '.test.jsx'
  execute 'normal! i' . "import { render, screen } from '@testing-library/react';\nimport " . @n . " from './" . @n . "';\n\ndescribe('" . @n . "', () => {\n  test('renders correctly', () => {\n    render(<" . @n . " />);\n    // Add your test assertions here\n  });\n});"
  write
  
  " Create an index file for easy imports
  execute 'edit src/components/' . @n . '/index.js'
  execute 'normal! i' . "export { default } from './" . @n . "';"
  write
  
  " Return to the component file
  execute 'edit src/components/' . @n . '/' . @n . '.jsx'
  echo "Created component structure for " . @n
endfunction

" Create a command to call this function
command! -nargs=1 CreateComponent call CreateReactComponent(<f-args>)
```

Usage:
```vim
:CreateComponent Button
```

This will create:
- `src/components/Button/Button.jsx`
- `src/components/Button/Button.css`
- `src/components/Button/Button.test.jsx`
- `src/components/Button/index.js`

### Recording This as a Macro

You can record a simplified version as a macro:

```vim
" Start recording to register c
qc

" Get component name from user
:let @n=input('Component name: ')

" Create directory and files
:silent !mkdir -p src/components/<C-r>n
:edit src/components/<C-r>n/<C-r>n.jsx
:normal! iimport React from 'react';

function <C-r>n() {
  return (
    <div>
      
    </div>
  );
}

export default <C-r>n;
:write

" Stop recording
q
```

## Workflow 2: Batch File Renaming with Consistent Patterns

When you need to rename multiple files following a pattern, command mode operations can be automated effectively:

### Renaming Files with Prefix/Suffix Changes

```vim
" Define a function to batch rename files
function! BatchRename(pattern, replacement)
  " Get a list of files matching the pattern
  let files = glob(a:pattern, 0, 1)
  
  " Process each file
  for file in files
    " Get the filename and directory
    let filename = fnamemodify(file, ':t')
    let directory = fnamemodify(file, ':h')
    
    " Create the new filename
    let new_filename = substitute(filename, a:pattern, a:replacement, '')
    
    " Rename the file
    call rename(file, directory . '/' . new_filename)
    
    echo "Renamed " . file . " to " . directory . '/' . new_filename
  endfor
endfunction

" Create a command to call this function
command! -nargs=+ Rename call BatchRename(<f-args>)
```

Usage:
```vim
:Rename "component_(.*)\.js" "Component\1.jsx"
```

This would rename files like:
- `component_button.js` → `ComponentButton.jsx`
- `component_card.js` → `ComponentCard.jsx`

### Using Command Mode Directly

For a simpler approach without defining functions:

```vim
" Get all JavaScript files
:args `find . -name "component_*.js"`

" Rename each file with a new pattern
:argdo let @f=substitute(expand('%:t'), 'component_\\(.*\\)\\.js', 'Component\\1.jsx', '') | saveas %:h/<C-r>f | call delete(expand('#')) | update
```

## Workflow 3: Creating File Pairs (Implementation and Test)

When developing with TDD, you often need to create implementation and test files together:

### Creating Implementation and Test Files

```vim
" Define a function to create file pairs
function! CreateFilePair(name, type)
  " Store the name in registers
  let @n=a:name
  let @t=a:type
  
  " Determine file extensions based on type
  let impl_ext = a:type ==? 'react' ? '.jsx' : '.js'
  let test_ext = a:type ==? 'react' ? '.test.jsx' : '.test.js'
  
  " Create the implementation file
  execute 'edit src/' . @n . impl_ext
  
  " Add appropriate boilerplate based on type
  if a:type ==? 'react'
    execute 'normal! i' . "import React from 'react';\n\nfunction " . @n . "() {\n  return (\n    <div>\n      \n    </div>\n  );\n}\n\nexport default " . @n . ";"
  else
    execute 'normal! i' . "/**\n * " . @n . "\n */\n\nfunction " . @n . "() {\n  \n}\n\nmodule.exports = " . @n . ";"
  endif
  
  write
  
  " Create the test file
  execute 'edit tests/' . @n . test_ext
  
  " Add test boilerplate
  if a:type ==? 'react'
    execute 'normal! i' . "import { render, screen } from '@testing-library/react';\nimport " . @n . " from '../src/" . @n . "';\n\ndescribe('" . @n . "', () => {\n  test('renders correctly', () => {\n    render(<" . @n . " />);\n    // Add your test assertions here\n  });\n});"
  else
    execute 'normal! i' . "const " . @n . " = require('../src/" . @n . "');\n\ndescribe('" . @n . "', () => {\n  test('works correctly', () => {\n    // Add your test assertions here\n  });\n});"
  endif
  
  write
  
  " Return to the implementation file
  execute 'edit src/' . @n . impl_ext
  echo "Created implementation and test files for " . @n
endfunction

" Create a command to call this function
command! -nargs=+ CreateFilePair call CreateFilePair(<f-args>)
```

Usage:
```vim
:CreateFilePair UserProfile react
```

This creates:
- `src/UserProfile.jsx` (with React boilerplate)
- `tests/UserProfile.test.jsx` (with React testing boilerplate)

## Workflow 4: Project Navigation with Bookmarks

While Telescope is great for fuzzy finding, sometimes you need to quickly jump between specific files in a project:

### Setting Up File Bookmarks

```vim
" Define a function to manage file bookmarks
function! BookmarkFile(name)
  " Store the current file path in a variable
  let g:bookmarks = get(g:, 'bookmarks', {})
  let g:bookmarks[a:name] = expand('%:p')
  echo "Bookmarked current file as '" . a:name . "'"
endfunction

" Define a function to go to a bookmarked file
function! GotoBookmark(name)
  let g:bookmarks = get(g:, 'bookmarks', {})
  if has_key(g:bookmarks, a:name)
    execute 'edit ' . g:bookmarks[a:name]
  else
    echo "No bookmark named '" . a:name . "'"
  endif
endfunction

" Define a function to list all bookmarks
function! ListBookmarks()
  let g:bookmarks = get(g:, 'bookmarks', {})
  echo "Bookmarks:"
  for [name, path] in items(g:bookmarks)
    echo "  " . name . ": " . path
  endfor
endfunction

" Create commands to call these functions
command! -nargs=1 Bookmark call BookmarkFile(<f-args>)
command! -nargs=1 Goto call GotoBookmark(<f-args>)
command! Bookmarks call ListBookmarks()
```

Usage:
```vim
" Bookmark the current file
:Bookmark config

" Go to a bookmarked file
:Goto config

" List all bookmarks
:Bookmarks
```

## Workflow 5: Template-Based File Generation

Creating files from templates is a common task that works well with command mode:

### Setting Up a Template System

```vim
" Define a function to create a file from a template
function! CreateFromTemplate(template, destination)
  " Check if the template exists
  let template_path = expand('~/.config/nvim/templates/' . a:template)
  if !filereadable(template_path)
    echo "Template '" . a:template . "' not found"
    return
  endif
  
  " Create the destination file
  execute 'edit ' . a:destination
  
  " Read the template content
  execute '0read ' . template_path
  
  " Replace template variables
  %s/{{filename}}/\=expand('%:t:r')/ge
  %s/{{date}}/\=strftime('%Y-%m-%d')/ge
  %s/{{author}}/Your Name/ge
  
  " Position cursor at a specific marker
  normal! gg
  if search('{{cursor}}', 'W')
    execute 's/{{cursor}}//'
  endif
  
  " Save the file
  write
  
  echo "Created " . a:destination . " from template " . a:template
endfunction

" Create a command to call this function
command! -nargs=+ Template call CreateFromTemplate(<f-args>)
```

Usage:
```vim
:Template react-component.jsx src/components/Button.jsx
```

## Combining with Telescope

While these workflows focus on command mode operations, you can still leverage Telescope for the parts where it excels:

```vim
" Use Telescope to find a file, then apply a command mode operation
:Telescope find_files
" (select a file in Telescope)

" Then use command mode to create a related file
:let @f=expand('%:t:r')
:execute 'edit test/' . @f . '_test.js'
```

## Next Steps

Now that you've learned about practical command mode workflows, the next guide will cover how to create your own custom commands and functions to further enhance your file management capabilities in Neovim.

Continue to [Creating Custom File Commands](10-creating-custom-file-commands.md).
