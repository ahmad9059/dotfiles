#!/bin/bash

# Session name
SESSION_NAME="neovim"

# Check if the tmux session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
    # If the session doesn't exist, create a new one and run Neovim
    kitty --class nvim-tmux tmux new-session -s $SESSION_NAME -d
    tmux send-keys -t $SESSION_NAME 'nvim' C-m
fi
# Attach to the tmux session in a kitty window with a unique class
kitty --class nvim-tmux tmux attach-session -t $SESSION_NAME

