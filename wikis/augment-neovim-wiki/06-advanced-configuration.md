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
vim.keymap.set('v', '<leader>ac', ':Augment chat<CR>')  -- This works with visual selections!
vim.keymap.set('n', '<leader>an', ':Augment chat-new<CR>')
vim.keymap.set('n', '<leader>at', ':Augment chat-toggle<CR>')
```

### Using Visual Mode with Augment Chat

One of Augment's most powerful features is its ability to automatically include selected text in chat messages:

```vim
-- How to use visual mode with Augment:
-- 1. Select text in visual mode (v, V, or Ctrl-v)
-- 2. Type :Augment chat followed by your question
-- 3. Augment automatically includes the selected text

-- Example workflow:
-- 1. Select a function with V (line-wise visual mode)
-- 2. Type: :Augment chat How can I optimize this function?
-- 3. Augment will analyze the selected function and provide specific advice

-- Visual mode types:
-- v       - character-wise selection (precise)
-- V       - line-wise selection (entire lines)
-- Ctrl-v  - block-wise selection (rectangular blocks)
```

**Pro tip**: If you're having issues with visual mode selection, see the [Visual Mode Selection Not Working](#visual-mode-selection-not-working) section in the troubleshooting guide below.

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

### Visual Mode Selection Not Working

**Issue**: Augment chat not seeing highlighted text when in visual mode

This is a common issue where Augment doesn't include your selected text in chat messages.

**How Visual Mode Selection Should Work**:
1. Select text in visual mode (`v`, `V`, or `Ctrl-v`)
2. Type `:Augment chat` followed by your question
3. Augment automatically includes the selected text in your message

**Solutions**:

#### 1. **Verify Your Visual Mode Selection**
```vim
" Make sure you're actually in visual mode:
" - You should see -- VISUAL -- in the status line
" - The selected text should be highlighted
" - Try these visual modes:
"   v       - character-wise selection
"   V       - line-wise selection
"   Ctrl-v  - block-wise selection
```

#### 2. **Use the Range Command Method**
```vim
" Alternative approach that explicitly uses the selection:
" 1. Select text in visual mode
" 2. Type : (you'll see :'<,'> appear)
" 3. Complete with: Augment chat Your question here
"
" This tells Vim to explicitly use the visual selection range
```

#### 3. **Check for Plugin Conflicts**
```vim
" Some plugins may interfere with visual mode
" Test with minimal config:
nvim --clean

" Then manually test Augment to isolate the issue
" Common conflicting plugins:
" - Custom visual mode mappings
" - Text object plugins
" - Plugins that override the : command in visual mode
```

#### 4. **Verify Selection Timing**
```vim
" Make sure selection is active when running command:
" 1. Select text and keep it selected
" 2. Don't press Escape or move cursor
" 3. Immediately type :Augment chat
" 4. If selection disappears, re-select and try again
```

#### 5. **Test with Simple Examples**
```vim
" Test with a simple function:
function test() {
    return "hello";
}

" 1. Select the entire function with V (line-wise)
" 2. Type: :Augment chat What does this function do?
" 3. Check if Augment mentions the function in its response
```

#### 6. **Check Augment Logs**
```vim
" After trying to use visual selection, check logs:
:Augment log

" Look for messages like:
" "Making chat request with selected_text="your selected text""
" If selected_text is empty, the selection wasn't captured
```

#### 7. **Alternative Workaround**
```vim
" If visual mode selection still doesn't work:
" 1. Copy your selection to clipboard: y
" 2. Use regular chat: :Augment chat
" 3. Paste the code in your question manually
" 4. This isn't ideal but works as a temporary solution
```

**Best Practices for Visual Selections**:
- Select complete code blocks (entire functions, if statements, etc.)
- Use `V` (line-wise) for complete lines
- Use `v` (character-wise) for precise selections
- Combine with specific questions: "What does this function do?" rather than just "Explain this"

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
