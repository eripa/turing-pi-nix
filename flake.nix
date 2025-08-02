{
  description = "raspberry-pi-nix example";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      raspberry-pi-nix,
      flake-utils,
    }:
    let
      nixosConfigurations = {
        rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            raspberry-pi-nix.nixosModules.sd-image
            ./configuration.nix
          ];
        };
      };
    in
    {
      rpi-sd-image = nixosConfigurations.rpi.config.system.build.sdImage;
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      packages = rec {
        turing-pi-nix = nixpkgs.legacyPackages.${system}.callPackage ./src { };
        default = self.packages.${system}.turing-pi-nix;
      };
    });
}
