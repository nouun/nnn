{ pkgs, lib, specialArgs, ... }:
{
  systemd.user.serivces.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi''
    };
  };
}
