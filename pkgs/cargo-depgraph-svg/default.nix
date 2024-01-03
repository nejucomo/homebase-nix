homebase:
let
  inherit (homebase.nixpkgs) writeShellScriptBin;
  
  cargo-depgraph = "${homebase.nixpkgs.cargo-depgraph}/bin/cargo-depgraph depgraph";
  dot = "${homebase.nixpkgs.graphviz}/bin/dot";
in
  writeShellScriptBin "cargo-depgraph-svg" ''
    if [ "$*" = '--help' ]
    then
      ${cargo-depgraph} --help
    else
      ${cargo-depgraph} "$@" \
        | sed 's/^digraph {$/\0\nrankdir="LR"/' \
        | ${dot} -Tsvg \
        > target/depgraph.svg
    fi
  ''
