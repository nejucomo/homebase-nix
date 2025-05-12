lib:
let
  inherit (lib.nixpkgs)
    writeShellScriptBin
    cargo-depgraph
    graphviz
  ;

  depgraph = "${cargo-depgraph}/bin/cargo-depgraph";
  dot = "${graphviz}/bin/dot";

in writeShellScriptBin "cargo-depgraph-svg" ''
  if [ "$*" = '--help' ]
  then
    ${depgraph} depgraph --help
  else
    ${depgraph} depgraph "$@" \
      | ${dot} -Tsvg \
      > target/depgraph.svg
  fi
''
