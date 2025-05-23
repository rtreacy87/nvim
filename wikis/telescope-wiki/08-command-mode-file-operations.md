# Command Mode File Operations in Neovim

While Telescope provides an excellent interface for finding and navigating files, it has limitations when working with macros or when you need to perform batch operations. This guide covers how to efficiently manage files using Neovim's command mode and registers, which works reliably with macros and automation.

## Why Use Command Mode for File Operations?

1. **Macro Compatibility**: Command mode operations can be recorded and played back reliably in macros
2. **Precise Control**: Direct access to Neovim's powerful command language
3. **Automation**: Can be used in scripts and complex workflows
4. **Consistency**: Works the same way across different Neovim versions and configurations

## Basic File Operations in Command Mode

### Opening Files

```vim
" Open a file
:edit path/to/file.txt

" Open multiple files
:args path/to/file1.txt path/to/file2.txt

" Open files matching a pattern
:args `find . -name "*.js"`
```

### Creating New Files

```vim
" Create and edit a new file
:edit path/to/new_file.txt

" Create a file with content from current buffer
:write path/to/new_file.txt
```

### Saving Files

```vim
" Save current file
:write

" Save with a new name (Save As)
:saveas path/to/new_name.txt

" Save all open buffers
:wall
```

### Renaming Files

```vim
" Rename current file (save with new name and delete old file)
:saveas path/to/new_name.txt | call delete(expand('#'))
```

### Deleting Files

```vim
" Delete the current file
:call delete(expand('%')) | bdelete!

" Delete a specific file
:call delete('path/to/file.txt')
```

## Using Registers for Path Manipulation

Registers are powerful tools for storing and manipulating file paths, especially when combined with command mode operations.

### Capturing the Current File Path

```vim
" Store current file path in register a
:let @a=expand('%')

" Store absolute path in register a
:let @a=expand('%:p')

" Store just the filename in register a
:let @a=expand('%:t')

" Store directory of current file in register a
:let @a=expand('%:h')
```

### Using Register Content in Commands

```vim
" Open a file in the same directory as current file
:execute 'edit ' . expand('%:h') . '/another_file.txt'

" Or using register directly
:let @a=expand('%:h')
:edit <C-r>a/another_file.txt
```

## Practical Examples with Registers and Command Mode

### Example 1: Duplicate a File with a New Name

```vim
" Store current file path in register a
:let @a=expand('%:p')

" Store just the filename without extension in register b
:let @b=expand('%:t:r')

" Create a copy with _copy suffix
:execute 'saveas ' . expand('%:h') . '/' . @b . '_copy' . '.' . expand('%:e')
```

### Example 2: Create a Related File (e.g., Test File for Implementation)

```vim
" If you're editing src/components/Button.js and want to create a test file
:let @a=expand('%:t:r')
:execute 'edit tests/' . @a . '.test.js'
```

### Example 3: Batch Rename Files in a Directory

```vim
" First, get a list of files
:args `find . -name "*.txt"`

" Then use argdo to perform operations on all files in the args list
:argdo let @c=expand('%:t:r') | saveas new_prefix_<C-r>c.txt | call delete(expand('#'))
```

## Using Command Mode with Macros

Command mode operations can be recorded in macros for repetitive tasks:

```vim
" Start recording to register q
qq

" Perform file operations
:let @a=expand('%:t:r')
:execute 'saveas backup/' . @a . '_backup.txt'

" Stop recording
q

" Play back the macro
@q
```

## Advanced Path Manipulation Techniques

### Working with Project Root

```vim
" Find git project root and store in register r
:let @r=system('git rev-parse --show-toplevel')[:-2]

" Open a file relative to project root
:execute 'edit ' . @r . '/src/main.js'
```

### Creating Directory Structure

```vim
" Create directory if it doesn't exist
:call mkdir(expand('%:h'), 'p')

" Create a new file in a new directory structure
:call mkdir('new/nested/dirs', 'p') | edit new/nested/dirs/file.txt
```

### Batch File Operations with Command Mode

```vim
" Find all JavaScript files and add an import statement at the top
:args `find . -name "*.js"`
:argdo normal ggO import { Component } from 'react'; | update
```

## Creating Custom Commands for File Operations

You can define custom commands in your Neovim configuration for common file operations:

```vim
" Add to your init.lua or init.vim

" Duplicate current file with a new name
command! -nargs=1 Duplicate execute 'saveas ' . expand('%:h') . '/' . <q-args> | edit <args>

" Create a test file for current implementation file
command! CreateTest execute 'edit ' . 'test/' . expand('%:t:r') . '_test.' . expand('%:e')

" Move current file to a new location
command! -nargs=1 Move saveas <args> | call delete(expand('#'))
```

## Integration with Telescope

While Telescope has limitations with macros, you can combine the best of both worlds:

```vim
" Use Telescope to find a file, then store its path for command mode operations
:Telescope find_files
" (select a file in Telescope)
:let @f=expand('%:p')

" Now use the path in register f for command mode operations
:execute 'saveas ' . @f . '.backup'
```

## Next Steps

Now that you understand how to perform file operations using command mode and registers, the next guide will cover specific use cases and workflows that combine these techniques with Telescope.

Continue to [Command Mode Workflows](09-command-mode-workflows.md).
