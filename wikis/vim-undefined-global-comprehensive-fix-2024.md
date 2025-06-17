# Comprehensive Fix for "Undefined global `vim`" in 2024

## Critical Update: neodev.nvim is Deprecated

**Important**: As of July 2024, `neodev.nvim` has been **archived and marked as end-of-life**. The maintainer recommends migrating to `lazydev.nvim` for Neovim 0.10+.

## Root Cause Analysis

Based on latest 2024 research, the "undefined global vim" issue persists because:

1. **Setup order problems** - neodev/lazydev must run before lua_ls setup
2. **Incomplete lua_ls configuration** - missing globals and workspace settings
3. **Plugin deprecation** - using outdated neodev.nvim instead of lazydev.nvim
4. **Version compatibility** - different solutions for different Neovim versions

## Modern Solution (Recommended for Neovim 0.10+)

### Step 1: Replace neodev.nvim with lazydev.nvim

Remove neodev.nvim from your config and add:

```lua
{
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
```

### Step 2: Update Your LSP Configuration

Your lua_ls setup needs explicit vim global recognition:

```lua
require('lspconfig').lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' }, -- THIS IS CRITICAL
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
})
```

## Legacy Solution (Neovim < 0.10)

If you must use neodev.nvim:

```lua
-- Setup neodev BEFORE lspconfig
require("neodev").setup({
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = true,
  },
})

-- Then setup lua_ls
require('lspconfig').lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})
```

## Alternative: .luarc.json Method

Create `.luarc.json` in your Neovim config root:

```json
{
  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
  "diagnostics.globals": ["vim"],
  "runtime.version": "LuaJIT",
  "workspace.library": [
    "${3rd}/luv/library",
    "/usr/local/share/nvim/runtime/lua",
    "${HOME}/.local/share/nvim/lazy/*/lua"
  ],
  "workspace.checkThirdParty": false,
  "telemetry.enable": false
}
```

## Debugging Your Current Setup

### Step 1: Check LSP Client Configuration
```vim
:lua =vim.lsp.get_active_clients()[1].config.settings
```

### Step 2: Verify Runtime Files
```vim
:lua print(vim.inspect(vim.api.nvim_get_runtime_file("", true)))
```

### Step 3: Test vim Global Recognition
```vim
:lua print(type(vim))  -- Should print "table"
```

### Step 4: Check LSP Diagnostics
```vim
:lua print(vim.inspect(vim.diagnostic.get()))
```

## Implementation Guide for Your Config

Based on your current setup, here's the exact fix:

### Remove neodev.nvim completely
Your current config has both neodev in dependencies and a separate call. Remove both.

### Update your nvim-lspconfig.lua
Replace the current lua_ls configuration:

```lua
lua_ls = {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' }, -- ADD THIS LINE
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
},
```

### Add lazydev.nvim plugin
Create a new plugin file or add to existing:

```lua
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
```

## Common Pitfalls and Solutions

### Issue: Setup Order
**Problem**: neodev/lazydev not running before lua_ls
**Solution**: Ensure dependencies load first or use explicit setup calls

### Issue: Incomplete Globals
**Problem**: Only adding 'vim' but missing other globals
**Solution**: Add comprehensive globals list:
```lua
diagnostics = {
  globals = { 'vim', 'describe', 'it', 'before_each', 'after_each' },
}
```

### Issue: Wrong Workspace Library
**Problem**: LSP can't find Neovim runtime files
**Solution**: Use `vim.api.nvim_get_runtime_file("", true)` not static paths

### Issue: Plugin Conflicts
**Problem**: Multiple LSP configurations overriding each other
**Solution**: Consolidate all lua_ls config into one place

## Testing Your Fix

After implementing changes:

1. **Restart Neovim completely**
2. **Open a Lua file in your config**
3. **Type `vim.` and check for autocomplete**
4. **Run `:checkhealth` and look for LSP section**
5. **Check for absence of "undefined global vim" warnings**

## Emergency Fallback

If all else fails, you can suppress the warning temporarily:

```lua
-- Add to your lua_ls settings (NOT recommended long-term)
diagnostics = {
  disable = { "undefined-global" },
}
```

## Detailed Setup Instructions for lazydev.nvim

### Option 1: Separate Plugin File (Recommended)
Create a new file `~/.config/nvim/lua/plugins/lazydev.lua`:

```lua
return {
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
```

### Option 2: Add to Existing Plugin File
Add to any existing plugin file (like `lua/plugins/lsp.lua`):

```lua
return {
  -- your other plugins...
  
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
```

### Option 3: Add as Dependency to lspconfig
You can add it as a dependency in your lspconfig file:

```lua
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- your other dependencies...
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    -- your lspconfig setup
  end,
}
```

## Load Order and Dependencies

### ✅ No Special Load Order Required
Unlike neodev.nvim, **lazydev.nvim does NOT require special setup order**. You can:
- Load it in its own file
- Load it as a dependency 
- Load it anywhere in your plugin configuration

### ✅ Automatic Integration
lazydev.nvim automatically:
- Detects when you're editing Lua files
- Updates the lua_ls workspace library
- Provides Neovim API completion and documentation
- Works without explicit `require()` calls

### ✅ Lazy Loading
The `ft = "lua"` ensures it only loads when editing Lua files, improving startup time.

## Advanced Configuration Options

### Extended Library Configuration
```lua
{
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- Add specific plugin libraries
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      { path = "LazyVim", words = { "LazyVim" } },
      { path = "lazy.nvim", words = { "LazyVim" } },
    },
    enabled = function(root_dir)
      -- Disable in certain directories
      return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
    end,
  },
}
```

### Integration with luvit-meta (Optional)
For enhanced `vim.uv` support:

```lua
{
  "Bilal2453/luvit-meta", 
  lazy = true 
},
{
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  },
}
```

## Verification Steps

### 1. Check Plugin Installation
```vim
:Lazy
" Look for lazydev.nvim in the list
```

### 2. Test Lua File Detection
```vim
" Open a .lua file and check if lazydev loads
:LspInfo
" Should show lua_ls with enhanced configuration
```

### 3. Test vim.uv Completion
```lua
-- In a .lua file, type:
vim.uv.  -- Should show completion options
```

### 4. Verify No Errors
```vim
:checkhealth
:messages
" Should show no lazydev-related errors
```

## Troubleshooting Setup Issues

### Issue: Plugin Not Loading
**Check**: Ensure you're editing a `.lua` file (due to `ft = "lua"`)
**Solution**: Open any `.lua` file in your config

### Issue: No Completion Improvements
**Check**: Verify lua_ls is running with `:LspInfo`
**Solution**: Restart LSP with `:LspRestart`

### Issue: Conflicts with Existing Setup
**Check**: Remove any remaining neodev references
**Solution**: Use `:Lazy clean` to remove unused plugins

## Key Takeaway

The 2024 solution is **lazydev.nvim + proper lua_ls configuration**. The combination of using the modern plugin plus explicit `globals = { 'vim' }` in your LSP settings should resolve the issue definitively.

**Setup Summary:**
1. ✅ Add lazydev.nvim plugin (any method above)
2. ✅ Keep `globals = { 'vim' }` in your lua_ls settings  
3. ✅ Remove all neodev.nvim references
4. ✅ Restart Neovim and test on `.lua` files

Most importantly: **lazydev.nvim requires no special setup order** unlike the deprecated neodev.nvim, making it much easier to configure correctly.
