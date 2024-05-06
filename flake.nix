{
  description = "Yannick's NixOS Flake";

inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; 

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable"; 

    harpoon = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
  };

  outputs = {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      home-manager,
      home-manager-unstable,
      harpoon,
      ...
  }@inputs: {
    nixosConfigurations = {
      "desktop-nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/desktop/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.yannick = import ./home/desktop/default.nix;
            home-manager.extraSpecialArgs = { inherit harpoon; };
          }
        ];
      };
      "server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          nixos-hardware.nixosModules.hardkernel-odroid-h3
          ./hosts/server/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.yannick = import ./home/server/default.nix;
            home-manager.extraSpecialArgs = { inherit harpoon; };
          }
        ];
      };
    };

    homeConfigurations."yannickmayeur@ymacbook.local" = home-manager-unstable.lib.homeManagerConfiguration {
      pkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [ ./home/work-macbook/default.nix ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
      extraSpecialArgs = { inherit harpoon; };
    };
  };
}
