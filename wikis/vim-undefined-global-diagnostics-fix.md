# "Undefined global `vim`" Lua Diagnostics Fix

## Problem
You're getting this error in your Neovim Lua files:
```
W Undefined global `vim`. Lua Diagnostics. (undefined-global) [6, 5]
```

## Root Cause
The Lua Language Server (lua-language-server) doesn't know about Neovim's `vim` global. This happens when:
1. LSP server lacks Neovim API definitions
2. Missing workspace configuration for Neovim Lua development
3. Incorrect LSP server settings

## Root Cause in Your Config
The issue was **setup order**. You had `neodev.nvim` installed but it wasn't being called before `lua_ls` setup, so the LSP server wasn't getting the Neovim API definitions.

**Fixed by**: Adding `require('neodev').setup()` at the start of your lspconfig function and removing the duplicate neodev.lua file.

## Solutions

### Solution 1: Configure lua-language-server for Neovim

#### Method A: Via LSP Config
```lua
-- In your lspconfig setup (likely lua/plugins/nvim-lspconfig.lua)
require('lspconfig').lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },  -- Recognize vim as global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
```

#### Method B: Via neodev.nvim Plugin (Recommended)
```lua
-- Install neodev.nvim in your plugin config
{
  "folke/neodev.nvim",
  opts = {}
}

-- Then configure lua_ls AFTER neodev setup
require("neodev").setup({})

require('lspconfig').lua_ls.setup({
  -- neodev handles most configuration automatically
})
```

### Solution 2: Check Current LSP Configuration

#### Verify LSP is Running
```vim
:LspInfo
```

#### Check LSP Settings
```vim
:lua =vim.lsp.get_active_clients()[1].config.settings
```

### Solution 3: Mason-specific Fix

#### Ensure Correct LSP Installation
```vim
:Mason
" Look for lua-language-server (not sumneko_lua which is deprecated)
```

#### Update Mason LSP Config
```lua
-- In your mason-lspconfig setup
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",  -- Make sure it's lua_ls, not sumneko_lua
  },
})
```

### Solution 4: Workspace-specific .luarc.json

Create `.luarc.json` in your Neovim config root:
```json
{
  "runtime.version": "LuaJIT",
  "diagnostics.globals": ["vim"],
  "workspace.library": [
    "/usr/local/share/nvim/runtime/lua",
    "~/.local/share/nvim/lazy/*/lua"
  ],
  "workspace.checkThirdParty": false,
  "telemetry.enable": false
}
```

### Solution 5: Quick Diagnostic Disable

#### Temporary File-level Fix
Add to top of your Lua files:
```lua
---@diagnostic disable: undefined-global
```

#### Global Diagnostic Disable (Not Recommended)
```lua
require('lspconfig').lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        disable = { "undefined-global" },
      },
    },
  },
})
```

## Debugging Steps

### Step 1: Verify LSP Client
```vim
:lua print(vim.inspect(vim.lsp.get_active_clients()))
```

### Step 2: Check Runtime Path
```vim
:lua print(vim.inspect(vim.api.nvim_get_runtime_file("", true)))
```

### Step 3: Test Vim Global Recognition
```vim
:lua print(type(vim))  -- Should print "table"
```

### Step 4: Restart LSP
```vim
:LspRestart
```

## Common File Locations to Check

### LSP Configuration Files
- `lua/plugins/nvim-lspconfig.lua`
- `lua/plugins/mason.lua` 
- `init.lua`

### Mason Installation Path  
- `~/.local/share/nvim/mason/packages/lua-language-server/`

## Expected Behavior After Fix

1. No more "undefined global `vim`" warnings
2. Vim API autocomplete working
3. Proper hover documentation for `vim.*` functions
4. Function signature help for Neovim APIs

## Verification Commands

```vim
" Check if vim global is recognized
:lua print(vim.version())

" Verify LSP diagnostics are clean
:lua vim.diagnostic.get()

" Test autocomplete works
" Type: vim. and see if autocomplete shows API functions
```

## Prevention

1. Always use `neodev.nvim` for Neovim Lua development
2. Ensure `lua_ls` (not deprecated `sumneko_lua`) is installed
3. Keep LSP configurations in sync with plugin updates
4. Use proper workspace library paths

The most reliable fix is installing `neodev.nvim` plugin, which automatically configures the Lua language server for Neovim development.