# templatePackage :: implib -> Path -> { String: ToString } -> Deriv
# templatePackage :: implib -> src -> env -> ...

{ nixpkgs, ... }:
let
  inherit (builtins)
    baseNameOf
    toJSON
    toFile
  ;

  inherit (nixpkgs)
    minijinja
  ;

  inherit (nixpkgs.stdenv)
    mkDerivation
  ;

in src: env: (
  let
    name = baseNameOf src;
    envFile = toFile "template-env-${name}" (toJson env);
  in mkDerivation {
    inherit src;
    name = "${name}";
    builder = ./templatePackage/builder.sh;
    buildInputs = [
      minijinja
      envFile
    ];
    env = env // { inherit envFile; };
  }
)

