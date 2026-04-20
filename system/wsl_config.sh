#!/bin/bash

# libedit ABI shim — alguns bins (ex: OpenGL stack) procuram libedit.so.2
if [[ -e /usr/lib/libedit.so ]]; then
  ln -sf /usr/lib/libedit.so /usr/lib/libedit.so.2
else
  printf '\e[1;33m[WARN]\e[0m %s\n' "/usr/lib/libedit.so ausente — pulando shim libedit.so.2"
fi
