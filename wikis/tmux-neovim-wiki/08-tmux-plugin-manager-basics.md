# Tmux Plugin Manager (TPM) Guide

This guide covers the basics of using the Tmux Plugin Manager (TPM) to extend and enhance your tmux experience with plugins.

## What is TPM?

Tmux Plugin Manager (TPM) is a package manager for tmux, similar to what vim-plug or Packer is for Vim/Neovim. It allows you to:

- Install tmux plugins with a simple command
- Update plugins easily
- Configure plugins through your tmux.conf
- Remove plugins you no longer need

## Installation

### 1. Clone the TPM repository

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 2. Add TPM to your tmux configuration

Add these lines to your `~/.config/tmux/tmux.conf`:

```bash
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

### 3. Reload tmux configuration

If tmux is already running, reload the configuration:

```bash
tmux source ~/.config/tmux/tmux.conf
```

## Basic Usage

### Adding Plugins

To add a plugin, include it in your tmux.conf with the `@plugin` directive:

```bash
set -g @plugin 'github-username/plugin-name'
```

Common examples:
```bash
set -g @plugin 'tmux-plugins/tmux-resurrect'    # Session saving and restoration
set -g @plugin 'tmux-plugins/tmux-continuum'    # Continuous saving of tmux environment
set -g @plugin 'tmux-plugins/tmux-yank'         # Copy to system clipboard
set -g @plugin 'janoamaral/tokyo-night-tmux'    # Tokyo Night theme
```

### Installing Plugins

After adding plugins to your configuration:

1. Reload your tmux configuration: `tmux source ~/.config/tmux/tmux.conf`
2. Press `prefix + I` (capital I) to install the plugins

You'll see a status message when installation completes.

### Updating Plugins

To update all plugins:

1. Press `prefix + U` (capital U)

Alternatively, you can update from the command line:

```bash
~/.tmux/plugins/tpm/bin/update_plugins all
```

### Removing Plugins

1. Remove the plugin line from your tmux.conf
2. Press `prefix + alt + u` to remove the plugin

## Popular Plugins

### Essential Plugins

- **tmux-sensible**: Sensible default settings that should be acceptable to everyone
- **tmux-resurrect**: Save and restore tmux sessions across system restarts
- **tmux-continuum**: Automatic saving and restoration of tmux environment

### Usability Enhancements

- **tmux-yank**: Copy to system clipboard
- **tmux-open**: Open highlighted selection with appropriate program
- **tmux-pain-control**: Better pane management

### Appearance

- **tokyo-night-tmux**: Tokyo Night theme for tmux
- **tmux-power**: Powerline-like theme
- **tmux-themepack**: A collection of themes

## Plugin Configuration

Many plugins accept configuration options. Add these before the plugin initialization line:

```bash
# Example: Configure tmux-resurrect to restore Neovim sessions
set -g @resurrect-strategy-nvim 'session'

# Example: Configure tmux-continuum to restore on boot
set -g @continuum-restore 'on'
```

Check each plugin's documentation for specific configuration options.

## Troubleshooting

### Plugins Not Installing

If `prefix + I` doesn't work:

1. Make sure TPM is properly installed at `~/.tmux/plugins/tpm`
2. Ensure the TPM initialization line is at the bottom of your tmux.conf
3. Try installing manually: `~/.tmux/plugins/tpm/bin/install_plugins`

### Plugin Not Working

If a plugin installs but doesn't work:

1. Check if it has dependencies (like `xclip` for tmux-yank on Linux)
2. Look for error messages when starting tmux with `tmux -v`
3. Verify your tmux version meets the plugin's requirements

### SSH Key Request with Every Shell

If you're prompted for an SSH key passphrase every time you open a new shell, it's not related to TPM. This is a general SSH configuration issue. You can resolve it by:

```bash
# Start SSH agent automatically
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check if ssh-agent is already running
   ps -aux | grep ssh-agent | grep -v grep > /dev/null
   if [ $? -ne 0 ]; then
      eval "$(ssh-agent -s)" > /dev/null
   fi
fi

# Add your SSH key to the agent automatically
if [ -f "$HOME/.ssh/id_ed25519" ]; then
   ssh-add -l | grep "$HOME/.ssh/id_ed25519" > /dev/null
   if [ $? -ne 0 ]; then
      ssh-add $HOME/.ssh/id_ed25519 2>/dev/null
   fi
fi

export PASSWORD_STORE_ENABLE_GIT=true
export PATH="$HOME/bin:$PATH"
```

This can be corrected by adding a timer to the SSH agent and key addition. Then the key will only need to be entered once every 8 hours (or whatever time you set).

```bash
# Start SSH agent automatically
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check if ssh-agent is already running
   ps -aux | grep ssh-agent | grep -v grep > /dev/null
   if [ $? -ne 0 ]; then
      eval "$(ssh-agent -t 8h -s)" > /dev/null
   fi
fi

# Add your SSH key to the agent automatically
if [ -f "$HOME/.ssh/id_ed25519" ]; then
   ssh-add -l | grep "$HOME/.ssh/id_ed25519" > /dev/null
   if [ $? -ne 0 ]; then
      ssh-add -t 8h $HOME/.ssh/id_ed25519 2>/dev/null
   fi
fi

export PASSWORD_STORE_ENABLE_GIT=true
export PATH="$HOME/bin:$PATH"
```


## Advanced Usage

### Custom Plugin Locations

You can install plugins in a custom directory by setting the `TMUX_PLUGIN_MANAGER_PATH` variable:

```bash
set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.local/share/tmux/plugins/'
```

### Local Plugins

You can use local plugins by providing a full path:

```bash
set -g @plugin '/path/to/local/plugin'
```

## Conclusion

TPM makes managing tmux plugins simple and efficient. With the basics covered in this guide, you can now extend your tmux setup with useful plugins that enhance your workflow.

For more information, visit the [official TPM repository](https://github.com/tmux-plugins/tpm).

## Related Wiki Pages

- [Setting Up Tmux and Neovim](02-setting-up-tmux-and-neovim.md)
- [Troubleshooting and Optimization](07-troubleshooting-and-optimization.md)


