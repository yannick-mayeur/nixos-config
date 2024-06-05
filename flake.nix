{
  description = "Yannick's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , home-manager-unstable
    , catppuccin
    , ...
    }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
    in
    {
      nixosConfigurations = {
        "desktop-nixos" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            catppuccin.nixosModules.catppuccin
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
            })
            ./hosts/desktop/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.yannick = import [
                ./home/desktop/default.nix
                catppuccin.homeManagerModules.catppuccin
              ];
              home-manager.extraSpecialArgs = { };
            }
          ];
        };
        "server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            nixos-hardware.nixosModules.hardkernel-odroid-h3
            catppuccin.nixosModules.catppuccin
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
            })
            ./hosts/server/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.yannick = import [
                ./home/server/default.nix
                catppuccin.homeManagerModules.catppuccin
              ];
              home-manager.extraSpecialArgs = { };
            }
          ];
        };
      };

      homeConfigurations."yannickmayeur@ymacbook.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ overlay-unstable ];
          })
          ./home/work-macbook/default.nix
          catppuccin.homeManagerModules.catppuccin
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { };
      };
    };
}
