# Lazy Update Breaking Changes Troubleshooting Guide

## Overview
After running `:Lazy update`, several breaking changes and errors occurred. This guide explains each issue and provides solutions to restore functionality.

## Critical Errors Found

### 1. VectorCode Plugin Error
```
VectorCode  VectorCode 
....local/share/nvim/lazy/lazy.nvim/lua/lazy/manage/git.lua:58: attempt to index local 'range' (a nil value)
```

**What this means**: The VectorCode plugin has a Git-related error in Lazy.nvim's management system, likely due to Git repository corruption or version conflicts.

**Immediate Impact**: VectorCode plugin is non-functional and may prevent other plugins from loading properly.

### 2. Conform.nvim Breaking Changes
The update log shows Conform.nvim had multiple breaking changes, including:
- Removal of deprecated syntax and functions (5 months ago)
- Updated API requirements for Neovim 0.10+
- Changed formatter configurations

## Step-by-Step Solutions

### Fix 1: Resolve VectorCode Git Error

#### Option A: Clean Reinstall VectorCode
```bash
# Remove corrupted VectorCode installation
rm -rf ~/.local/share/nvim/lazy/VectorCode/

# Restart Neovim and let Lazy reinstall it
nvim
# Then run: :Lazy install VectorCode
```

#### Option B: Fix Git Repository
```bash
# Navigate to VectorCode directory
cd ~/.local/share/nvim/lazy/VectorCode/

# Check git status
git status

# If corrupted, reset the repository
git fetch origin
git reset --hard origin/main  # or origin/master

# If that fails, remove and reinstall (Option A)
```

#### Option C: Temporary Disable
```lua
-- In your VectorCode plugin config, temporarily disable it:
{
  "VectorCode/VectorCode",
  enabled = false,  -- Add this line
  -- ... rest of config
}
```

### Fix 2: Address Conform.nvim Breaking Changes

#### Check Current Conform Configuration
```lua
-- Look for deprecated syntax in your conform config
-- Common breaking changes to look for:

-- OLD (deprecated):
formatters_by_ft = {
  lua = { "stylua" },
  -- Using simple strings
}

-- NEW (current):
formatters_by_ft = {
  lua = { { "stylua" } },  -- Note the double braces for some formatters
  -- More explicit configuration required
}
```

#### Update Conform Configuration
```lua
-- Example updated configuration
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
  format_after_save = {
    lsp_format = "fallback",  -- Updated from lsp_fallback
  },
  -- Remove any deprecated options
})
```

### Fix 3: Check for Other Plugin Conflicts

#### Run Plugin Health Checks
```vim
:checkhealth conform
:checkhealth lazy
:checkhealth
```

#### Verify Neovim Version Compatibility
```bash
nvim --version
# Ensure you're running Neovim 0.10+ as required by updated Conform
```

## Systematic Recovery Process

### Step 1: Safe Mode Startup
```bash
# Start Neovim with minimal config to isolate issues
nvim --clean
```

### Step 2: Identify Broken Plugins
```vim
" In Neovim:
:Lazy check
:Lazy health
```

### Step 3: Selective Plugin Recovery
```vim
" Update one plugin at a time to identify specific issues
:Lazy update conform.nvim
:Lazy update VectorCode
```

### Step 4: Configuration Audit
Check these files for deprecated syntax:
- `lua/plugins/conform.lua` or similar
- `lua/plugins/vectorcode.lua` 
- Any custom formatter configurations

## Common Breaking Changes Patterns

### Conform.nvim Specific Changes
1. **Formatter specification**: Some formatters now require different argument formats
2. **LSP fallback**: `lsp_fallback` changed to `lsp_format = "fallback"`
3. **Exit codes**: Some formatters have updated expected exit codes
4. **Neovim version**: Now requires Neovim 0.10+

### General Plugin Update Issues
1. **API deprecations**: Old function names no longer supported
2. **Configuration schema**: Required vs optional parameters changed
3. **Dependencies**: New or updated plugin dependencies

## Prevention Strategies

### Before Future Updates
```vim
" Create a backup of working configuration
:!cp -r ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d)

" Update plugins selectively, not all at once
:Lazy update conform.nvim
" Test functionality before updating next plugin
```

### Monitor Breaking Changes
1. Check plugin GitHub releases before updating
2. Read CHANGELOG.md files for major updates
3. Test in a separate Neovim instance first

## Recovery Checklist

- [ ] VectorCode git error resolved
- [ ] Conform.nvim configuration updated for new API
- [ ] All plugins loading without errors (`:Lazy check`)
- [ ] Health checks passing (`:checkhealth`)
- [ ] Core functionality working (LSP, formatting, completion)
- [ ] Custom configurations compatible with updated plugins

## Emergency Rollback

If issues persist:
```bash
# Restore from backup
rm -rf ~/.config/nvim
mv ~/.config/nvim.backup.YYYYMMDD ~/.config/nvim

# Or restore specific plugin versions
cd ~/.local/share/nvim/lazy/conform.nvim
git log --oneline -10  # Find last working commit
git reset --hard <commit-hash>
```

## Next Steps
1. Fix the VectorCode git error first (highest priority)
2. Update conform configuration for new API
3. Test all formatting functionality
4. Monitor for any remaining deprecation warnings
5. Create a backup once everything is working

The key is to address issues systematically rather than updating everything at once, which makes it harder to isolate specific problems.