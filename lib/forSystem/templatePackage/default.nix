# templatePackage :: syslib -> Path -> { String: ToString } -> Deriv
# templatePackage :: syslib -> src -> env -> ...

syslib:
let
  inherit (builtins)
    baseNameOf
    toJSON
    toFile
  ;

  nixpkgs = syslib.basePkgs.nix;

  inherit (nixpkgs.stdenv)
    mkDerivation
  ;

in src: reldst: env: (
  let
    inherit (builtins) trace replaceStrings;
    inherit (syslib.attrsets) mapAttrs' nameValuePair;
    name = baseNameOf src;
    escapeNameHyphens = n: nameValuePair (replaceStrings ["-"] ["_"] n);
    templateParams = mapAttrs' escapeNameHyphens env;

  in trace "building template package: ${name}" mkDerivation {
    inherit name src;
    builder = ./builder.sh;
    buildInputs = with nixpkgs; [
      jq
      minijinja
    ];
    env = env // {
      inherit reldst;
      "HOMEBASE_TEMPLATE_JSON" = toJSON templateParams;
    };
  }
)

