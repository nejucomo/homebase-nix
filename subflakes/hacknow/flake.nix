{
  inputs.dry-flakes.url = "github:nejucomo/dry-flakes";

  outputs =
    inputs:
    let
      inherit (inputs.dry-flakes.inputs.nixpkgs) lib;

      base = inputs.dry-flakes.lib.mkFlakeOutputs { cargoWorkspace = ./.; };

      # dry-flakes uses `craneLib.cleanCargoSource`, which drops every non-cargo file
      # (e.g. `*.hacknow-template`, `flake.nix`) from `templates/`. Those files are
      # embedded via `include_dir!`, so the final package needs the full `templates/` tree.
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./Cargo.toml
          ./Cargo.lock
          ./rust-toolchain.toml
          ./src
          ./templates
        ];
      };

      withTemplates = drv: drv.overrideAttrs { inherit src; };

      fixDefault = lib.mapAttrs (_: outs: outs // { default = withTemplates outs.default; });
    in
    base
    // {
      packages = fixDefault base.packages;
      checks = fixDefault base.checks;
    };
}
