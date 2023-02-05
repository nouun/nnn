{ pkgs
, lib
, inputs
, config
, ...
}: {
  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      (ripgrep.override { withPCRE2 = true; })
      neovim

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

  # symlinks don't work with finder + spotlight, copy them instead
  disabledModules = [ "targets/darwin/linkapps.nix" ];
  home.activation = lib.mkIf pkgs.stdenv.isDarwin {
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
