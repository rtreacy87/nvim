# Fine-tuning and Troubleshooting Your Augment Code Setup

This final guide covers advanced configuration options and troubleshooting techniques to help you get the most out of Augment Code in Neovim.

## Advanced Configuration Options

### All Available Plugin Settings

Here's a complete list of settings you can add to your Neovim configuration:

```lua
-- Workspace folders to include in context (REQUIRED)
vim.g.augment_workspace_folders = {'/path/to/project'}

-- Disable the default Tab mapping for accepting suggestions
vim.g.augment_disable_tab_mapping = true  -- Default: false

-- Completely disable completions
vim.g.augment_disable_completions = true  -- Default: false

-- Configure the location of the log file
vim.g.augment_log_file = '~/augment.log'  -- Default: stdpath('data') .. '/augment.log'
```

Remember to set these options **before** the plugin is loaded.

### Creating a Complete Configuration

Here's an example of a complete configuration with custom keybindings:

```lua
-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Augment Code configuration
vim.g.augment_workspace_folders = {
  '~/projects/main-project',
  '~/projects/shared-libraries'
}
vim.g.augment_disable_tab_mapping = true

-- Load plugins
require('lazy').setup({
  -- Your other plugins
  { 'augmentcode/augment.vim' },
  -- More plugins
})

-- Custom keybindings for Augment (add after plugins are loaded)
-- Accept suggestions with Ctrl+y
vim.keymap.set('i', '<C-y>', '<cmd>call augment#Accept()<cr>')

-- Chat commands
vim.keymap.set('n', '<leader>ac', ':Augment chat<CR>')
vim.keymap.set('v', '<leader>ac', ':Augment chat<CR>')
vim.keymap.set('n', '<leader>an', ':Augment chat-new<CR>')
vim.keymap.set('n', '<leader>at', ':Augment chat-toggle<CR>')
```

### Performance Optimization Tips

To ensure Augment Code runs smoothly:

1. **Be Selective with Workspace Folders**: Only include folders that are relevant to your current work
2. **Use `.augmentignore`**: Exclude large directories like `node_modules` or `build`
3. **Limit Concurrent Operations**: Avoid running multiple resource-intensive operations at once
4. **Check Resource Usage**: If Neovim seems slow, check if the Node.js process is using too much CPU or memory

### Integration with Other Neovim Plugins

#### Working with nvim-cmp

If you use nvim-cmp for completions:

```lua
-- Disable Augment's Tab mapping
vim.g.augment_disable_tab_mapping = true

-- Configure nvim-cmp
require('cmp').setup({
  -- Your existing cmp configuration
  mapping = {
    -- Your existing mappings
    
    -- Add a mapping for Augment
    ['<C-a>'] = function()
      if vim.fn.pumvisible() == 0 then
        vim.fn.call('augment#Accept', {})
      else
        -- Handle nvim-cmp completion
      end
    end,
  },
})
```

#### Working with which-key

If you use which-key for keybinding hints:

```lua
require('which-key').register({
  a = {
    name = "Augment",
    c = { ':Augment chat<CR>', 'Chat' },
    n = { ':Augment chat-new<CR>', 'New Chat' },
    t = { ':Augment chat-toggle<CR>', 'Toggle Chat' },
    s = { ':Augment status<CR>', 'Status' },
  }
}, { prefix = '<leader>' })
```

## Common Issues and Solutions

### Authentication Problems

**Issue**: Unable to sign in or "Not authenticated" error

**Solutions**:
1. Run `:Augment signin` again
2. Check your internet connection
3. If a browser doesn't open automatically, check the URL in the command output and open it manually
4. Check `:Augment log` for specific error messages

### Workspace Indexing Issues

**Issue**: Workspace not syncing or syncing very slowly

**Solutions**:
1. Check that the paths in `vim.g.augment_workspace_folders` are correct
2. Create or update your `.augmentignore` file to exclude large directories
3. Check `:Augment status` to monitor progress
4. Check `:Augment log` for errors

### Completion Conflicts

**Issue**: Tab key not working as expected or conflicts with other plugins

**Solutions**:
1. Disable Augment's Tab mapping: `vim.g.augment_disable_tab_mapping = true`
2. Set up a custom key for accepting suggestions:
   ```lua
   vim.keymap.set('i', '<C-y>', '<cmd>call augment#Accept()<cr>')
   ```
3. Check which plugin is capturing the Tab key:
   ```
   :verbose imap <Tab>
   ```

### No Suggestions Appearing

**Issue**: Not seeing any code suggestions

**Solutions**:
1. Check if you're signed in: `:Augment status`
2. Make sure completions are enabled: `:Augment enable`
3. Verify your workspace is indexed: `:Augment status`
4. Check for errors: `:Augment log`

### Chat Not Working

**Issue**: Chat commands not working or no responses

**Solutions**:
1. Check if you're signed in: `:Augment status`
2. Try starting a new conversation: `:Augment chat-new`
3. Check for errors: `:Augment log`
4. Make sure your workspace is properly indexed

## Viewing and Understanding Logs

The Augment log can provide valuable information for troubleshooting:

1. View the log with: `:Augment log`
2. Look for error messages (they start with "ERROR")
3. Check for authentication issues or connection problems
4. Note any workspace indexing errors

You can also find the log file on your system:
- Default location: `~/.local/share/nvim/augment.log` (Linux/Mac) or `%LOCALAPPDATA%\nvim-data\augment.log` (Windows)
- Custom location: Wherever you set `vim.g.augment_log_file`

## Staying Updated

### Updating the Plugin

To update Augment Code:

With Lazy.nvim:
```
:Lazy update
```

With manual installation:
```bash
cd ~/.config/nvim/pack/augment/start/augment.vim
git pull
```

### Keeping Track of New Features

Stay informed about new features and updates:

1. Follow [Augment Code on GitHub](https://github.com/augmentcode/augment.vim)
2. Check the [CHANGELOG.md](https://github.com/augmentcode/augment.vim/blob/main/CHANGELOG.md) file for updates
3. Visit [augmentcode.com](https://augmentcode.com) for announcements

### Community Resources and Support

If you need help:

1. Check the [GitHub Issues](https://github.com/augmentcode/augment.vim/issues) for known problems and solutions
2. Report bugs or request features on GitHub
3. Contact support at [support@augmentcode.com](mailto:support@augmentcode.com)

## Conclusion

Congratulations! You've completed all six guides on integrating Augment Code with Neovim. You should now have a solid understanding of how to:

1. Install and configure Augment Code
2. Set up your workspace context for optimal results
3. Use AI-powered code completions
4. Leverage chat for code understanding and problem-solving
5. Fine-tune your setup and troubleshoot issues

With practice, Augment Code will become an invaluable part of your development workflow, helping you write better code faster and understand complex codebases more easily.

Happy coding!
