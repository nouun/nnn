{ pkgs ? (import ../nixpkgs.nix) {}
, lib ? pkgs.lib }:
let
  importLib = (file: import file { lib = lib; });
in {
  strings = importLib ./strings.nix;
}
