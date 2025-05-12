{ package-bash-scripts, stdenvNoCC }:
let
  wrapped-pkg = package-bash-scripts ./scripts;
in
  # Ref: https://msfjarvis.dev/posts/writing-your-own-nix-flake-checks/
  stdenvNoCC.mkDerivation {
    name = "bash-scripts";
    buildInputs = [ wrapped-pkg ];
    src = ./.;

    # Forward `wrapped-pkg` to the output:
    buildPhase = ''
      mkdir "$out"
      cp -av '${wrapped-pkg.out}'/* "$out"
    '';

    # Checks:
    doCheck = true;
    checkPhase = ''
      selftest='${wrapped-pkg}/bin/postlude-bash-test'
      ls -l "$selftest"
      exec "$selftest"
    '';
  }
