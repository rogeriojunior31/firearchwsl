#!/bin/bash

mkdir ~/.config

# Create firewarchwsl in .local
mkdir ~/.local/share/firearchwsl
mkdir ~/.local/share/firearchwsl/config

mkdir ~/.local/share/firearchwsl/default

# Copy firewarchwsl configs
cp -R ../config_files/ ~/.local/share/firearchwsl/config/

# Use default fish from FireArchWsl
mkdir ~/.config/fish
cp ~/.local/share/firearchwsl/default/config.fish ~/.config/fish

# Use default bashrc from FireArchWsl
cp ~./local/share/firewarchwsl/default/bashrc ~/.bashrc
