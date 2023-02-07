{ pkgs, lib, inputs, config, specialArgs, ...  }:
let
  inherit (specialArgs) system;
in {
  imports = [
    ./home-${if system.isDarwin then "darwin" else "linux"}.nix
  ];

  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      (ripgrep.override { withPCRE2 = true; })
      neovim
      wezterm

      ## Dev
      # Fennel
      fennel
      fnlfmt
    ];
  };

  programs = {
    bash = import ./programs/bash.nix pkgs;
    direnv = {
      enable = true;

      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    bat.enable = true;
    exa.enable = true;

    git = {
      enable = true;
      userName = "nouun";
      userEmail = "me@nouun.dev";
      delta.enable = true;
      ignores = [ "**/.direnv/" "**/.DS_Store" ];
      extraConfig = {
        pull.ff = "only";
        init.defaultBranch = "main";
      };
    };
  };
}
