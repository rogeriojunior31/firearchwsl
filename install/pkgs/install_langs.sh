#!/bin/bash

echo "Instalando python..."
mise use -g python@latest

echo "Instalando node e bun..."
mise use -g node@latest
mise use -g bun@latest

echo "instalando Rust.."
mise use -g rust@latest

echo "instalando Go..."
mise use -g go@latest
