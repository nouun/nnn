{ pkgs, lib, inputs, config, specialArgs, ... }:
let
  inherit (specialArgs) system networking;
  inherit (lib) mkIf;
in {
  networking.hostName = networking.hostName;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # TODO: This seems to work on nix-darwin but not NixOS. Do I mkIf system.isDarwin or is there something else that could be done?
    # nixPath = lib.mapAttrs (key: value: "${key}=${value.to.path}") config.nix.registry;

    gc = {
      automatic = true;
    };

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      sandbox = true;
    };

    extraOptions = ''
      warn-dirty = false
    '' + (if system.isDarwin then ''
      build-users-group = nixbld
    '' else ''
    '');
  };

  system.stateVersion = if system.isDarwin then 4 else "23.05";
}
