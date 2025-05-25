# Introduction to Tmux-Neovim Integration

This guide introduces the powerful combination of tmux and Neovim, explaining why this integration is valuable and how it can transform your development workflow.

## What is Tmux?

Tmux (terminal multiplexer) is a program that allows you to create and manage multiple terminal sessions within a single terminal window. Think of it as a window manager for your terminal.

### Core Tmux Concepts

**Sessions**: A collection of windows and panes that persist even when you disconnect
```bash
# Create a new session
tmux new-session -s development

# List sessions
tmux list-sessions

# Attach to a session
tmux attach-session -t development
```

**Windows**: Like tabs in a browser, each containing one or more panes
```bash
# Create a new window
tmux new-window -n "editor"

# Switch between windows
tmux select-window -t 0
```

**Panes**: Split sections within a window for running different processes
```bash
# Split horizontally
tmux split-window -h

# Split vertically
tmux split-window -v
```

## Why Integrate Tmux with Neovim?

### 1. Seamless Code Execution

Send code directly from your editor to a running interpreter or compiler:

```python
# In Neovim, select this code and send to Python REPL
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
```

### 2. Persistent Development Environment

Your entire development setup survives:
- Terminal disconnections
- System reboots (with proper configuration)
- Switching between projects
- Remote development sessions

### 3. Efficient Screen Real Estate

Organize your workspace with purpose:
```
┌─────────────────┬─────────────────┐
│                 │                 │
│    Neovim       │   Test Output   │
│    Editor       │                 │
│                 │                 │
├─────────────────┼─────────────────┤
│                 │                 │
│   REPL/Shell    │   Logs/Monitor  │
│                 │                 │
└─────────────────┴─────────────────┘
```

### 4. Terminal Output Management

Navigate and manipulate terminal output like text:
- Use vim motions to scroll through logs
- Copy specific error messages
- Search through command history
- Save output to files for analysis

## Integration Methods Overview

### vim-slime: The Classic Choice

**Pros:**
- Mature and stable
- Works with any terminal multiplexer
- Simple configuration
- Language agnostic

**Cons:**
- Basic feature set
- Manual target configuration
- No built-in REPL management

```lua
-- Basic vim-slime configuration
vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
  socket_name = "default",
  target_pane = "{last}"
}
```

### iron.nvim: Modern REPL Integration

**Pros:**
- Language-specific REPL support
- Automatic REPL management
- Rich feature set
- Active development

**Cons:**
- More complex setup
- Language-specific configuration
- Heavier resource usage

```lua
-- iron.nvim basic setup
require('iron.core').setup({
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = {"python3"},
        format = require("iron.fts.common").bracketed_paste,
      }
    },
  },
})
```

### neoterm: Lightweight Terminal Management

**Pros:**
- Simple and lightweight
- Good terminal management
- Easy configuration
- Fast startup

**Cons:**
- Limited REPL features
- Basic functionality
- Less active development

```lua
-- neoterm configuration
vim.g.neoterm_default_mod = 'vertical'
vim.g.neoterm_autoinsert = 1
vim.g.neoterm_autoscroll = 1
```

## Common Use Cases

### Data Science Workflow

1. **Exploratory Analysis**: Send code snippets to Python/R REPL
2. **Visualization**: View plots in separate pane
3. **Documentation**: Keep notes in another Neovim buffer
4. **Results**: Capture and save important output

### Web Development

1. **Code Editing**: Main Neovim window
2. **Server Logs**: Monitor application output
3. **Testing**: Run tests in dedicated pane
4. **Database**: Interactive database sessions

### System Administration

1. **Script Development**: Write and test scripts
2. **Log Monitoring**: Watch system logs
3. **Command Execution**: Run administrative commands
4. **Documentation**: Keep runbooks and notes

### Debugging Workflow

1. **Code Editor**: Main development window
2. **Debugger**: Interactive debugging session
3. **Logs**: Application and system logs
4. **Tests**: Automated test execution

## Benefits of Integration

### Productivity Gains

- **Reduced Context Switching**: Everything in one interface
- **Faster Feedback Loops**: Immediate code execution
- **Persistent State**: Never lose your work environment
- **Customizable Layouts**: Optimize for your workflow

### Learning and Experimentation

- **Interactive Development**: Test ideas immediately
- **Documentation**: Keep examples and notes together
- **Exploration**: Easy experimentation with new tools
- **Sharing**: Reproducible development environments

### Professional Development

- **Remote Work**: Consistent environment anywhere
- **Pair Programming**: Shared terminal sessions
- **Teaching**: Demonstrate concepts interactively
- **Presentations**: Live coding demonstrations

## What You'll Learn

By the end of this series, you'll be able to:

1. **Set up** a complete tmux-Neovim development environment
2. **Send code** from Neovim to terminal using multiple methods
3. **Navigate** terminal output using vim motions
4. **Capture** and analyze terminal output in files
5. **Create** custom workflows for your specific needs
6. **Troubleshoot** common integration issues
7. **Optimize** your setup for maximum productivity

## Next Steps

Ready to get started? The next guide will walk you through installing and configuring both tmux and Neovim to create the foundation for integration.

Continue to [Setting Up Tmux and Neovim](02-setting-up-tmux-and-neovim.md).
