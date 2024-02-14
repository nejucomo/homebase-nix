{ nixpkgs, pname, version }:
let
  homebase = rec {
    # New API:
    define-user-environment = base-pkgs: specs:
      let
        resolve-dependencies = imp ./resolve-dependencies.nix;
        resolved = resolve-dependencies base-pkgs specs;
        inherit (resolved) user-environment;
        inherit (builtins) attrValues;
        inherit (nixpkgs) symlinkJoin;
      in
        symlinkJoin {
          name = "${homebase.pname}-${homebase.version}";
          paths = attrValues user-environment;
        };

    override-bin = upstream-bin: mk-script: (
      let
        inherit (builtins) baseNameOf;
        inherit (nixpkgs) runCommand symlinkJoin writeShellScriptBin;

        script-name = baseNameOf upstream-bin;
        pkg-name = "override-${script-name}";

        wrapped-bin = writeShellScriptBin script-name (mk-script upstream-bin);

        linked-bin = runCommand "${pkg-name}-override-link" {} ''
          mkdir -vp "$out/bin"
          ln -s '${upstream-bin}' "$out/bin/overridden-${script-name}"
        '';
      in
        symlinkJoin {
          name = pkg-name;
          paths = [ wrapped-bin linked-bin ];
        }
    );

    # Old API:
    # TODO: cleanup
    inherit nixpkgs pname version;

    ## Name a sub-package
    sub-pname = subname: "${pname}-${subname}";

    ## Import the argument, passing in the closure of homebase:
    imp = mod-path: import mod-path homebase;

    ## Include extras for the given pacakges, such as man pages:
    include-extras = pkgs:
      let
        inherit (nixpkgs.lib.lists) flatten;

        include-optional-man =  pkg:
          if pkg ? man
          then [pkg pkg.man]
          else [pkg];
      in
        flatten (map include-optional-man pkgs);

    ## Wrap binaries from an underlying package:
    wrap-bins = imp ./wrap-bins.nix;

    ## Wrap binaries specialized with specific config args:
    wrap-configs = pkg: configs:
      let
        inherit (nixpkgs.lib.attrsets) mapAttrs;

        wrap-config = name: config-args: { upstream-pkg, upstream-bin }: ''
          #!/bin/sh
          exec '${upstream-bin}' ${config-args} "$@"
        '';
      in
        homebase.wrap-bins pkg (mapAttrs wrap-config configs);

    ## wrap-config-pkgs :: upstream-pkgs -> config-attrset -> pkgs-attrset
    ##
    ## Wrap configs of an attrset where each name is for a package with
    ## a single identical binary. The result is an attrset where each
    ## value is the `wrap-config` derivations.
    wrap-config-pkgs = upstream-pkgs:
      let
        inherit (nixpkgs.lib.attrsets) mapAttrs;

        wrap-config-pkg = name: config-args:
          wrap-configs upstream-pkgs."${name}" { "${name}" = config-args; };
      in
        mapAttrs wrap-config-pkg;

    ## wrap-xdg-config :: xdg-name -> xdg-config-dir -> upstream-bins -> deriv
    wrap-xdg-config = imp ./wrap-xdg-config.nix;

    ## copy-to-prefix :: src-path -> prefix -> derivation
    ##
    ## Copy src to a specific out prefix.
    copy-to-prefix = src: prefix:
      let
        inherit (builtins) baseNameOf replaceStrings;
        basename = baseNameOf src;
        prefix_ = replaceStrings ["/"] ["_"] prefix;
      in
        nixpkgs.stdenv.mkDerivation {
          name = "copy-${basename}-to-${prefix_}";
          inherit src;

          installPhase = ''
            set -x
            dest="$out/${prefix}"
            mkdir -p "$dest"
            cp -a "$src"/* "$dest"
            set +x
          '';
        };
  };
in
  homebase
