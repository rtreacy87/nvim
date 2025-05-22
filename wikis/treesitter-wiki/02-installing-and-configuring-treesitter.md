# Installing and Configuring Treesitter in Neovim

This guide will walk you through the process of installing and configuring Treesitter in your Neovim setup. By the end, you'll have Treesitter up and running with your preferred languages.

## Prerequisites

Before installing Treesitter, make sure you have:

1. **Neovim 0.5.0 or newer** - Treesitter requires Neovim 0.5.0+
2. **Git** - Required for installing parsers
3. **A C compiler** - Needed to build the parsers:
   - Windows: MinGW or Visual Studio Build Tools
   - macOS: Xcode Command Line Tools
   - Linux: GCC or Clang

## Installation Methods

### Method 1: Using a Plugin Manager (Recommended)

The easiest way to install Treesitter is through a plugin manager like Lazy.nvim, Packer, or vim-plug.

#### Using Lazy.nvim

If you're using Lazy.nvim (as in your current setup), create or edit the file `lua/plugins/treesitter.lua`:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}
```

#### Using Packer

```lua
use {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end
}
```

#### Using vim-plug

```vim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" In your init.vim, after plug#end():
lua <<EOF
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
  auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
EOF
```

### Method 2: Manual Installation

If you prefer to install manually:

1. Clone the repository into your Neovim packages directory:

```bash
git clone https://github.com/nvim-treesitter/nvim-treesitter.git \
  ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter
```

2. Add the configuration to your `init.lua` or `init.vim`:

```lua
-- In init.lua
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
  auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
```

## Basic Configuration Options

Let's break down the basic configuration options:

### ensure_installed

This option specifies which language parsers to install:

```lua
ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown', 'python', 'javascript' }
```

You can also use `ensure_installed = "all"` to install all available parsers, but this is not recommended as it will use a lot of disk space.

### auto_install

When set to `true`, Treesitter will automatically install parsers for files you open:

```lua
auto_install = true
```

### highlight

Enables syntax highlighting:

```lua
highlight = {
  enable = true,
  -- Disable for specific languages
  disable = { "latex" },
  -- Use additional vim regex highlighting for specific languages
  additional_vim_regex_highlighting = { 'ruby' },
}
```

### indent

Enables indentation based on Treesitter:

```lua
indent = {
  enable = true,
  -- Disable for languages with problematic indentation
  disable = { 'python', 'ruby' },
}
```

## Installing Language Parsers

### Method 1: Using :TSInstall Command

Once Treesitter is installed, you can install parsers for specific languages using the `:TSInstall` command:

```
:TSInstall python javascript typescript lua
```

To see all available parsers:

```
:TSInstallInfo
```

### Method 2: Automatic Installation

If you've set `auto_install = true`, parsers will be installed automatically when you open a file of that type.

### Method 3: Ensuring Installation in Configuration

The `ensure_installed` option in your configuration will install the specified parsers when Neovim starts.

## Configuring Parser Installation Method

By default, Treesitter uses `curl` to download parsers. If you're having connectivity issues, you can configure it to use Git instead:

```lua
require('nvim-treesitter.install').prefer_git = true
```

## Checking Installation Status

To check which parsers are installed and their status:

```
:TSInstallInfo
```

This will show a list of all available parsers, whether they're installed, and their versions.

## Updating Parsers

To update all installed parsers:

```
:TSUpdate
```

To update a specific parser:

```
:TSUpdate python
```

## Complete Configuration Example

Here's a more comprehensive configuration example:

```lua
require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    'bash', 'c', 'cpp', 'css', 'html', 'javascript',
    'json', 'lua', 'markdown', 'python', 'rust',
    'typescript', 'vim', 'vimdoc', 'yaml'
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "phpdoc" },

  -- Highlighting configuration
  highlight = {
    enable = true,

    -- Disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    additional_vim_regex_highlighting = false,
  },

  -- Indentation based on treesitter for the = operator
  indent = {
    enable = true,
    disable = { "yaml" },
  },
})
```

### Understanding the Treesitter Configuration

Let's break down each section of this configuration to understand what it does and why it matters:

#### Parser Installation (`ensure_installed`)
```lua
ensure_installed = { 'bash', 'c', 'cpp', 'css', 'html', 'javascript', ... }
```
- **What it does**: Specifies which language parsers to install when Neovim starts
- **Why it's important**: Each parser enables Treesitter features for a specific language
- **Best practice**: Only include languages you regularly work with to save disk space and startup time

#### Synchronous Installation (`sync_install`)
```lua
sync_install = false
```
- **What it does**: When set to `false`, parsers are installed asynchronously (in the background)
- **Why it's important**: Asynchronous installation prevents Neovim from freezing during startup
- **When to change**: Set to `true` only if you want to ensure all parsers are ready immediately (will slow startup)

#### Automatic Installation (`auto_install`)
```lua
auto_install = true
```
- **What it does**: Automatically installs parsers when you open a file of a type not yet installed
- **Why it's important**: Provides a seamless experience without manual parser installation
- **Convenience factor**: Eliminates the need to run `:TSInstall` commands manually

#### Ignored Parsers (`ignore_install`)
```lua
ignore_install = { "phpdoc" }
```
- **What it does**: Specifies parsers to never install, even if `ensure_installed = "all"`
- **Why it's important**: Some parsers might be problematic or unnecessary for your workflow
- **When to use**: When certain parsers cause issues or you know you'll never need them

#### Syntax Highlighting (`highlight`)
```lua
highlight = { enable = true, ... }
```
- **What it does**: Enables Treesitter's advanced syntax highlighting
- **Why it's important**: Provides more accurate and context-aware highlighting than traditional regex-based methods
- **Performance consideration**: The `disable` function prevents Treesitter highlighting for large files to avoid slowdowns

#### Large File Handling
```lua
disable = function(lang, buf)
  local max_filesize = 100 * 1024 -- 100 KB
  -- Check file size logic
end
```
- **What it does**: Disables Treesitter highlighting for files larger than 100KB
- **Why it's important**: Prevents performance issues when editing large files
- **Customization tip**: Adjust the `max_filesize` value based on your computer's performance

#### Additional Vim Highlighting
```lua
additional_vim_regex_highlighting = false
```
- **What it does**: When `true`, runs both Treesitter and traditional Vim syntax highlighting
- **Why it's important**: Usually unnecessary and can cause conflicts or visual inconsistencies
- **When to enable**: Only for languages where Treesitter highlighting is incomplete

#### Indentation (`indent`)
```lua
indent = { enable = true, disable = { "yaml" } }
```
- **What it does**: Uses Treesitter for smarter auto-indentation when pressing `=`
- **Why it's important**: Provides more accurate indentation based on code structure
- **Language exceptions**: Some languages like YAML have special indentation rules that work better with Vim's native indentation

This configuration provides a balanced setup that enables Treesitter's powerful features while maintaining good performance. You can adjust these settings based on your specific needs and the languages you work with most frequently.

Here is the current configuration of the `treesitter.lua` plugin:
```lua
return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  config = function(_, opts)
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    -- Prefer git instead of curl in order to improve connectivity in some environments
    require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
```

## Common Language Parsers

Below is a table of commonly used programming languages and their corresponding parser names for Treesitter. Use these names in your `ensure_installed` configuration:

| Language | Parser Name | File Extensions |
|----------|-------------|----------------|
| Bash/Shell | `bash` | .sh, .bash |
| C | `c` | .c, .h |
| C++ | `cpp` | .cpp, .hpp, .cc |
| C# | `c_sharp` | .cs |
| CSS | `css` | .css |
| Dart | `dart` | .dart |
| Go | `go` | .go |
| HTML | `html` | .html, .htm |
| Java | `java` | .java |
| JavaScript | `javascript` | .js, .jsx |
| JSON | `json` | .json |
| Kotlin | `kotlin` | .kt, .kts |
| LaTeX | `latex` | .tex |
| Lua | `lua` | .lua |
| Markdown | `markdown` | .md, .markdown |
| PHP | `php` | .php |
| Python | `python` | .py |
| R | `r` | .r, .R, .Rmd |
| Ruby | `ruby` | .rb |
| Rust | `rust` | .rs |
| Scala | `scala` | .scala |
| SQL | `sql` | .sql |
| Swift | `swift` | .swift |
| TypeScript | `typescript` | .ts |
| TSX | `tsx` | .tsx |
| YAML | `yaml` | .yml, .yaml |
| Vim | `vim` | .vim |
| Vimdoc | `vimdoc` | help files |
| XML | `xml` | .xml |
| Zig | `zig` | .zig |

To see all available parsers, run `:TSInstallInfo` in Neovim.

#### Language Groups

You can also install groups of related parsers:

| Group | Description | Includes |
|-------|-------------|----------|
| `all` | All available parsers | Every parser in the Treesitter repository |
| `maintained` | Actively maintained parsers | Parsers that are regularly updated |

#### Example Configuration with Common Languages

```lua
ensure_installed = {
  -- Web Development
  'html', 'css', 'javascript', 'typescript', 'tsx',

  -- Backend Development
  'python', 'rust', 'go', 'java', 'php',

  -- Data/Config Formats
  'json', 'yaml', 'toml', 'xml',

  -- Shell/Scripting
  'bash', 'lua',

  -- Documentation
  'markdown', 'vimdoc',

  -- Neovim Configuration
  'vim', 'lua',
}
```

## Windows-Specific Considerations

If you're using Windows, you might encounter specific issues with compiler setup and parser installation. For detailed guidance on Windows-specific Treesitter challenges and solutions, see [Windows-Specific Treesitter Issues](08-windows-specific-treesitter-issues.md).

## Next Steps

Now that you have Treesitter installed and configured, the next guide will show you how to use Treesitter for syntax highlighting and customize it to your preferences.

Continue to [Syntax Highlighting with Treesitter](03-syntax-highlighting-with-treesitter.md).
