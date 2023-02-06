{ pkgs, lib, inputs, config, specialArgs, ...  }:
let
  inherit (specialArgs) system;
in {
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

  wayland.windowManager.sway = {
    enable = true;
    
    config = rec {
      modifier = "Mod4";
      terminal = "wezterm";
      startup = [
        { command = "wezterm"; }
      ];
      input = {
        "*" = {
          xkb_layout = "us";
          xkb_variant = "dvorak";
          xkb_options = "caps:escape";
        };
      };
    };
  };

  # Symlinks don't work with finder and spotlight so they need to be copied instead.
  disabledModules =
    if system.isDarwin
      then [ "targets/darwin/linkapps.nix" ]
      else [];

  home.activation = lib.mkIf system.isDarwin {
    copyApplications =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        baseDir="$HOME/Applications/Home Manager Apps"
        if [ -d "$baseDir" ]; then
          rm -rf "$baseDir"
        fi
        mkdir -p "$baseDir"
        if [[ -d "${apps}/Applications/*" ]]; then
          for appFile in ${apps}/Applications/*; do
            target="$baseDir/$(basename "$appFile")"
            $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
            $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
          done
        fi
      '';
  };
}
