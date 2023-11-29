{
  description = "nejucomo's homebase";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.git-clone-canonical.url = "github:nejucomo/flake-git-clone-canonical";

  outputs = { self, nixpkgs, git-clone-canonical }:
    let
      system = "x86_64-linux";
    in {
      packages."${system}".default = import ./default.nix {
        git-clone-canonical = git-clone-canonical.packages."${system}".default;
        nixpkgs = nixpkgs.legacyPackages."${system}";
      };
    };
}
