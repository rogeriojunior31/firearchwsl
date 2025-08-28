#!/bin/bash

mkdir -o ~/.config

# Create firewarchwsl in .local
mkdir -o ~/.local/share/firearchwsl
mkdir -o ~/.local/share/firearchwsl/config

mkdir -o ~/.local/share/firearchwsl/default

# Copy firewarchwsl configs
cp -R ../config_files/ ~/.local/share/firearchwsl/config/

# Use default fish from FireArchWsl
mkdir -o ~/.config/fish
cp ~/.local/share/firearchwsl/default/config.fish ~/.config/fish

# Use default bashrc from FireArchWsl
cp ~./local/share/firewarchwsl/default/bashrc ~/.bashrc
