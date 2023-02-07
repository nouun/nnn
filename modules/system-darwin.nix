{ pkgs, lib, specialArgs, ... }:
let
  inherit (specialArgs) system capabilities networking;
  inherit (lib) mkIf;
in {
  networking.computerName = networking.computerName;

  system.activationScripts.postActivation.text = ''
    sudo chsh -s ${lib.getBin pkgs.bashInteractive}/bin/bash nouun
  '';

  security.pam.enableSudoTouchIdAuth = mkIf capabilities.hasTouchID true;

  services.nix-daemon.enable = true;
}
