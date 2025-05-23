# Basic Telescope Usage in Neovim

This guide covers the fundamental usage patterns of Telescope, focusing on the most common built-in pickers and how to effectively navigate and interact with them.

## Launching Telescope

There are two main ways to launch Telescope pickers:

### 1. Using Commands

Telescope provides commands for all built-in pickers:

```
:Telescope find_files
:Telescope live_grep
:Telescope buffers
```

You can also pass options directly:

```
:Telescope find_files hidden=true no_ignore=true
```

### 2. Using Keymaps

If you've set up keymaps as suggested in the previous guide, you can use them to quickly access pickers:

```
<leader>ff - Find files
<leader>fg - Live grep (search text)
<leader>fb - Buffers
```

## Common Built-in Pickers

### File Pickers

#### find_files

Searches for files in your current working directory:

```
:Telescope find_files
```

**Tips:**
- Type to filter files by name
- Use space to separate multiple search terms
- Results update in real-time as you type

#### oldfiles

Shows recently opened files:

```
:Telescope oldfiles
```

**Tips:**
- Great for quickly returning to files you were working on
- Persists across Neovim sessions

### Text Search Pickers

#### live_grep

Searches for text patterns across all files:

```
:Telescope live_grep
```

**Tips:**
- Uses ripgrep under the hood for fast searching
- Supports regex patterns
- Updates results as you type

#### grep_string

Searches for the word under the cursor:

```
:Telescope grep_string
```

**Tips:**
- Quick way to find all occurrences of a symbol
- Can be mapped to a key for instant searching

### Buffer Pickers

#### buffers

Lists and filters open buffers:

```
:Telescope buffers
```

**Tips:**
- Quickly switch between open files
- Preview buffer content before switching
- Delete buffers directly from the picker

### Help and Documentation

#### help_tags

Searches Neovim's help documentation:

```
:Telescope help_tags
```

**Tips:**
- Great for learning Neovim features
- Much faster than navigating help manually
- Shows preview of help content

#### man_pages

Searches system manual pages:

```
:Telescope man_pages
```

### Git Integration

#### git_files

Lists files tracked by git:

```
:Telescope git_files
```

**Tips:**
- Faster than find_files in git repositories
- Only shows tracked files

#### git_commits

Browses git commit history:

```
:Telescope git_commits
```

**Tips:**
- Preview commit changes
- Checkout commits directly

#### git_status

Shows files with git status changes:

```
:Telescope git_status
```

**Tips:**
- Quickly find modified files
- Preview changes before opening

## Navigation and Interaction

### Basic Navigation

Within any Telescope picker:

| Key | Action |
|-----|--------|
| `j` or `Down` | Move selection down |
| `k` or `Up` | Move selection up |
| `H` | Move to top of list |
| `M` | Move to middle of list |
| `L` | Move to bottom of list |
| `Ctrl-u` | Scroll preview up |
| `Ctrl-d` | Scroll preview down |

### Selection Actions

| Key | Action |
|-----|--------|
| `Enter` | Confirm selection (open file, etc.) |
| `Ctrl-x` | Open in horizontal split |
| `Ctrl-v` | Open in vertical split |
| `Ctrl-t` | Open in new tab |
| `Ctrl-q` | Send all items to quickfix list |
| `Tab` | Toggle selection (for multi-select) |

### Filter and Search

| Key | Action |
|-----|--------|
| Type text | Filter results |
| `Backspace` | Delete character in filter |
| `Ctrl-n`/`Ctrl-p` | Cycle through search history |
| `Ctrl-c` or `Esc` | Close Telescope |

### Getting Help

To see all available keymaps in any picker:

- In insert mode: `Ctrl-/`
- In normal mode: `?`

This will display a help window with all available actions.

## Searching and Filtering Techniques

### Smart Case Sensitivity

Telescope is smart about case sensitivity:

- Lowercase query: case-insensitive search
- Any uppercase letter: case-sensitive search

### Multiple Search Terms

Separate terms with spaces to search for multiple patterns:

```
main function
```

This will find items containing both "main" and "function".

### Excluding Terms

Prefix a term with `-` to exclude it:

```
test -spec
```

This will find items containing "test" but not "spec".

### Using Regex

Many pickers support regex patterns:

```
^function.*end$
```

This would find lines starting with "function" and ending with "end".

## Working with Results

### Multi-selection

You can select multiple items:

1. Navigate to an item
2. Press `Tab` to select it
3. Navigate to another item
4. Press `Tab` again
5. Press `Enter` to confirm all selections

This works great with the quickfix list (`Ctrl-q`).

The quickfix list in Neovim is a powerful feature that stores a collection of locations (files and positions) that you can navigate through. Here's what you need to know:

1. **Purpose**: It's designed to help you work through a list of locations, like search results, compiler errors, or linting warnings.

2. **How Telescope uses it**: When you press `Ctrl-q` in Telescope, it sends all your current search results to the quickfix list, allowing you to:
   - Keep those results available after closing Telescope
   - Navigate through them systematically
   - Perform batch operations on them

3. **Basic quickfix commands**:
   - `:copen` - Open the quickfix window
   - `:cnext` or `:cn` - Go to next item
   - `:cprev` or `:cp` - Go to previous item
   - `:cclose` - Close the quickfix window

4. **Common workflow**:
   - Search for something in Telescope (e.g., `:Telescope live_grep`)
   - Press `Ctrl-q` to send results to quickfix
   - Close Telescope
   - Use `:cn` and `:cp` to jump between matches
   - Or open quickfix window with `:copen` to see all matches

This is especially useful for tasks like refactoring, where you need to make similar changes across multiple files.

The quickfix list is a built-in feature of Neovim and doesn't require any additional plugins. It's a core functionality that comes with Neovim/Vim out of the box.

When you use Telescope's `Ctrl-q` command, it's simply interfacing with this native Neovim feature. The quickfix list has been part of Vim for decades and is available in any standard Neovim installation.

You can use all the quickfix commands (`:copen`, `:cnext`, `:cprev`, etc.) immediately without installing anything extra. Telescope just provides a convenient way to populate this list with search results.



### Sending to Quickfix List

To send results to the quickfix list:

1. Search for what you need
2. Press `Ctrl-q` to send all results to quickfix
3. Or select specific items with `Tab` first, then `Ctrl-q`

### Opening in Splits/Tabs

Instead of just opening a file, you can:

- `Ctrl-x`: Open in horizontal split
- `Ctrl-v`: Open in vertical split
- `Ctrl-t`: Open in new tab

## Next Steps

Now that you understand the basics of using Telescope, the next guide will cover how to customize its appearance and behavior to better suit your workflow.

Continue to [Customizing Telescope](04-customizing-telescope.md).
