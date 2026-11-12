{
  inputs.dry-flakes.url = "github:nejucomo/dry-flakes";

  outputs =
    inputs:
    inputs.dry-flakes.lib.mkFlakeOutputs {
      cargoWorkspace = ./.;

      # FIXME: incorporate into rust build:
      # env = {
      #   HOMEBASE_NIX_NIX_BIN = "${config.packages.nix}/bin/nix";
      #   HOMEBASE_NIX_BASH_BIN = "${pkgs.bashInteractive}/bin/bash";
      #   HOMEBASE_NIX_DEV_SHELL_BASHRC = "${config.packages.bashrc-dir}/etc/bashrc-dir/nix-dev-shell-bashrc";
      #   # The exact nixpkgs revision this flake is pinned to, for `search`:
      #   HOMEBASE_NIX_NIXPKGS_REF = "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
      # };
    };
}
