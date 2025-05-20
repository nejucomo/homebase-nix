{ templatePackage, nixpkgs, ... }: templatePackage ./src {
  inherit (nixpkgs)
    cargo-depgraph
    graphviz
  ;
}
