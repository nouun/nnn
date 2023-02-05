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

      mkConfiguration = args: args.sys (rec {
        system = args.arch or "x86_64-linux";
        specialArgs = args.args;
        modules = [
          ./modules/system.nix
          (if args.arch == "aarch64-darwin"
            then home-manager.darwinModules.home-manager
            else home-manager.nixosModules.home-manager)
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nouun = import ./modules/home.nix;
              extraSpecialArgs = args.args;
            };
          }
        ];
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

      darwinConfigurations.nouun-macbook = mkConfiguration {
        sys = darwin.lib.darwinSystem;
        arch = "aarch64-darwin";
        args = {
          capabilities = {
            hasTouchID = true;
          };
        };
      };
    };
}
