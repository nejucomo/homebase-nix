{
  perSystem =
    { templatePackage, ... }:
    {
      packages.bash-postlude = templatePackage ./bash-postlude "lib" { };
    };
}
