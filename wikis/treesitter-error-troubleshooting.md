# Treesitter Error Troubleshooting Guide

## Understanding the Error Messages

### Error 1: Treesitter Decoration Provider Error

```
ERR 2025-06-06T18:12:03.218 nvim.219074.0 decor_provider_error:36: Error in decoration provider "line" (ns=nvim.treesitter.highlighter):
Lua: ...nvim-treesitter/lua/nvim-treesitter/query_predicates.lua:80: attempt to call method 'parent' (a nil value)
```

**What this means line by line:**

1. **`ERR 2025-06-06T18:12:03.218`** - This is an error that occurred on June 6th, 2025 at 6:12 PM
2. **`nvim.219074.0`** - This is the specific Neovim process ID (219074) where the error happened
3. **`decor_provider_error:36`** - An error occurred in Neovim's decoration system (line 36 of that code)
4. **`Error in decoration provider "line"`** - The error is in the system that adds colors/highlights to lines of text
5. **`ns=nvim.treesitter.highlighter`** - Specifically in the Treesitter syntax highlighting system
6. **`Lua: ...nvim-treesitter/lua/nvim-treesitter/query_predicates.lua:80`** - The error is in line 80 of a Treesitter file
7. **`attempt to call method 'parent' (a nil value)`** - The code tried to call a function called 'parent' on something that doesn't exist (nil = nothing)

**In simple terms:** Treesitter (the system that colors your code) tried to find the "parent" of something in your code structure, but that something didn't exist, causing it to crash.

### Error 2: Stack Traceback

The lines starting with "stack traceback:" show the path the error took through different files:
- It started in `query_predicates.lua` (line 80)
- Traveled through `query.lua` (line 884, then 1013)  
- Ended up in `highlighter.lua` (lines 349, 237, 326, 423)

This is like following breadcrumbs to see how the error spread through the code.

### Error 3: TUI Stop Error

```
ERR 2025-06-09T21:04:12.608 ui.679454  tui_stop:628: TUI already stopped (race?) 
```

**What this means:**
- **TUI** = Terminal User Interface (how Neovim displays in your terminal)
- **"already stopped (race?)"** = Neovim tried to stop the display system, but it was already stopped
- This suggests a timing issue where multiple parts of Neovim tried to shut down at the same time

## Root Cause Analysis

These errors indicate:
1. **Treesitter parser corruption** - The syntax highlighting system has invalid data
2. **Version mismatch** - Treesitter parsers may be incompatible with your Neovim version
3. **Race condition** - Multiple processes competing to shut down Neovim

## Step-by-Step Fix Methods

### Method 1: Update and Reinstall Treesitter Parsers

```vim
" In Neovim, run these commands:
:TSUpdate
:TSInstall all
```

If that doesn't work:
```vim
:TSUninstall all
:TSInstall all
```

### Method 2: Clear Treesitter Cache

```bash
# In terminal:
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/parser/*
```

Then restart Neovim and reinstall parsers:
```vim
:TSInstall all
```

### Method 3: Check Neovim and Plugin Versions

```vim
" Check Neovim version
:version

" Check Treesitter status
:checkhealth nvim-treesitter
```

Update if needed:
```bash
# Update Neovim (Ubuntu/Debian)
sudo apt update && sudo apt upgrade neovim

# Or update plugins
# In Neovim:
:Lazy update
```

### Method 4: Temporary Disable Treesitter

Add this to your config to temporarily disable Treesitter:

```lua
-- In your Neovim config
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = false,  -- Disable highlighting
  },
})
```

### Method 5: Clean Reinstall

```bash
# Backup your config first
cp -r ~/.config/nvim ~/.config/nvim.backup

# Remove Treesitter completely
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/

# Restart Neovim and let Lazy reinstall it
```

## Prevention Tips

1. **Regular updates**: Run `:Lazy update` and `:TSUpdate` weekly
2. **Version compatibility**: Check that your Neovim version supports your Treesitter version
3. **Gradual updates**: Update one plugin at a time to identify problematic combinations

## When to Seek Further Help

If these methods don't work:
1. The issue may be in your specific configuration
2. Check the nvim-treesitter GitHub issues page
3. Your file type might have a corrupted parser
4. Consider reporting the bug with your exact Neovim and Treesitter versions

## Quick Health Check Commands

```vim
:checkhealth
:checkhealth nvim-treesitter  
:TSInstallInfo
:Lazy health nvim-treesitter
```

These commands will show you the current state of your Treesitter installation and highlight any issues.