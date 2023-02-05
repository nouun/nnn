{ pkgs, lib, inputs, config, specialArgs, ... }:
let
  inherit (specialArgs) withGUI capabilities;
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in {
  security.pam.enableSudoTouchIdAuth = mkIf capabilities.hasTouchID true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ] ++ (if isLinux then [pkgs.firefox] else []);

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrs (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      sandbox = true;
    };
    extraOptions = ''
      warn-dirty = false
    '' + (if isDarwin then ''
      build-users-group = nixbld
    '' else ''
    '');
  };

  programs.bash.enable = true;

  users.users.nouun = mkIf isLinux {
    name = "nouun";
    home = "/home/nouun";
    shell = pkgs.bashInteractive;
  };

  system.activationScripts.postActivation.text = mkIf isDarwin ''
    sudo chsh -s ${lib.getBin pkgs.bashInteractive}/bin/bash nouun
  '';

  services.nix-daemon.enable = true;
  system.stateVersion = 4;
}
