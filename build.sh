#!/bin/sh

nix build ".#darwinConfigurations.nouun-macbook.system" --show-trace
./result/sw/bin/darwin-rebuild switch --flake ".#nouun-macbook"
