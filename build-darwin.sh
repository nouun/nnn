#!/bin/sh

nix build ".#darwinConfigurations.macbook.system" --show-trace
./result/sw/bin/darwin-rebuild switch --flake ".#macbook"
