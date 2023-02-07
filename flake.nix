{
  description = "NNN - Nouun's New Nix (environment)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, ... }:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      nLib = import ./lib { inherit lib; pkgs = nixpkgs; };

      userConfig = rec {
        layout = "us(dvorak);caps:escape";
      };

      mkConfiguration = args: args.sys (let
	config = args.conf // { userConfig = userConfig; };
	systemName = if config.system.isDarwin then "darwin" else "linux";
	hmSystemName = (if config.system.isDarwin then "darwin" else "nixos") + "Modules";
      in rec {
        system = args.arch or "x86_64-linux";
        specialArgs = { inherit inputs nLib; } // config;
        modules = [
          ./modules/system.nix
          ./modules/system-${systemName}.nix
	  home-manager.${hmSystemName}.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nouun = import ./modules/home.nix;
              extraSpecialArgs = { inherit nLib; } // config;
            };
          }
        ] ++
        (if config.system.isLinux && config.system.isM1
          then [inputs.nixos-apple-silicon.nixosModules.default]
          else []);
      });

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    rec {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      darwinConfigurations.nixbook = mkConfiguration {
        sys = darwin.lib.darwinSystem;
        arch = "aarch64-darwin";
        conf = {
          capabilities = {
            hasTouchID = true;
          };
          system = {
            isDarwin = true;
            isLinux = false;
            isM1 = true;
          };
          networking = {
            hostName = "nixbook";
            computerName = "Nouuns NixBook";
          };
        };
      };

      nixosConfigurations.nixbook = mkConfiguration {
        sys = nixpkgs.lib.nixosSystem;
        arch = "aarch64-darwin";
        conf = {
          capabilities = {
            hasTouchID = true;
          };
          system = {
            isDarwin = false;
            isLinux = true;
            isM1 = true;
          };
          networking = {
            hostName = "nixbook";
            computerName = "Nouuns NixBook";

            wireless = {
              enable = true;

              interfaces = [
                "wlp1s0f0"
              ];
            };
          };
        };
      };
    };
}
