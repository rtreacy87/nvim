# Customizing Telescope in Neovim

This guide covers how to customize Telescope's appearance and behavior to match your preferences and workflow needs.

## Understanding Telescope's Configuration Structure

Telescope's configuration is organized into three main sections:

1. **defaults**: Global settings that apply to all pickers
2. **pickers**: Settings for specific built-in pickers
3. **extensions**: Settings for installed extensions

Here's the basic structure:

```lua
require('telescope').setup {
  defaults = {
    -- Global settings
  },
  pickers = {
    -- Picker-specific settings
  },
  extensions = {
    -- Extension-specific settings
  }
}
```

## Configuring Appearance

### Changing the Layout

Telescope offers several built-in layouts:

```lua
require('telescope').setup {
  defaults = {
    layout_strategy = 'horizontal', -- Options: horizontal, vertical, center, cursor
    layout_config = {
      horizontal = {
        width = 0.8,
        height = 0.9,
        preview_width = 0.6,
      },
      vertical = {
        width = 0.8,
        height = 0.9,
        preview_height = 0.5,
      },
      center = {
        width = 0.6,
        height = 0.6,
      },
      cursor = {
        width = 0.4,
        height = 0.4,
      },
    },
  },
}
```

### Using Built-in Themes

Telescope comes with several built-in themes:

```lua
-- Apply globally
require('telescope').setup {
  defaults = require('telescope.themes').get_dropdown(),
}

-- Or for specific pickers
require('telescope').setup {
  pickers = {
    find_files = require('telescope.themes').get_dropdown(),
    live_grep = require('telescope.themes').get_ivy(),
  },
}
```

Available themes:
- `get_dropdown()`: Compact dropdown menu
- `get_cursor()`: Opens near the cursor
- `get_ivy()`: Bottom-aligned list

### Creating Custom Themes

You can create your own theme by defining a set of options:

```lua
local my_theme = {
  layout_strategy = 'horizontal',
  layout_config = {
    width = 0.9,
    height = 0.8,
    preview_width = 0.5,
  },
  borderchars = {
    prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
    results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
  color_devicons = true,
  winblend = 10,
}

-- Apply to a specific picker
vim.keymap.set('n', '<leader>ff', function()
  require('telescope.builtin').find_files(my_theme)
end)
```

### Customizing Colors

You can customize Telescope's colors by defining highlight groups:

```lua
-- In your colorscheme setup or init.lua
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#5e81ac" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#5e81ac" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#5e81ac" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#bf616a", bold = true })
vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = "#a3be8c", bold = true })
vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = "#ebcb8b", bold = true })
```

## Configuring Behavior

### Customizing Default Mappings

You can override Telescope's default keymaps:

```lua
require('telescope').setup {
  defaults = {
    mappings = {
      i = { -- Insert mode mappings
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-n>"] = "cycle_history_next",
        ["<C-p>"] = "cycle_history_prev",
        ["<C-c>"] = "close",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
        ["<C-f>"] = "results_scrolling_down",
        ["<C-b>"] = "results_scrolling_up",
      },
      n = { -- Normal mode mappings
        ["j"] = "move_selection_next",
        ["k"] = "move_selection_previous",
        ["gg"] = "move_to_top",
        ["G"] = "move_to_bottom",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
        ["?"] = "which_key",
      },
    },
  },
}
```

### Adjusting Sorting and Matching

You can customize how Telescope sorts and matches results:

```lua
require('telescope').setup {
  defaults = {
    -- Sorting
    sorting_strategy = "ascending", -- Options: ascending, descending
    
    -- Matching
    file_ignore_patterns = { "node_modules", "%.git/", "%.DS_Store" },
    path_display = { "truncate" }, -- Options: truncate, smart, shorten, absolute
    
    -- For fzf-native extension
    -- (install telescope-fzf-native.nvim first)
    file_sorter = require('telescope.sorters').get_fzf_sorter(),
    generic_sorter = require('telescope.sorters').get_fzf_sorter(),
  },
}
```

### Configuring File and Path Display

Control how paths are displayed in results:

```lua
require('telescope').setup {
  defaults = {
    path_display = {
      -- Options: truncate, smart, shorten, absolute, tail
      "smart",
      -- Or use a function for custom formatting
      -- function(opts, path)
      --   return path:gsub(os.getenv("HOME"), "~")
      -- end
    },
  },
}
```

### Setting Default Command-line Options

You can set default options for command-line tools like ripgrep:

```lua
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden", -- Include hidden files
      "--glob=!.git/", -- Exclude .git directory
    },
  },
}
```

## Customizing Specific Pickers

You can override settings for individual pickers:

```lua
require('telescope').setup {
  pickers = {
    find_files = {
      theme = "dropdown",
      previewer = false,
      hidden = true,
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
    },
    live_grep = {
      theme = "ivy",
      additional_args = function()
        return { "--hidden" }
      end,
    },
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      mappings = {
        i = {
          ["<c-d>"] = "delete_buffer",
        },
      },
    },
  },
}
```

## Creating Custom Keymaps with Options

You can create keymaps that include custom options:

```lua
-- Find files with hidden files included
vim.keymap.set('n', '<leader>fa', function()
  require('telescope.builtin').find_files({
    hidden = true,
    no_ignore = true,
    prompt_title = "All Files",
  })
end, { desc = 'Find all files' })

-- Live grep with case sensitivity
vim.keymap.set('n', '<leader>fs', function()
  require('telescope.builtin').live_grep({
    additional_args = function()
      return { "--case-sensitive" }
    end,
    prompt_title = "Case Sensitive Search",
  })
end, { desc = 'Case sensitive search' })
```

## Customizing Preview Behavior

Control how previews work:

```lua
require('telescope').setup {
  defaults = {
    -- Preview settings
    preview = {
      filesize_limit = 1, -- MB
      timeout = 250, -- ms
    },
    
    -- Preview highlighting
    highlight = true,
    
    -- Preview scrolling
    scroll_strategy = "cycle", -- Options: cycle, limit
  },
}
```

## Next Steps

Now that you know how to customize Telescope's appearance and behavior, the next guide will cover advanced features and extensions that can further enhance your Telescope experience.

Continue to [Advanced Telescope Features](05-advanced-telescope-features.md).
