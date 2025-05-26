#!/bin/bash

# Check if tmux config directory exists
if [ ! -d ~/.config/tmux ]; then
  # Create tmux config directory if it doesn't exist
  mkdir -p ~/.config/tmux
  echo "Created tmux config directory at ~/.config/tmux"
elif [ "$(ls -A ~/.config/tmux)" ]; then
  echo "Directory ~/.config/tmux already exists and is not empty."
  echo "Aborting to prevent overwriting existing configuration."
  exit 1
else
  echo "Directory ~/.config/tmux exists but is empty. Creating configuration..."
fi

# Create tmux.conf file
cat > ~/.config/tmux/tmux.conf << 'EOF'
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support
set -g mouse on

# Set default terminal mode to 256color
set -g default-terminal "screen-256color"

# Enable true color support
set-option -ga terminal-overrides ",xterm-256color:Tc"

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when a window is closed
set -g renumber-windows on

# Increase scrollback buffer size
set -g history-limit 10000

# Enable vi mode for copy mode
setw -g mode-keys vi

# Faster command sequences
set -s escape-time 10

# Refresh status line every 5 seconds
set -g status-interval 5

# Focus events enabled for terminals that support them
set -g focus-events on

# Super useful when using "grouped sessions" and multi-monitor setup
setw -g aggressive-resize on

# Vim-like pane switching
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Vim-like pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Copy mode vim bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

# Copy to system clipboard (macOS)
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# Tokyo Night theme for tmux
# Default theme
set -g mode-style "fg=#7aa2f7,bg=#3b4261"
set -g message-style "fg=#7aa2f7,bg=#3b4261"
set -g message-command-style "fg=#7aa2f7,bg=#3b4261"
set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#7aa2f7"
set -g status "on"
set -g status-justify "left"
set -g status-style "fg=#7aa2f7,bg=#1f2335"

set -g status-left-length "100"
set -g status-right-length "100"
set -g status-left-style NONE
set -g status-right-style NONE
set -g status-left "#[fg=#15161e,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1f2335,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#1f2335] #{prefix_highlight} #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161e,bg=#7aa2f7,bold] #h "
setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-format "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#1f2335,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]"


bind v copy-mode
bind p paste-buffer

# Enable vi mode
setw -g mode-keys vi
# Copy mode key bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi Escape send-keys -X cancel
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line

# Mouse support in copy mode
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
# Copy to system clipboard (choose based on your system)
# WSL
 bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
# Linux (X11)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"

# Linux (Wayland)
# bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"


# Copy current pane content to file
bind-key S capture-pane -S -3000 \; save-buffer ~/tmux-buffer.txt

# Copy and search in one command
bind-key / copy-mode \; send-keys "/"

bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
EOF

echo "Tmux configuration has been created at ~/.config/tmux/tmux.conf"
echo "Make this script executable with: chmod +x tmux-setup.sh"

