{
  description = "nejucomo's homebase";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.git-clone-canonical.url = "github:nejucomo/flake-git-clone-canonical";
  inputs.cargo-checkmate.url = "github:cargo-checkmate/cargo-checkmate";
  inputs.leftwm.url = "github:leftwm/leftwm";
  #inputs.radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
  # inputs.niri.url = "github:YaLTeR/niri";
  inputs.penumbra.url = "github:penumbra-zone/penumbra/v0.78.0";

  outputs = inputs:
    let
      system = "x86_64-linux";

      # Flakes where we install something different than "the default package" for out platform:
      nonstd-flake-pkgs = {
        nixpkgs = inputs.nixpkgs.legacyPackages."${system}";
        cargo-checkmate = inputs.cargo-checkmate.packages."${system}".unwrapped;
        penumbra = inputs.penumbra.packages."${system}".penumbra;
      };

      # Flakes where we just install the default package for our platform:
      std-flake-pkgs = (
        let
          inherit (builtins) attrNames removeAttrs mapAttrs;

          std-flakes = removeAttrs inputs (attrNames nonstd-flake-pkgs);

          select-default = _name: flake: flake.packages."${system}".default;
        in
          mapAttrs select-default std-flakes
      );

      flake-pkgs = std-flake-pkgs // nonstd-flake-pkgs;
    in {
      packages."${system}".default = import ./default.nix flake-pkgs;
    };
}
