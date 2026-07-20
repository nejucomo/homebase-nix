{
  description = "nejucomo's homebase";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.git-clone-canonical.url = "github:nejucomo/flake-git-clone-canonical";
  inputs.jj.url = "github:jj-vcs/jj";

  # inputs.cargo-checkmate.url = "github:cargo-checkmate/cargo-checkmate";
  # inputs.leftwm.url = "github:leftwm/leftwm";
  # inputs.niri.url = "github:YaLTeR/niri";
  # inputs.penumbra.url = "github:penumbra-zone/penumbra/v0.78.0";
  # inputs.radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";

  outputs = (
    inputs@{ flake-parts, ... }:

    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        imports = [
          mods/default-all-package.nix
          mods/nixpkgs-config.nix
          mods/pkgs/custom.nix
          mods/pkgs/from-flakes.nix
          mods/pkgs/from-nixpkgs-any-system.nix
          mods/pkgs/from-nixpkgs-system-specific.nix
        ];
      }
    )
  );
}
