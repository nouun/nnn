{ pkgs, lib, specialArgs, ... }:
let
  inherit (specialArgs) system capabilities networking;
  inherit (lib) mkIf;
in {
  networking.computerName = networking.computerName;

  system = {
    # Remap caps lock to escape
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      dock = {
        # More icons in Launchpad
        springboard-columns = 9;
        springboard-rows = 6;

        # Show app switcher on all displays
        appswitcher-all-displays = true;

        # Automatically hide the dock after half a second
        autohide = true;
        autohide-delay = 0.5;

        # Speed up animations
        autohide-time-modifier = 0.5;
        expose-animation-duration = 0.5;

        # Hide recent apps from the dock
        show-recents = true;

        # Disable Notes hot corner
        wvous-br-corner = 1;
      };

      loginwindow = {
        # Auto login to user nouun
        autoLoginUser = "nouun";

        # Disable guest account
        GuestEnabled = false;

        # Disable shutdown button if there is a user logged in
        ShutDownDisabledWhileLoggedIn = true;
        PowerOffDisabledWhileLoggedIn = true;
        RestartDisabledWhileLoggedIn = true;

        # Disable console until logged in
        DisableConsoleAccess = true;
      };

      # Disable 'Application Downloaded from Internet' popup
      LaunchServices.LSQuarantine = false;

      # Enable automatic updates
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      # Ctrl (^) + Scroll to zoom
      universalaccess.closeViewScrollWheelToggle = true;

      NSGlobalDomain = {
        # Show hidden files
        AppleShowAllFiles = true;

        # Automatic light/dark mode
        AppleInterfaceStyleSwitchesAutomatically = true;

        # Disable press and hold for accented keys
        ApplePressAndHoldEnabled = false;

        # Always show file extensions
        AppleShowAllExtensions = true;

        # Only show scroll bars when scrolling
        AppleShowScrollBars = "WhenScrolling";

        # Expand save panel by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Set Finder sidebar icons to smallest setting (1, 2, or 3)
        NSTableViewDefaultSizeMode = 1;

        # Enable tap to click
        "com.apple.mouse.tapBehavior" = 1;

        # Enable 24hr format
        AppleICUForce24HourTime = true;
      };

      finder = {
        # Show hidden files
        AppleShowAllFiles = true;

        # Show breadcrumbs
        ShowPathbar = true;

        # Set default Finder view to list view
        FXPreferredViewStyle = "Nlsv";

        # Always show file extensions
        AppleShowAllExtensions = true;

        # Hide desktop icons
        CreateDesktop = false;

        # Show full POSIX filepath in window title
        _FXShowPosixPathInTitle = true;

        # Disable extension change warning
        FXEnableExtensionChangeWarning = false;
      };
    };

    # Set default shell to bash
    activationScripts.postActivation.text = ''
      sudo chsh -s ${lib.getBin pkgs.bashInteractive}/bin/bash nouun
    '';
  };

  # Enable using Touch ID for `sudo`
  security.pam.enableSudoTouchIdAuth = mkIf capabilities.hasTouchID true;

  services.nix-daemon.enable = true;
}

