# turing-pi-nix

This repository provides an easy way to deploy NixOS to Raspberry Pi Compute Module 4s (CM4), which serve as nodes in the Turing Pi 2 cluster. It leverages Nix flakes and the raspberry-pi-nix project to simplify the deployment process.

## Prerequisites

Before deploying, ensure your system meets the following requirements:

### Emulate aarch64

If you are compiling the Raspberry Pi image on a system that is not `aarch64`, you need to enable architecture emulation by adding the following to your NixOS configuration:

```nix
boot.binfmt.emulatedSystems = ["aarch64-linux"];
```

### Use nix-community Cachix cache

To avoid compiling the Raspberry Pi Linux kernel fork, you can use the nix-community Cachix cache. Add the following to your NixOS configuration:

```nix
nix = {
  settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://nix-community.cachix.org"];
    trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };
};
```

## Deployment

1. Clone this repository.
   ```sh
   git clone https://github.com/your-username/turing-pi-nix.git
   cd turing-pi-nix
   ```
2. Modify `configuration.nix` to suit your setup.
3. Run the deployment command.
   ```sh
   nix run . <NODE_NUMBER|NODE_RANGE|NODE_LIST> <IP_ADDRESS> <USER> <PASSWORD>
   ```
    You can choose to deploy to a single node, a range of nodes or a list of nodes according to the following formats:
    - A single number: `1`
    - A range: `1-3`
    - A comma-separated list: `1,3,4`

## Tools

This project utilizes the following tools:

- [Nix Flakes](https://wiki.nixos.org/wiki/Flakes)
- [raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)
- [flake-utils](https://github.com/numtide/flake-utils)

## License

This project is licensed under the MIT License.

## Contributing

If you have suggestions or improvements, feel free to open an issue or submit a pull request!

