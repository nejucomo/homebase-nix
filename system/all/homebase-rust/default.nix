{ inputs, ... }:
{
  imports = [
    (inputs.dry-flakes.lib.mkFlakePartsModule.forCargoWorkspace {
      name = "homebase-rust";
      src = ./.;

      # Baked into the binaries via `env!` (see `homebase-nix/src/paths.rs`):
      env =
        { config, ... }:
        let
          inherit (config.packages) nix bash bashrc-dir;
        in
        {
          HOMEBASE_NIX_NIX_BIN = "${nix}/bin/nix";
          HOMEBASE_NIX_BASH_BIN = "${bash}/bin/bash";
          HOMEBASE_NIX_DEV_SHELL_BASHRC = "${bashrc-dir}/etc/bashrc-dir/nix-dev-shell-bashrc";
          # The exact nixpkgs revision this flake is pinned to, for `search`:
          HOMEBASE_NIX_NIXPKGS_REF = "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
        };
    })
  ];
}
