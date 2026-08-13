{
  perSystem =
    { config, inputs', templatePackage, ... }:
    {
      packages.git-user-hooks = templatePackage ./git-user-hooks "lib/git-user-hooks" {
        inherit (config.packages) bash-postlude set-symlink;
        git-clone-canonical = inputs'.git-clone-canonical.packages.default;
      };
    };
}
