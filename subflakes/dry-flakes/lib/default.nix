{
  self,
  nixpkgs,
  systems,
  flake-parts,
  crane,
  rust-overlay,
}@inputs:

let
  inherit (nixpkgs) lib;

  systemsDefault = import systems;
  cargoIncludes = import ./cargo-includes.nix { inherit lib; };

  mkFlakePartsModule = {
    # forCargoWorkspace :: { src, name ? "default", env ? { } } -> FlakePartsModule
    #
    # A flake-parts module which builds the cargo workspace at `src`. It is
    # meant to be imported alongside other modules, so it leaves `systems`
    # to the importer and names everything it defines after `name`:
    #
    # - `packages.<name>`: the workspace build,
    # - `checks.<name>` and `checks.<name>-clippy`,
    # - `devShells.<name>`: a shell with the toolchain and the inputs of the
    #   above checks.
    #
    # For `name = "default"` the clippy check is plain `checks.clippy`.
    #
    # `env` is a set of environment variables visible to the workspace's
    # build (so rust code may read them with `env!` / `option_env!`) and in
    # its dev shell. It is either an attrset, or a function from `perSystem`
    # module arguments to one, e.g.:
    #
    #   env = { config, ... }: { FOO_BIN = "${config.packages.foo}/bin/foo"; };
    #
    # Dependency builds don't see `env`, so changing it never rebuilds them.
    forCargoWorkspace =
      {
        src,
        name ? "default",
        env ? { },
      }:
      let
        envFn = if lib.isFunction env then env else _: env;

        perSystem =
          { system, ... }@perSystemArgs:
          let
            resolvedEnv = envFn perSystemArgs;
            suffixed = suffix: if name == "default" then suffix else "${name}-${suffix}";

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
            cleanSrc = lib.cleanSourceWith {
              src = lib.cleanSource src;
              filter = path: type: craneLib.filterCargoSources path type || cargoIncludesFilter path type;
              name = "source";
            };
            commonArgs = {
              src = cleanSrc;
              strictDeps = true;
            };
            cargoArtifacts = craneLib.buildDepsOnly commonArgs;
            workspaceArgs = commonArgs // {
              inherit cargoArtifacts;
              env = resolvedEnv;
            };
            package = craneLib.buildPackage workspaceArgs;
            checks = {
              ${name} = package;
              ${suffixed "clippy"} = craneLib.cargoClippy (
                workspaceArgs // { cargoClippyExtraArgs = "--all-targets -- --deny warnings"; }
              );
            };
          in
          {
            inherit checks;
            packages.${name} = package;
            # Only this workspace's checks: the importing flake may define
            # many unrelated ones.
            devShells.${name} = craneLib.devShell {
              inherit checks;
              env = resolvedEnv;
            };
          };
      in
      {
        # The module system passes a module function only the arguments it
        # names, so advertise those `env` names too, alongside our own.
        perSystem = lib.setFunctionArgs perSystem (lib.functionArgs perSystem // lib.functionArgs envFn);
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
      env ? { },
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;
      imports = [
        (mkFlakePartsModule.forCargoWorkspace {
          inherit env;
          src = cargoWorkspace;
        })
      ];
    };
}
