# Troubleshooting and Optimization for Treesitter

Even with a well-configured Treesitter setup, you might encounter issues or performance problems. This guide will help you troubleshoot common issues, optimize performance, and keep your Treesitter installation up to date.

## Diagnosing Treesitter Issues

### Using Health Checks

Neovim provides a health check for Treesitter that can identify common issues:

```vim
:checkhealth nvim-treesitter
```

This will check:
- If Treesitter is properly installed
- If the required dependencies are available
- If there are any issues with installed parsers

### Checking Parser Status

To see the status of all available parsers:

```vim
:TSInstallInfo
```

This shows:
- Which parsers are installed
- Which parsers are available but not installed
- The version of each installed parser

### Enabling Logging

You can enable logging to get more information about Treesitter operations:

```lua
-- Add to your init.lua
vim.g.ts_debug = true
```

Logs will be written to `~/.local/state/nvim/treesitter.log` (or `$XDG_STATE_HOME/nvim/treesitter.log`).

## Common Issues and Solutions

### Parser Installation Failures

**Issue**: Parser fails to install with compilation errors.

**Solutions**:
1. Check if you have a C compiler installed:
   ```bash
   gcc --version  # or clang --version
   ```

2. Try installing with Git instead of curl:
   ```lua
   require('nvim-treesitter.install').prefer_git = true
   ```

3. For Windows users, ensure you have the correct build tools:
   ```bash
   # Install MinGW
   choco install mingw
   # Or use Visual Studio Build Tools
   ```

### Syntax Highlighting Issues

**Issue**: Incorrect or missing syntax highlighting.

**Solutions**:
1. Update the parser:
   ```vim
   :TSUpdate <language>
   ```

2. Check if the parser is installed:
   ```vim
   :TSInstallInfo
   ```

3. Try using additional Vim regex highlighting:
   ```lua
   highlight = {
     enable = true,
     additional_vim_regex_highlighting = { '<language>' },
   }
   ```

4. Check for conflicts with other syntax plugins:
   ```vim
   :verbose set syntax?
   ```

### Performance Issues

**Issue**: Treesitter causing slowdowns or high CPU usage.

**Solutions**:
1. Disable Treesitter for large files:
   ```lua
   highlight = {
     enable = true,
     disable = function(lang, buf)
       local max_filesize = 100 * 1024 -- 100 KB
       local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
       if ok and stats and stats.size > max_filesize then
         return true
       end
     end,
   }
   ```

2. Limit the number of lines Treesitter processes:
   ```lua
   vim.g.ts_highlight_max_lines = 10000
   ```

3. Use a more efficient parser installation method:
   ```lua
   require('nvim-treesitter.install').prefer_git = true
   ```

### Folding Issues

**Issue**: Incorrect folding or slow folding performance.

**Solutions**:
1. Use a more efficient folding configuration:
   ```lua
   vim.opt.foldmethod = 'expr'
   vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
   -- Don't fold by default
   vim.opt.foldenable = false
   -- Start with all folds open
   vim.opt.foldlevel = 99
   ```

2. Disable folding for large files:
   ```lua
   vim.api.nvim_create_autocmd('BufReadPre', {
     pattern = '*',
     callback = function(args)
       local max_filesize = 100 * 1024 -- 100 KB
       local ok, stats = pcall(vim.loop.fs_stat, args.match)
       if ok and stats and stats.size > max_filesize then
         vim.opt_local.foldmethod = 'manual'
       else
         vim.opt_local.foldmethod = 'expr'
         vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
       end
     end
   })
   ```

### Compatibility Issues with Other Plugins

**Issue**: Conflicts between Treesitter and other plugins.

**Solutions**:
1. Load Treesitter before syntax plugins:
   ```lua
   use {
     'nvim-treesitter/nvim-treesitter',
     priority = 1000, -- High priority to load first
   }
   ```

2. Disable Vim's syntax for files with Treesitter parsers:
   ```lua
   vim.api.nvim_create_autocmd('FileType', {
     pattern = { 'lua', 'python', 'javascript' }, -- Add your languages
     callback = function()
       vim.opt_local.syntax = 'off'
     end
   })
   ```

## Updating Treesitter and Parsers

### Updating the Treesitter Plugin

To update the Treesitter plugin itself:

```vim
" Using Lazy.nvim
:Lazy update nvim-treesitter

" Using Packer
:PackerUpdate nvim-treesitter

" Using vim-plug
:PlugUpdate nvim-treesitter
```

### Updating Parsers

To update all installed parsers:

```vim
:TSUpdate
```

To update a specific parser:

```vim
:TSUpdate <language>
```

### Automatic Updates

You can set up automatic updates for parsers:

```lua
-- Add to your init.lua
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.exists(':TSUpdate') > 0 then
      vim.cmd('TSUpdate')
    end
  end
})
```

## Performance Optimization

### Lazy Loading

Load Treesitter only when needed:

```lua
-- Using Lazy.nvim
return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = {
    'TSInstall', 'TSUpdate', 'TSUpdateSync', 'TSInstallInfo',
    'TSInstallSync', 'TSInstallFromGrammar'
  },
  build = ':TSUpdate',
  config = function()
    -- Your Treesitter configuration
  end,
}
```

### Selective Parser Installation

Only install parsers for languages you actually use:

```lua
ensure_installed = {
  -- Base languages
  'lua', 'vim', 'vimdoc',
  
  -- Your primary languages
  'python', 'javascript', 'typescript',
  
  -- Common file formats
  'json', 'yaml', 'markdown',
}
```

### Disabling Unused Modules

Only enable the modules you actually use:

```lua
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  -- Only enable what you need
  -- indent = { enable = false },
  -- incremental_selection = { enable = false },
  -- textobjects = { enable = false },
})
```

### Optimizing for Large Files

Create a special configuration for large files:

```lua
vim.api.nvim_create_autocmd('BufReadPre', {
  pattern = '*',
  callback = function(args)
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, args.match)
    if ok and stats and stats.size > max_filesize then
      -- Disable treesitter for large files
      vim.cmd('TSBufDisable highlight')
      vim.cmd('TSBufDisable indent')
      vim.cmd('TSBufDisable incremental_selection')
      -- Use faster alternatives
      vim.opt_local.syntax = 'on'
      vim.opt_local.foldmethod = 'manual'
    end
  end
})
```

## Advanced Troubleshooting

### Debugging Parser Issues

If a specific parser is causing issues:

1. Use the Playground to inspect the syntax tree:
   ```vim
   :TSPlaygroundToggle
   ```

2. Check for parser errors:
   ```vim
   :TSHighlightCapturesUnderCursor
   ```

3. Try reinstalling the parser:
   ```vim
   :TSUninstall <language>
   :TSInstall <language>
   ```

### Creating Custom Parser Configurations

For languages with specific needs, you can create custom parser configurations:

```lua
require('nvim-treesitter.parsers').get_parser_configs().mylang = {
  install_info = {
    url = "https://github.com/username/tree-sitter-mylang",
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "mylang",
}
```

### Fixing Indentation Issues

If you're experiencing indentation issues with a specific language:

```lua
indent = {
  enable = true,
  disable = { "python", "yaml" }, -- Languages with problematic indentation
}
```

You can also create a custom indentation function:

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.indentexpr = 'MyCustomPythonIndent()'
  end
})

-- Define the custom indent function in Lua
_G.MyCustomPythonIndent = function()
  -- Your custom indentation logic
end
```

## Keeping Up with Treesitter Development

### Following the Project

- Star and watch the [nvim-treesitter repository](https://github.com/nvim-treesitter/nvim-treesitter)
- Join the [Neovim Discord](https://discord.gg/neovim) for discussions
- Check the [Treesitter documentation](https://tree-sitter.github.io/tree-sitter/)

### Contributing to Treesitter

If you encounter issues or have improvements:

1. Report issues on the [GitHub repository](https://github.com/nvim-treesitter/nvim-treesitter/issues)
2. Contribute fixes or enhancements via pull requests
3. Help improve documentation or create tutorials

## Conclusion

Congratulations! You've completed all seven guides in the Treesitter wiki series. You should now have a solid understanding of how to:

1. Understand what Treesitter is and how it works
2. Install and configure Treesitter in your Neovim setup
3. Use Treesitter for enhanced syntax highlighting
4. Navigate your code more efficiently with Treesitter
5. Use Treesitter text objects for smarter editing
6. Leverage advanced Treesitter modules for additional functionality
7. Troubleshoot issues and optimize performance

Treesitter is a powerful tool that can significantly enhance your Neovim experience. As you continue to use it, you'll discover more ways to customize and optimize it for your specific workflow.

Happy coding with Treesitter!
