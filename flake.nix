{
  description = "nejucomo's homebase";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.git-clone-canonical.url = "github:nejucomo/flake-git-clone-canonical";
  inputs.cargo-checkmate.url = "github:cargo-checkmate/cargo-checkmate";
  inputs.leftwm.url = "github:leftwm/leftwm";

  outputs = { self, nixpkgs, git-clone-canonical, cargo-checkmate, leftwm }:
    let
      system = "x86_64-linux";
    in {
      packages."${system}".default = import ./default.nix {
        nixpkgs = nixpkgs.legacyPackages."${system}";
        git-clone-canonical = git-clone-canonical.packages."${system}".default;
        cargo-checkmate = cargo-checkmate.packages."${system}".unwrapped;
        leftwm = leftwm.packages."${system}".default;
      };
    };
}
