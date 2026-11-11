# System-specific extra `nixpkgs` selections.
{
  perSystem =
    { lib, pkgs, system, ... }:
    lib.mkIf (system == "aarch64-darwin") {
      packages = {
        inherit (pkgs) libiconv;
      };
    };
}
