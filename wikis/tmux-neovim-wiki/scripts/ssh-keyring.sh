#!/bin/bash

# Function to append the SSH agent code to the appropriate shell config file
append_to_shell_config() {
    # Determine which shell config file to use
    if [ -f "$HOME/.zshrc" ] && [ "$SHELL" = "$(which zsh)" ]; then
        CONFIG_FILE="$HOME/.zshrc"
        SHELL_NAME="zsh"
    else
        CONFIG_FILE="$HOME/.bashrc"
        SHELL_NAME="bash"
    fi
    
    # Check if the code is already in the config file
    if grep -q "start_ssh_agent" "$CONFIG_FILE"; then
        echo "SSH agent code already exists in $CONFIG_FILE"
        return
    fi
    
    # Append the code to the config file
    cat >> "$CONFIG_FILE" << 'EOF'

# SSH Agent Configuration
start_ssh_agent() {
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
        # Kill any existing ssh-agent processes
        pkill -u "$USER" ssh-agent 2>/dev/null
        
        # Start new ssh-agent
        eval "$(ssh-agent -t 8h -s)" > /dev/null
        
        # Add key if it exists
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
            ssh-add -t 8h "$HOME/.ssh/id_ed25519" 2>/dev/null
        fi
    fi
}

if [ -n "$TMUX" ]; then
    # In tmux, try to use the forwarded agent first
    tmux_auth_sock=$(tmux show-environment 2>/dev/null | grep "^SSH_AUTH_SOCK=" | cut -d= -f2-)
    if [ -n "$tmux_auth_sock" ] && [ -S "$tmux_auth_sock" ]; then
        export SSH_AUTH_SOCK="$tmux_auth_sock"
    fi
    
    # Test if the agent is working, if not start a new one
    if ! ssh-add -l >/dev/null 2>&1; then
        start_ssh_agent
        # Update tmux environment with new agent
        tmux set-environment SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
    fi
else
    # Not in tmux, use regular logic
    start_ssh_agent
fi

export PASSWORD_STORE_ENABLE_GIT=true
export PATH="$HOME/bin:$PATH"
EOF

    echo "SSH agent configuration added to $SHELL_NAME configuration ($CONFIG_FILE)"
    echo "Please restart your shell or run 'source $CONFIG_FILE' to apply changes"
}

# Run the function
append_to_shell_config

