# Terminal Navigation with Vim Motions

This guide shows you how to navigate terminal output using familiar vim motions, making terminal interaction as efficient as text editing.

## Tmux Copy Mode Fundamentals

Tmux copy mode allows you to navigate terminal output using vim-like motions, search through history, and copy text.

### Entering Copy Mode

```bash
# Default key binding
Ctrl-a [

# Or add a more convenient binding to ~/.tmux.conf
bind v copy-mode
```

### Basic Navigation

Once in copy mode, use familiar vim motions:

```bash
# Movement
h, j, k, l          # Character and line movement
w, b, e             # Word movement
0, $                # Beginning and end of line
gg, G               # Top and bottom of buffer
Ctrl-u, Ctrl-d      # Half page up/down
Ctrl-b, Ctrl-f      # Full page up/down

# Search
/pattern            # Search forward
?pattern            # Search backward
n                   # Next search result
N                   # Previous search result

# Exit copy mode
q                   # Quit copy mode
Escape              # Also quits copy mode
```

## Advanced Copy Mode Configuration

### Enhanced Vim-like Copy Mode

Add this comprehensive configuration to `~/.config/tmux/tmux.conf`:

```bash
# Enable vi mode
setw -g mode-keys vi

# Copy mode key bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi Escape send-keys -X cancel
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line
```

#### Detailed Explanation of Selected tmux Configuration Commands

##### Setting Vi Mode

```bash
#### Enable vi mode
setw -g mode-keys vi
```

This command sets tmux's copy mode to use vi-style key bindings instead of the default emacs-style. `setw` is short for `set-window-option`, and `-g` makes this setting global across all windows. This is the foundation that enables all the vim-like navigation and selection commands.

##### Copy Mode Key Bindings

```bash
#### Copy mode key bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
```
- This binds the `v` key in copy mode to start text selection, similar to Vim's visual mode
- When you press `v` in copy mode, you can then move the cursor to select text
- `-T copy-mode-vi` specifies this binding applies only in copy mode with vi keys
- `send-keys -X begin-selection` is the tmux command that initiates selection

```bash
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
```
- This binds `Ctrl-v` to toggle block/rectangular selection mode
- Similar to Vim's visual block mode, this lets you select columns of text
- Perfect for selecting text in columns or tables in terminal output
- You can press `C-v` again to toggle back to normal selection

```bash
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
```
- This binds `y` to copy the selected text and exit copy mode
- Just like in Vim where `y` "yanks" (copies) text
- The selected text is placed in tmux's paste buffer
- `-and-cancel` part automatically exits copy mode after copying

```bash
bind-key -T copy-mode-vi Escape send-keys -X cancel
```
- This binds `Escape` to cancel selection and exit copy mode
- Provides a way to abort a selection without copying anything
- Matches Vim behavior where `Escape` exits the current mode

```bash
bind-key -T copy-mode-vi H send-keys -X start-of-line
```
- This binds `H` (capital H) to move to the start of the current line
- Provides a quick way to jump to the beginning of a line
- Similar to Vim's `0` command but easier to reach

```bash
bind-key -T copy-mode-vi L send-keys -X end-of-line
```
- This binds `L` (capital L) to move to the end of the current line
- Provides a quick way to jump to the end of a line
- Similar to Vim's `$` command but easier to reach

##### Example Workflow with Python Output

Imagine you're reviewing Python error output in a terminal:

1. Enter copy mode with `Ctrl-a [`
2. Navigate to the start of the error message using `/Error`
3. Press `v` to start selection
4. Use `j` to extend selection down through the traceback
5. Press `y` to copy the selection
6. Switch to your editor and paste to analyze the error

Or to select a column of numbers from command output:

1. Enter copy mode
2. Navigate to the first number
3. Press `C-v` to start block selection
4. Move down with `j` to select the entire column
5. Press `y` to copy just that column of data
6. Paste into a Python script for analysis

These bindings create a seamless, Vim-like experience when working with terminal output, making complex text selection tasks much more efficient.



```bash
# Mouse support in copy mode
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel

# Copy to system clipboard (choose based on your system)
# macOS
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Linux (X11)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"

# Linux (Wayland)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

# WSL
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
```

### Quick Copy Mode Access

```bash
# Add to ~/.tmux.conf for easier access
bind v copy-mode
bind p paste-buffer

# Copy current pane content to file
bind-key S capture-pane -S -3000 \; save-buffer ~/tmux-buffer.txt \; display-message "Buffer saved to ~/tmux-buffer.txt"

# Copy and search in one command
bind-key / copy-mode \; send-keys "/"
```

#### How These Commands Differ from Standard Copy Mode

1. **`bind v copy-mode`**
   - This creates a single-key shortcut (`v`) to enter copy mode
   - Standard method requires pressing `Ctrl-a [` (two keys)
   - Makes entering copy mode faster and more intuitive for Vim users
   - Mnemonic: "v" for visual selection, matching Vim's visual mode

2. **`bind p paste-buffer`**
   - Creates a single-key shortcut (`p`) to paste the copied content
   - Standard method requires `Ctrl-a ]` (two keys)
   - Matches Vim's paste command for muscle memory consistency
   - Mnemonic: "p" for paste, just like in Vim

3. **`bind-key S capture-pane -S -3000 \; save-buffer ~/tmux-buffer.txt`**
   - This is a powerful command that:
     - Captures up to 3000 lines of scrollback history
     - Saves it directly to a file without manual selection
     - Provides visual feedback with a message
   - Standard copy mode would require manually selecting all content
   - Perfect for quickly saving terminal output for later analysis
   - Mnemonic: "S" for Save (capital to avoid conflicts)

4. **`bind-key / copy-mode \; send-keys "/"`**
   - Combines two operations in one keystroke:
     - Enters copy mode
     - Immediately starts a search
   - Standard method requires entering copy mode first, then pressing `/`
   - Streamlines the common workflow of searching terminal history
   - Mnemonic: "/" matches the search command itself

#### Practical Example

When debugging a Python application:

1. Run your Python script and see an error in the output
2. Press `/` to immediately enter copy mode and search
3. Type "Error" and press Enter to find the error message
4. Navigate and select the relevant parts with `v` and movement keys
5. Press `y` to copy the selection
6. Press `p` to paste it elsewhere or use `S` to save all output to a file

These shortcuts save keystrokes and streamline common terminal workflows, making you more efficient when working with command output.

The typical workflow would be:

1. **Capture terminal output** to the default location (`~/tmux-buffer.txt`) using the `S` binding
2. **Process or review** that captured information as needed
3. **Preserve the information** by either:
   - Renaming the file (e.g., `mv ~/tmux-buffer.txt ~/debug-session-20230601.txt`)
   - Copying it to another location (e.g., `cp ~/tmux-buffer.txt ~/project/logs/debug-output.txt`)
   - Moving the content to a more permanent document
4. **Capture new output** with the `S` binding again, which will create a fresh `~/tmux-buffer.txt`

This approach gives you a quick way to save terminal output without having to think about filenames each time, while still allowing you to preserve important information by moving/renaming files afterward.

For more sophisticated workflows, you might:
- Use the `A` binding to append to specific files
- Create timestamped files automatically
- Set up project-specific capture locations

But the basic pattern is exactly as you described - capture to a standard location, then move/rename as needed to preserve the information.

#### Purpose of `\;` in tmux Configuration

In the command:
```bash
bind-key S capture-pane -S -3000 \; save-buffer ~/tmux-buffer.txt \; display-message "Buffer saved to ~/tmux-buffer.txt"
```

The `\;` is used to:

1. **Chain multiple commands**: This binding executes three separate tmux commands in sequence:
   - `capture-pane -S -3000` (capture 3000 lines of history)
   - `save-buffer ~/tmux-buffer.txt` (save the captured content to a file)
   - `display-message "..."` (show a confirmation message)

2. **Escape the semicolon**: The backslash `\` is needed to escape the semicolon `;` so that your shell doesn't interpret it as its own command separator. Without the backslash, the shell would try to execute only the first part as a tmux command.

#### Highlighting Issues

The weird text highlighting you experienced could be due to:

1. **Syntax highlighting in your editor**: Some editors might not correctly recognize the `\;` syntax in tmux configuration files, causing incorrect highlighting.

2. **Quoting issues**: If you're using a different type of quotes than in the example (e.g., smart quotes instead of straight quotes), it could cause syntax highlighting problems.

3. **Line continuation**: Sometimes line breaks or spaces around the `\;` can cause highlighting issues.

#### Solutions

1. **Verify exact syntax**: Make sure you're using exactly `\;` with no space between the backslash and semicolon.

2. **Try alternative syntax**: tmux also supports a different syntax for command chaining:
   ```bash
   bind-key S run-shell "tmux capture-pane -S -3000 && tmux save-buffer ~/tmux-buffer.txt && tmux display-message 'Buffer saved to ~/tmux-buffer.txt'"
   ```

3. **Check file type**: Ensure your editor recognizes the file as a tmux configuration file for proper syntax highlighting.

4. **Simplify for testing**: Try adding just one command first, then gradually add the others to identify which part causes the issue.



## Text Selection Techniques

### Visual Selection

```bash
# In copy mode:
v                   # Start visual selection (character mode)
V                   # Start visual line selection
Ctrl-v              # Start visual block selection

# Extend selection
hjkl                # Extend character by character
w, b, e             # Extend by word
0, $                # Extend to line boundaries
gg, G               # Extend to buffer boundaries

# Copy selection
y                   # Copy and exit copy mode
Enter               # Copy and exit copy mode (default)
```

### Quick Selection Patterns

```bash
# Select entire lines
V                   # Start line selection
5j                  # Select 5 lines down
y                   # Copy

# Select words
w                   # Move to next word
v                   # Start selection
e                   # Extend to end of word
y                   # Copy

# Select paragraphs
{                   # Move to paragraph start
v                   # Start selection
}                   # Extend to paragraph end
y                   # Copy
```

## Searching Terminal Output

### Basic Search Operations

```bash
# Forward search
/error              # Search for "error"
/ERROR              # Search for "ERROR" (case sensitive)
/\cerror            # Case insensitive search

# Backward search
?warning            # Search backward for "warning"

# Navigate search results
n                   # Next match
N                   # Previous match
```

### Advanced Search Patterns

```bash
# Regular expressions
/[0-9]+             # Search for numbers
/\d{4}-\d{2}-\d{2}  # Search for dates (YYYY-MM-DD)
/ERROR\|WARN        # Search for ERROR or WARN
/^Failed            # Search for lines starting with "Failed"
/timeout$           # Search for lines ending with "timeout"

# Case insensitive search
/(?i)error          # Case insensitive "error"
```

### Search and Copy Workflow

```bash
# Common workflow:
1. Ctrl-a [         # Enter copy mode
2. /ERROR           # Search for errors
3. n                # Navigate to next error
4. v                # Start selection
5. $                # Select to end of line
6. y                # Copy and exit

# Or select the entire error context:
1. /ERROR           # Find error
2. {                # Go to paragraph start
3. v                # Start selection
4. }                # Select to paragraph end
5. y                # Copy
```

## Practical Navigation Workflows

### Log Analysis Workflow

```bash
# 1. Enter copy mode and go to bottom
Ctrl-a [
G

# 2. Search for recent errors
?ERROR

# 3. Navigate through errors
N                   # Previous error
n                   # Next error

# 4. Copy error context
{                   # Start of paragraph
v                   # Start selection
}                   # End of paragraph
y                   # Copy

# 5. Paste in Neovim for analysis
# Switch to Neovim pane and paste
```

### Command Output Review

```bash
# After running a long command:
# 1. Review output from the beginning
Ctrl-a [
gg

# 2. Search for specific patterns
/SUCCESS
/FAILED
/WARNING

# 3. Copy important sections
# Use visual selection to copy relevant parts
```

### Debugging Session Navigation

```bash
# Navigate through stack traces:
# 1. Find the error
/Traceback
/Exception
/Error

# 2. Select the entire stack trace
v                   # Start selection
/^[^ ]              # Find next non-indented line (end of trace)
k                   # Go back one line
y                   # Copy

# 3. Or select specific frames
/at .*\.py          # Find Python files in trace
v                   # Start selection
$                   # Select to end of line
y                   # Copy
```

## Integration with Neovim

### Seamless Pane Navigation

Add to your Neovim configuration for seamless navigation:

```lua
-- Smart pane navigation (works with tmux)
local function navigate_pane(direction)
  local directions = {
    h = "left",
    j = "down", 
    k = "up",
    l = "right"
  }
  
  -- Try to move within Neovim first
  local current_win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. direction)
  
  -- If we didn't move, try tmux
  if current_win == vim.api.nvim_get_current_win() then
    os.execute("tmux select-pane -" .. string.upper(direction))
  end
end

-- Key mappings
vim.keymap.set("n", "<C-h>", function() navigate_pane("h") end)
vim.keymap.set("n", "<C-j>", function() navigate_pane("j") end)
vim.keymap.set("n", "<C-k>", function() navigate_pane("k") end)
vim.keymap.set("n", "<C-l>", function() navigate_pane("l") end)

-- Also work in terminal mode
vim.keymap.set("t", "<C-h>", function() navigate_pane("h") end)
vim.keymap.set("t", "<C-j>", function() navigate_pane("j") end)
vim.keymap.set("t", "<C-k>", function() navigate_pane("k") end)
vim.keymap.set("t", "<C-l>", function() navigate_pane("l") end)
```

### Quick Terminal Access

```lua
-- Quick terminal operations from Neovim
vim.keymap.set("n", "<leader>tc", function()
  os.execute("tmux send-keys -t {last} C-c")
end, { desc = "Cancel command in terminal" })

vim.keymap.set("n", "<leader>tC", function()
  os.execute("tmux send-keys -t {last} 'clear' Enter")
end, { desc = "Clear terminal" })

vim.keymap.set("n", "<leader>ty", function()
  os.execute("tmux copy-mode -t {last}")
end, { desc = "Enter copy mode in terminal" })
```

## Advanced Copy Mode Features

### Custom Copy Mode Commands

Add to `~/.tmux.conf`:

```bash
# Custom copy mode bindings
bind-key -T copy-mode-vi 'C-h' send-keys -X start-of-line
bind-key -T copy-mode-vi 'C-l' send-keys -X end-of-line
bind-key -T copy-mode-vi 'C-j' send-keys -X scroll-down
bind-key -T copy-mode-vi 'C-k' send-keys -X scroll-up

# Select entire pane content
bind-key -T copy-mode-vi 'A' send-keys -X select-all

# Jump to specific line number
bind-key -T copy-mode-vi 'g' command-prompt -p "Go to line:" "send-keys -X goto-line %%"

# Search and select
bind-key -T copy-mode-vi 's' command-prompt -p "Search and select:" "send-keys -X search-forward %%"
```

### Buffer Management

```bash
# Multiple buffer support
bind-key b list-buffers
bind-key B choose-buffer
bind-key x delete-buffer

# Save buffer to file with timestamp
bind-key S command-prompt -p "Save buffer to:" "capture-pane -S -3000 \; save-buffer %%"

# Append to existing file
bind-key A command-prompt -p "Append buffer to:" "capture-pane -S -3000 \; save-buffer -a %%"
```

## Troubleshooting Navigation Issues

### Common Problems and Solutions

**Copy mode not working:**
```bash
# Check if vi mode is enabled
tmux show-options -g mode-keys
# Should show: mode-keys vi

# If not, add to ~/.tmux.conf:
setw -g mode-keys vi
```

**Search not working:**
```bash
# Ensure you're in copy mode first
# Press Ctrl-a [ before searching
```

**Can't copy to system clipboard:**
```bash
# Check if clipboard utility is installed
# macOS: pbcopy should be available
# Linux: install xclip or wl-copy
# WSL: clip.exe should be available

# Test manually:
echo "test" | pbcopy  # macOS
echo "test" | xclip -selection clipboard  # Linux X11
echo "test" | wl-copy  # Linux Wayland
echo "test" | clip.exe  # WSL
```

**Navigation feels slow:**
```bash
# Reduce escape time in ~/.tmux.conf:
set -s escape-time 0

# Increase repeat time for navigation:
set -g repeat-time 1000
```

## Next Steps

Now that you can efficiently navigate terminal output, learn how to capture and manage that output in files for further analysis.

Continue to [Capturing and Managing Terminal Output](05-capturing-and-managing-terminal-output.md).
