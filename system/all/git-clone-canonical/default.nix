# This is the wrapper script (adds `--update-hack-links`), not the raw
# upstream flake package - it owns the `git-clone-canonical` name here,
# matching the old merged-profile precedence where the wrapper's
# bin/git-clone-canonical shadowed upstream's. See system/all/git-user-hooks
# for the other consumer of the raw upstream package.
{
  perSystem =
    { config, inputs', templatePackage, ... }:
    {
      packages.git-clone-canonical = templatePackage ./git-clone-canonical "bin" {
        inherit (config.packages) bash-postlude set-symlink;
        git-clone-canonical = inputs'.git-clone-canonical.packages.default;
      };
    };
}
