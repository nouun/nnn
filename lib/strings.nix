{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib }:
{
  getLayoutArgs = (layout:
    with builtins;
    let reg = match ''^([a-z]*)(\(([^;]*)\))?(;(.*))?$'' layout;
    in rec {
      layout = elemAt reg 0;

      variant = (elemAt reg 2);
      hasVariant = variant != null;

      options = (elemAt reg 4);
      hasOptions = options != null;
    })
}
