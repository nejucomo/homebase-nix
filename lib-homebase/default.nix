{ nixpkgs, pname, version }:
let
  homebase = rec {
    inherit nixpkgs pname version;

    ## Name a sub-package
    sub-pname = subname: "${pname}-${subname}";

    ## Import the argument, passing in the closure of homebase:
    imp = mod-path: import mod-path homebase;

    ## Legacy custom-pkgs importer (to be deprecated):
    legacy-custom-pkgs = imp ./custom-pkgs;

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
  };
in
  homebase
