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

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      mkConfiguration = args: args.sys (let
        a = true;
      in rec {
        system = args.arch or "x86_64-linux";
        specialArgs = { inherit inputs; } // args.conf;
        modules = [
         ./modules/system.nix
         ./modules/system-${if args.conf.system.isDarwin then "darwin" else "linux"}.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nouun = import ./modules/home.nix;
              extraSpecialArgs = args.conf;
            };
          }
        ] ++
        (if args.conf.system.isLinux
          then ([
           ./modules/system-linux.nix
           home-manager.nixosModules.home-manager
          ] ++
           (if args.conf.system.isM1
             then [inputs.nixos-apple-silicon.nixosModules.default]
             else []))
          else [
           ./modules/system-darwin.nix
           home-manager.darwinModules.home-manager
          ]);
      });
    in
    rec {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      darwinConfigurations.macbook = mkConfiguration {
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
            hostName = "macbook";
            computerName = "Nouun's MacBook";
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
            computerName = "Nouun's NixBook";

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
