{
  description = "Yannick's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; 
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          nixos-hardware.nixosModules.hardkernel-odroid-h3
          ./hosts/server/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.yannick = import ./home/default.nix;
          }
        ];
      };
    };
  };
}
