{
  description = "nejucomo's homebase";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in {
      packages."${system}".default = import ./default.nix {
        nixpkgs = nixpkgs.legacyPackages."${system}";
      };
    };
}
