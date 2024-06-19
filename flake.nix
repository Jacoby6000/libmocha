{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    devkitNix.url = "github:Jacoby6000/devkitNix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devkitNix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devkitNix.overlays.default];
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.devkitNix.devkitPPC];
        inherit (pkgs.devkitNix.devkitPPC) shellHook;
      };
      packages.default = pkgs.stdenv.mkDerivation {
        name = "libmocha";
        src = ./.;

        preBuild = pkgs.devkitNix.devkitPPC.shellHook;

        installPhase = ''
          export DESTDIR=$out
          make install
        '';
      };
    });
}
