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
        "*" = 
	  let
            layoutConfig = nLib.strings.getLayoutArgs userConfig.layout;
	  in {
            xkb_layout = layoutConfig.layout;
            xkb_variant = mkIf layoutConfig.hasVariant layoutConfig.variant;
            xkb_options = mkIf layoutConfig.hasOptions layoutConfig.options;
          };
      };
    };
  };
}
