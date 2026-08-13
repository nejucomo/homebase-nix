{
  description = "nejucomo's homebase";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.git-clone-canonical.url = "github:nejucomo/flake-git-clone-canonical";

  # inputs.jj.url = "github:jj-vcs/jj";
  # inputs.cargo-checkmate.url = "github:cargo-checkmate/cargo-checkmate";
  # inputs.leftwm.url = "github:leftwm/leftwm";
  # inputs.niri.url = "github:YaLTeR/niri";
  # inputs.penumbra.url = "github:penumbra-zone/penumbra/v0.78.0";
  # inputs.radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";

  outputs = (
    inputs@{ flake-parts, ... }:
    let
      modsInDir = import ./_lib/modsInDir;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = modsInDir ./config ++ modsInDir ./system;
    }
  );
}
