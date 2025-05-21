syslib:
syslib.templatePackage ./src {
  inherit (syslib.basePkgs.nix)
    cargo-depgraph
    graphviz
  ;
}
