# Configure the `pkgs` argument given to every `perSystem` module.
#
# `claude-code` is unfree; without this, evaluating it throws. This mirrors
# the `unfreePackages` allowlist `lib/default.nix` used to pass through to
# `nixpkgs`.
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "claude-code" ];
      };
    };
}
