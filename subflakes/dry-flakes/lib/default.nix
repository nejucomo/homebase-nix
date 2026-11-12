{
  self,
  nixpkgs,
  systems,
  flake-parts,
  crane,
  rust-overlay,
}@inputs:

let
  systemsDefault = import systems;
  cargoIncludes = import ./cargo-includes.nix { inherit (nixpkgs) lib; };

  mkFlakePartsModule = {
    forCargoWorkspace = { systems, src }: {
      inherit systems;

      perSystem =
        { self', system, ... }:
        let
          pkgsWithRust = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          toolchain =
            (pkgsWithRust.rust-bin.fromRustupToolchainFile (src + "/rust-toolchain.toml")).override
              {
                extensions = [
                  "clippy"
                  "rust-analyzer"
                  "rust-src"
                  "rustfmt"
                ];
              };
          craneLib = (crane.mkLib pkgsWithRust).overrideToolchain toolchain;
          # Like `craneLib.cleanCargoSource`, but also keep any paths listed
          # in a workspace crate's `package.include`.
          cargoIncludesFilter = cargoIncludes.mkFilter src;
          cleanSrc = nixpkgs.lib.cleanSourceWith {
            src = nixpkgs.lib.cleanSource src;
            filter = path: type: craneLib.filterCargoSources path type || cargoIncludesFilter path type;
            name = "source";
          };
          commonArgs = {
            src = cleanSrc;
            strictDeps = true;
          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
          package = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
        in
        {
          packages.default = package;
          devShells.default = craneLib.devShell {
            checks = self'.checks;
          };
          checks = {
            default = package;
            clippy = craneLib.cargoClippy (
              commonArgs
              // {
                inherit cargoArtifacts;
                cargoClippyExtraArgs = "--all-targets -- --deny warnings";
              }
            );
          };
        };
    };
  };

in
# lib interface:
{
  inherit mkFlakePartsModule;

  mkFlakeOutputs =
    {
      cargoWorkspace,
      systems ? systemsDefault,
    }:
    (flake-parts.lib.mkFlake { inputs = inputs; } {
      imports = [
        (mkFlakePartsModule.forCargoWorkspace {
          inherit systems;
          src = cargoWorkspace;
        })
      ];
    });
}
