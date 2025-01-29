{
  description = "raspberry-pi-nix example";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = {
    self,
    nixpkgs,
    raspberry-pi-nix,
  }: let
    nixosConfigurations = {
      rpi-example = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            raspberry-pi-nix.nixosModules.sd-image
            ./configuration.nix
        ];
      };
    };
  in {
    images.rpi-example = nixosConfigurations.rpi-example.config.system.build.sdImage;

    packages.x86_64-linux = {
      turing-pi-nix = nixpkgs.legacyPackages.x86_64-linux.callPackage ./src { };
      default = self.packages.x86_64-linux.turing-pi-nix;
    };
  };
}
