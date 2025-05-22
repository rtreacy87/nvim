# Windows-Specific Treesitter Issues and Solutions

Windows users often face unique challenges when setting up and using Treesitter in Neovim. This guide addresses common issues specific to Windows environments and provides practical solutions to get Treesitter working smoothly.

## Understanding Windows Environment Challenges

Windows differs from Unix-based systems in several ways that can affect Treesitter:

1. **Command-line environments vary** (PowerShell, CMD, Git Bash, WSL)
2. **Path handling and separators** are different
3. **Compiler availability and setup** is more complex
4. **Environment variables** may need special configuration

## Compiler-Related Issues

### Missing C Compiler

**Issue**: The most common error on Windows is missing a C compiler, which Treesitter needs to build parsers.

**Symptoms**:
- Error messages when running `:TSInstall` mentioning "no C compiler"
- Parser installation fails with compilation errors
- `:checkhealth nvim-treesitter` shows warnings about missing compilers

**Solutions**:

1. **Install MinGW (Minimalist GNU for Windows)**:
   ```powershell
   # Using Chocolatey
   choco install mingw
   
   # Using Scoop
   scoop install mingw
   ```

2. **Install Visual Studio Build Tools**:
   - Download from [Visual Studio Downloads](https://visualstudio.microsoft.com/downloads/)
   - Select "Build Tools for Visual Studio" (not the full VS)
   - In the installer, select "C++ build tools"

3. **Add the compiler to your PATH**:
   - For MinGW: Add `C:\path\to\mingw\bin` to your PATH
   - For VS Build Tools: Run Neovim from the "Developer PowerShell for VS" or "Developer Command Prompt for VS"

### PowerShell vs. Developer PowerShell

**Issue**: Regular PowerShell may not have access to the C compiler even if it's installed.

**Solution**:
- Use "Developer PowerShell for VS" or "Developer Command Prompt for VS" when working with Treesitter
- Create a shortcut that launches Neovim from the developer environment

```powershell
# Create a batch file (launch-nvim-dev.bat) with:
@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat"
nvim %*
```

### Different Compiler for Different File Types

**Issue**: You mentioned that PowerShell can find the C compiler, but markdown doesn't work in dev shell.

**Solution**:
- Ensure consistent compiler environment by setting explicit compiler paths in your Neovim config:

```lua
-- Add to your init.lua or treesitter.lua
vim.g.ts_cc = 'cl.exe'  -- For Visual Studio compiler
-- OR
vim.g.ts_cc = 'gcc.exe' -- For MinGW
```

## Installation Method Issues

### Curl vs. Git Download Methods

**Issue**: The default curl method for downloading parsers often fails on Windows due to SSL or proxy issues.

**Solution**:
- Configure Treesitter to use Git instead of curl (already in your config):

```lua
require('nvim-treesitter.install').prefer_git = true
```

### Parser Installation Failures

**Issue**: Some parsers fail to compile on Windows due to path issues or compiler incompatibilities.

**Solutions**:

1. **Install parsers one by one** to identify problematic ones:
   ```
   :TSInstall markdown
   :TSInstall python
   ```

2. **Check compiler output** for specific errors:
   ```
   :messages
   ```

3. **Try the sync_install option** for better error visibility:
   ```lua
   sync_install = true, -- Set temporarily for debugging
   ```

## Parser-Specific Issues on Windows

### Markdown Parser Issues

**Issue**: The markdown parser often has compilation issues on Windows.

**Solutions**:
1. **Reinstall with specific compiler flags**:
   ```
   :TSUninstall markdown
   :TSInstall markdown
   ```

2. **Use additional Vim regex highlighting as fallback**:
   ```lua
   highlight = {
     enable = true,
     additional_vim_regex_highlighting = { 'markdown' },
   }
   ```

### C/C++ Parser Issues

**Issue**: C/C++ parsers may fail with Visual Studio compiler.

**Solution**:
- Use MinGW specifically for these parsers or set specific compiler flags:
  ```lua
  require('nvim-treesitter.install').compilers = { "gcc", "clang", "cl" }
  ```

## Path and Environment Issues

### Long Paths on Windows

**Issue**: Windows has path length limitations that can cause issues with deeply nested node modules.

**Solution**:
- Enable long path support in Windows 10/11:
  1. Run `gpedit.msc`
  2. Navigate to Computer Configuration > Administrative Templates > System > Filesystem
  3. Enable "Enable Win32 long paths"
  
- Or set registry key:
  ```
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
  ```

### Environment Variable Conflicts

**Issue**: Conflicting environment variables can cause compiler detection issues.

**Solution**:
- Create a clean environment for Neovim:
  ```batch
  @echo off
  set PATH=C:\Windows\System32;C:\Windows;C:\Program Files\LLVM\bin;%USERPROFILE%\scoop\apps\mingw\current\bin
  nvim %*
  ```

## Troubleshooting Steps for Windows

1. **Check health and compiler detection**:
   ```
   :checkhealth nvim-treesitter
   ```

2. **Verify compiler availability in your shell**:
   ```powershell
   # For MinGW
   gcc --version
   
   # For Visual Studio
   cl
   ```

3. **Check Treesitter log file** for detailed error messages:
   ```lua
   -- Enable logging in init.lua
   vim.g.ts_debug = true
   ```
   Then check the log at: `%LOCALAPPDATA%\nvim-data\treesitter.log`

4. **Try installing with verbose output**:
   ```
   :verbose TSInstall markdown
   ```

## Advanced Solutions

### Using WSL for Treesitter

If you continue to have issues with native Windows, consider using WSL (Windows Subsystem for Linux):

1. Install WSL2 with Ubuntu
2. Install Neovim in WSL
3. Configure Treesitter in the WSL environment

### Creating Custom Parser Configurations

For problematic parsers, you can create custom configurations:

```lua
require('nvim-treesitter.parsers').get_parser_configs().markdown = {
  install_info = {
    url = "https://github.com/ikatyang/tree-sitter-markdown",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "master",
  },
  filetype = "markdown",
}
```

## Recommended Windows Configuration

Here's a Windows-optimized Treesitter configuration:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'lua', 'vim', 'vimdoc' }, -- Start with minimal parsers
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'markdown' }, -- Fallback for problematic parsers
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    indent = { 
      enable = true, 
      disable = { 'yaml', 'python', 'markdown' } -- Disable for problematic languages
    },
  },
  config = function(_, opts)
    -- Windows-specific settings
    require('nvim-treesitter.install').prefer_git = true
    require('nvim-treesitter.install').compilers = { "gcc", "clang", "cl" }
    
    -- Setup
    require('nvim-treesitter.configs').setup(opts)
  end,
}
```

## Next Steps

Now that you've addressed Windows-specific issues with Treesitter, you can continue exploring other Treesitter features and modules.

Return to [Troubleshooting and Optimization](07-troubleshooting-and-optimization.md) for general Treesitter troubleshooting.
