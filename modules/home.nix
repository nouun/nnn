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

    fzf = {
      enable = true;

      enableBashIntegration = true;
    # colors
    # fg	Text
    # bg	Background
    # preview-fg	Preview window text
    # preview-bg	Preview window background
    # hl	Highlighted substrings
    # fg+	Text (current line)
    # bg+	Background (current line)
    # gutter	Gutter on the left (defaults to bg+)
    # hl+	Highlighted substrings (current line)
    # info	Info
    # border	Border of the preview window and horizontal separators (--border)
    # prompt	Prompt
    # pointer	Pointer to the current line
    # marker	Multi-select marker
    # spinner	Streaming input indicator
    # header	Header
    };

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
