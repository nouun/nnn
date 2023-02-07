{ ...  }:
{
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
}
