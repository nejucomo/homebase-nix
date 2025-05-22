syslib: deps@{
  cargo-depgraph,
  graphviz
}:

syslib.templatePackage ./src deps
