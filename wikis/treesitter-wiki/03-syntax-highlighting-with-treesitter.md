# Syntax Highlighting with Treesitter

One of the primary benefits of Treesitter is its superior syntax highlighting. This guide will show you how to enable, customize, and troubleshoot Treesitter's syntax highlighting features.

## Enabling Treesitter Highlighting

Treesitter highlighting is enabled through the configuration:

```lua
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
  },
})
```

Once enabled, Treesitter will automatically use its highlighting for files with installed parsers.

## How Treesitter Highlighting Works

Treesitter highlighting works differently from traditional Vim syntax highlighting:

1. **Parsing**: Treesitter builds a syntax tree of your code
2. **Queries**: It uses language-specific queries to identify syntax elements
3. **Highlighting**: It applies highlight groups to these elements

This approach provides more accurate and consistent highlighting across languages.

## Comparing Traditional and Treesitter Highlighting

To see the difference between traditional and Treesitter highlighting:

1. Open a file with Treesitter highlighting enabled
2. Run `:set syntax=off` to disable traditional syntax highlighting
3. Run `:TSBufToggle highlight` to toggle Treesitter highlighting

You'll notice that Treesitter provides more accurate highlighting, especially for:
- Nested structures
- Multi-line constructs
- Language-specific features

## Understanding Highlight Groups

Treesitter uses a standardized set of highlight groups across languages:

| Highlight Group | Description | Example |
|-----------------|-------------|---------|
| `@variable` | Variables | `x`, `count` |
| `@function` | Function names | `print()`, `getData()` |
| `@function.call` | Function calls | `myFunc()` |
| `@parameter` | Function parameters | `name` in `function(name)` |
| `@method` | Method names | `toString()` |
| `@field` | Object fields/properties | `user.name` |
| `@property` | Object properties | `obj.property` |
| `@constructor` | Constructors | `new Class()` |
| `@conditional` | Conditionals | `if`, `else`, `switch` |
| `@repeat` | Loops | `for`, `while` |
| `@label` | Labels | `case` in switch statements |
| `@keyword` | Keywords | `return`, `async` |
| `@string` | Strings | `"hello"` |
| `@number` | Numbers | `42`, `3.14` |
| `@boolean` | Booleans | `true`, `false` |
| `@operator` | Operators | `+`, `=`, `=>` |
| `@punctuation.delimiter` | Delimiters | `;`, `,` |
| `@punctuation.bracket` | Brackets | `()`, `{}`, `[]` |
| `@comment` | Comments | `// comment` |
| `@type` | Types | `int`, `String` |
| `@namespace` | Namespaces | `namespace`, `module` |

## Customizing Highlight Groups

You can customize how Treesitter highlight groups appear by linking them to your color scheme's highlight groups:

```lua
-- In your init.lua or after/plugin/treesitter.lua
vim.api.nvim_set_hl(0, '@function', { link = 'GruvboxBlue' })
vim.api.nvim_set_hl(0, '@keyword', { link = 'GruvboxRed' })
vim.api.nvim_set_hl(0, '@string', { link = 'GruvboxGreen' })
vim.api.nvim_set_hl(0, '@variable', { link = 'GruvboxFg1' })
```

Or you can define custom colors:

```lua
vim.api.nvim_set_hl(0, '@function', { fg = '#61AFEF', bold = true })
vim.api.nvim_set_hl(0, '@keyword', { fg = '#E06C75', italic = true })
```

## Language-Specific Highlighting

### Enabling Additional Vim Regex Highlighting

Some languages may benefit from additional Vim regex highlighting alongside Treesitter:

```lua
highlight = {
  enable = true,
  additional_vim_regex_highlighting = { 'ruby', 'php' },
}
```

### Disabling Treesitter for Specific Languages

If Treesitter highlighting doesn't work well for a particular language, you can disable it:

```lua
highlight = {
  enable = true,
  disable = { 'latex', 'yaml' },
}
```

You can also disable it conditionally, such as for large files:

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

## Treesitter and Color Schemes

Many modern Neovim color schemes are designed with Treesitter in mind. Some popular Treesitter-aware color schemes include:

- Tokyonight
- Catppuccin
- Gruvbox Material
- Nightfox
- Onedark

These color schemes provide specific highlight groups for Treesitter's capture groups, resulting in better syntax highlighting.

## Inspecting Highlight Groups

To see which highlight group is applied to an element under your cursor:

```vim
:TSHighlightCapturesUnderCursor
```

This is useful for debugging or when customizing highlight groups.

## Troubleshooting Common Highlighting Issues

### Missing Highlighting

If syntax highlighting isn't working:

1. Check if the parser is installed: `:TSInstallInfo`
2. Install the parser if needed: `:TSInstall [language]`
3. Verify that highlighting is enabled in your config
4. Check for errors: `:checkhealth nvim-treesitter`

### Incorrect Highlighting

If highlighting looks wrong:

1. The parser might be outdated: `:TSUpdate [language]`
2. There might be conflicts with other syntax plugins
3. The language might need additional Vim regex highlighting

### Slow Performance

If highlighting is causing performance issues:

1. Disable Treesitter for large files (see the conditional disable example above)
2. Update to the latest Neovim version
3. Update your Treesitter parsers: `:TSUpdate`

## Advanced Highlighting Features

### Rainbow Parentheses

You can enable rainbow parentheses with the `rainbow` module:

```lua
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  }
})
```

Note: This requires the `p00f/nvim-ts-rainbow` or `HiPhish/nvim-ts-rainbow2` plugin.

### Context-Aware Indentation

Treesitter can provide better indentation based on code structure:

```lua
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  indent = { enable = true },
})
```

## Next Steps

Now that you've mastered Treesitter syntax highlighting, the next guide will show you how to use Treesitter for code navigation.

Continue to [Code Navigation with Treesitter](04-code-navigation-with-treesitter.md).
