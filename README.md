# dotnix-v2

Nix(OS) flakes configuration for my personal computer, supporting
`x86_64-linux` with NixOS (coming soon:tm:),
`aarch64-linux` with NixOS using [AsahiLinux](https://github.com/AsahiLinux)' kernel and bootloader, and
`aarch64-darwin` with Nix and [nix-darwin](https://gituh.com/LnL7/nix-darwin).

# Building and Instalation

# NixOS (Arm)

Follow the [nixos-apple-silicon](https://github.com/tpwrules/nixos-apple-silicon/blob/main/docs/uefi-standalone.md)
guide to NixOS. Once you have mounted NixOS and generated a base config, you can create a new nix-shell with git
and clone the repository.

    nix-shell -p git --run "git clone https://github.com/nouun/dotnix-v2 /mnt/etc/nixos"

After it has finished cloning, cd into the directory and run the following command to install NixOS with the config.

    sudo nixos-install --extra-experimental-features 'nix-command flakes --flake .#nixbook
    
This may take a while as it has to compile the kernel, but once that is completed you will be prompted for your root
password. Reboot and you should be able to login.

Once you have NixOS setup and installed, you can switch to this config by using the following command.

    sudo nixos-rebuild switch --flake .#nixbook

# MacOS

Install [Nix](https://github.com/NixOS/nix) with the following command.

    curl -L https://nixos.org/nix/install | sh

Once Nix is installed, run the following command to build the flake and switch to it. If it the first time installing
this config you may need to append `--extra-experimental-features 'nix-command flakes'` if they weren't enabled in your
previous configuration.

    nix build .#darwinConfigurations.macbook.system
    ./result/sw/bin/darwin-rebuild switch --flake .
