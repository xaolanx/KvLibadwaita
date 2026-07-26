{
  description = ''
    KvLibadwaita theme for Kvantum which repeats
    the Libadwaita design for your QT applications
    The gradience feature provides the ability
    to override the theme color scheme.
    35 presets from popular themes in
    base16 format are available to choose from
    If your favorite color scheme is not in the list,
    you can pass the path to the base16.json file
    with your favorite theme in base16 format to the builder
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          kvlibadwaita = pkgs.callPackage ./nix/kvlibadwaita.nix { };
          default = kvlibadwaita;
        };
      }
    )
    // {
      overlays = (import ./nix/overlays.nix { }) // {
        default = self.overlays.kvlibadwaita;
      };
      homeManagerModules.kvlibadwaita = import ./nix/module.nix;
      homeManagerModule = self.homeManagerModules.kvlibadwaita;
    };
}
