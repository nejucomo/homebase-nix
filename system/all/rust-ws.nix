# Builds the crates of the `rust-ws` cargo workspace.
{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    let
      inherit (pkgs) lib;

      wsRoot = ../../rust-ws;

      src = lib.fileset.toSource {
        root = wsRoot;
        fileset = lib.fileset.unions [
          (wsRoot + "/Cargo.toml")
          (wsRoot + "/Cargo.lock")
          (wsRoot + "/homebase-nix")
        ];
      };
    in
    {
      packages.homebase-nix = pkgs.rustPlatform.buildRustPackage {
        pname = "homebase-nix";
        version = "0.1.0";
        inherit src;
        cargoLock.lockFile = wsRoot + "/Cargo.lock";
        cargoBuildFlags = [ "--package=homebase-nix" ];
        cargoTestFlags = [ "--package=homebase-nix" ];

        # Baked into the binary at compile time via `option_env!`:
        env = {
          HOMEBASE_NIX_NIX_BIN = "${config.packages.nix}/bin/nix";
          HOMEBASE_NIX_BASH_BIN = "${pkgs.bashInteractive}/bin/bash";
          HOMEBASE_NIX_DEV_SHELL_BASHRC = "${config.packages.bashrc-dir}/etc/bashrc-dir/nix-dev-shell-bashrc";
          # The exact nixpkgs revision this flake is pinned to, for `search`:
          HOMEBASE_NIX_NIXPKGS_REF = "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
        };

        meta.mainProgram = "homebase-nix";
      };
    };
}
