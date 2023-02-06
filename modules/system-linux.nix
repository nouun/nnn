{ pkgs, lib, specialArgs, ... }:
let
  inherit (specialArgs) system networking;
  inherit (lib) mkIf;
in {
  imports = [
    ../hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = !system.isM1;
  };

  users = {
    mutableUsers = false;

    users.nouun = {
      hashedPassword = "$y$j9T$iUnO9xQBWOxmSbNWkR3g90$YYR2/IWGq.StYGiiQKtxgP/Yrk.vtd2U7galg.F1G5C";
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
      ];
    };
  };

  programs = {
    light.enable = true;
  };

  security.polkit.enable = true;

  services = {
    timesyncd.enable = true;
    fstrim.enable = true;

    upower.enable = true;

    xserver = {
      enable = true;

      layout = "us";
      xkbVariant = "dvorak";
      xkbOptions = "caps:escape";

      extraLayouts = with builtins;
        lib.pipe ./layouts [
          readDir
          attrNames
          (map (n: {
            name = n;
            value = {
              description = n;
              languages = [ "eng" ];
              symbolsFile = ./layouts + "/${n}";
            };
          }))
          listToAttrs
        ];
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
  };
  sound.enable = true;

  hardware = {
    asahi = mkIf system.isM1 {
      addEdgeKernelConfig = true;
      peripheralFirmwareDirectory = ./m1-firmware;

      useExperimentalGPUDriver = true;
      experimentalGPUInstallMode = "driver";
    };

    opengl.enable = true;

    bluetooth.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = "kime";
  };
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
    useXkbConfig = true;
  };

  networking = {
    useDHCP = false;
    interfaces = mkIf networking.wireless.enable
      (builtins.listToAttrs (map (v: { name = v; value = { useDHCP = true; }; }) networking.wireless.interfaces));


    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    wireless = 
      let
        home_ssids = [ "vodafoneE43B22-5" "vodafoneE43B22" "vodafoneE43B22_EXT" "vodafoneE43B22-5_EXT" ];
        home_psk = "b7d7a6f1dd0fa48a4b8f690de5672e43e103e1ca4e63eba04dc03862cc17cbb8";
     in mkIf networking.wireless.enable {
      enable = true;
      userControlled.enable = false;

      interfaces = networking.wireless.interfaces;
      networks = builtins.listToAttrs (map (v: { name = v; value = { pskRaw = home_psk; }; }) home_ssids);
    };
  };
}
