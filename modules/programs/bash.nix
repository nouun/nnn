pkgs: {
  enable = true;
  enableCompletion = true;

  shellAliases = {
    ".." = "cd ..";
    ls = "ls -liah";
  };

  initExtra = ''
    #> Syntax: bash

    function run() {
      nix run nixpkgs#$1
    }

    search() {
      nix search "''${@:-nixpkgs}" ".*" |
        grep "^\* " | sed "s/^\* //;s/ (.*//" |
        sed -r "s/\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?m//g" |
        ${pkgs.fzf}/bin/fzf --preview="nix search nixpkgs '^{}$'"
    }

    function updatePrompt() {
      dir=$(pwd | sed "s|$HOME|~|g")

      startDir=$dir
      trim=$(echo $dir | sed -e "s|^/||g")
      if [ $(echo $trim | sed -e "s|/| |g" | wc -w) -ge 3 ]; then
        trim=$(echo $trim | rg -o "s|(/[^/]*){2}$||g")
        trim=$(echo $trim | awk '{gsub(/^[ \n]+|[ \n]+$/, "")} { print $0 }')
        dir="..$trim"
      fi

      if [[ "$(cut -c2- <<< "$startDir")" == "$(cut -c3- <<< "$dir")" ]]; then
        dir="$startDir"
      fi

      PS1="$dir | "
    }

    updatePrompt

    function cd() {
      command cd $@; updatePrompt
    }

    function cdc() {
      cd $@ && clear
    }

    mmv() {
      if [ "$#" -ne 2 ]; then
        echo "Usage: mmv <search> <replacement>" >&2;
      else
        for FILE in *$1*; do
          mv -v "$FILE" '$(echo "$FILE" | sed -e "s/$1/$2/" - )';
        done
      fi;
    }

    alias cat=bat

    # Setup direnv
    eval "$(${pkgs.direnv}/bin/direnv hook bash)"
  '';
}
