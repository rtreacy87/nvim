# Neovim 0.12 API Migration Guide

## Problem
You're running Neovim 0.12 and seeing deprecation warnings from plugins that haven't updated to the newer API changes. The main issues are:

1. **augment.vim**: Using deprecated LSP client methods
2. **codecompanion.nvim**: Using deprecated `vim.validate` 
3. General API migrations from `vim.*` to `vim.uv.*`

## Understanding Neovim 0.12 Changes

### Major API Migrations in 0.10+
- Many `vim.loop.*` functions moved to `vim.uv.*`
- `vim.validate()` signature changed
- LSP client methods changed from `client.request()` to `client:request()`
- `vim.lsp.start_client()` deprecated in favor of `vim.lsp.start()`

### Your Specific Errors

#### 1. Augment.vim LSP Issues
```
client.request is deprecated → use client:request
vim.lsp.start_client() is deprecated → use vim.lsp.start()
```

#### 2. CodeCompanion vim.validate Issues
```
vim.validate is deprecated → use vim.validate(name, value, validator, optional_or_msg)
```

## Solutions by Priority

### High Priority: Replace Problematic Plugins

#### Replace augment.vim
Augment.vim appears unmaintained. Switch to actively maintained alternatives:

**Option A: GitHub Copilot**
```lua
{
  "github/copilot.vim",
  -- or the Lua version:
  -- "zbirenbaum/copilot.lua"
}
```

**Option B: Codeium**
```lua
{
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({})
  end
}
```

**Option C: Continue.dev**
```lua
{
  "continuedev/continue.nvim",
  config = function()
    require("continue").setup()
  end
}
```

#### Update CodeCompanion
```vim
:Lazy update codecompanion.nvim
```

If still showing errors, check for newer versions or forks.

### Medium Priority: API Compatibility Layer

#### Create Compatibility Shim
Add this to your `init.lua` or a separate file:

```lua
-- Neovim 0.12 compatibility shim
if vim.fn.has('nvim-0.10') == 1 then
  -- Handle vim.validate deprecation
  local old_validate = vim.validate
  vim.validate = function(spec, ...)
    if type(spec) == "table" and not ... then
      -- Old format: vim.validate({ name = { value, type, optional } })
      return old_validate(spec)
    else
      -- New format: vim.validate(name, value, validator, optional_or_msg)
      return old_validate(spec, ...)
    end
  end
  
  -- Handle vim.loop → vim.uv migration
  if not vim.loop and vim.uv then
    vim.loop = vim.uv
  end
end
```

### Low Priority: Suppress Warnings Temporarily

#### Global Deprecation Warning Suppression
```lua
-- Add to init.lua - USE SPARINGLY
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:match("deprecated") then
    return -- Suppress deprecation warnings
  end
  return original_notify(msg, level, opts)
end
```

**Warning**: This hides ALL deprecation warnings, making future problems harder to diagnose.

## Plugin-Specific Fixes

### Check Plugin Update Status

#### Augment.vim Status Check
```bash
# Check last commit date
ls -la ~/.local/share/nvim/lazy/augment.vim/
cd ~/.local/share/nvim/lazy/augment.vim/
git log --oneline -5
```

If no recent commits (6+ months), consider it abandoned.

#### CodeCompanion Update Check
```bash
cd ~/.local/share/nvim/lazy/codecompanion.nvim/
git log --oneline -10 | grep -i "deprecat\|fix\|0\.1[2-9]"
```

### Manual Plugin Patching (Advanced)

#### Fix augment.vim Locally (Temporary)
```bash
cd ~/.local/share/nvim/lazy/augment.vim/lua/
# Backup original
cp augment.lua augment.lua.backup

# Edit the file to fix deprecations
# Line 43: vim.lsp.start_client() → vim.lsp.start()
# Line 71: client.request() → client:request()
```

**Note**: This will be overwritten on plugin updates.

## Recommended Migration Strategy

### Phase 1: Replace Abandoned Plugins (This Week)
1. **Remove augment.vim**, replace with Copilot or Codeium
2. **Update codecompanion.nvim** to latest version
3. Test core functionality

### Phase 2: Monitor and Update (Next Month)
1. Set up plugin update schedule
2. Monitor plugin GitHub issues for 0.12 compatibility
3. Replace any other plugins showing persistent warnings

### Phase 3: Long-term Maintenance
1. Only use actively maintained plugins
2. Check plugin update frequency before adoption
3. Have fallback alternatives for critical functionality

## Plugin Configuration Updates

### Remove Augment.vim
```lua
-- Comment out or remove from your plugin config
-- {
--   "github/augment.vim",
--   -- config
-- }
```

### Add Modern Alternative
```lua
-- Add to your plugin config
{
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false
    })
  end,
}
```

## Verification Steps

### After Changes
```vim
:checkhealth
:Lazy check
:Lazy health
```

### Test Core Functionality
1. LSP completion working
2. Code assistance working (if applicable)
3. No error popups during normal usage

## Prevention Strategy

### Plugin Selection Criteria
1. **Active maintenance**: Commits within last 3 months
2. **Neovim version support**: Explicitly supports your version
3. **Issue responsiveness**: Recent issues get responses
4. **Community adoption**: Many stars/forks

### Monitoring Tools
```vim
" Check plugin commit dates
:Lazy

" Look for plugins without recent updates
" Consider these candidates for replacement
```

## Emergency Rollback

If changes break functionality:

```bash
# Restore plugin backup
cd ~/.local/share/nvim/lazy/augment.vim/lua/
mv augment.lua.backup augment.lua

# Or remove problematic plugins temporarily
# Edit your plugin config to disable them
```

## Key Takeaway

**The root issue isn't Neovim 0.12**, it's that some plugins haven't been updated for newer Neovim APIs. The solution is replacing unmaintained plugins with actively maintained alternatives rather than trying to patch old code.

Focus on **augment.vim replacement** first, as it's the most problematic and appears abandoned.