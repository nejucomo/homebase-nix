homebase:
let
  inherit (homebase.nixpkgs) writeShellScriptBin;
  
  cargo-depgraph = "${homebase.nixpkgs.cargo-depgraph}/bin/cargo-depgraph";
  dot = "${homebase.nixpkgs.graphviz}/bin/dot";
in
  writeShellScriptBin "cargo-depgraph-svg" ''
    ${cargo-depgraph} depgraph --workspace-only --all-features \
      | sed 's/^digraph {$/\0\nrankdir="LR"/' \
      | ${dot} -Tsvg \
      > target/depgraph.svg
  ''
