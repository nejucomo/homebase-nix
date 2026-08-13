# modsInDir :: Path -> [ Path ]
#
# Recursively discovers flake-parts module files under `path`, so a
# directory tree of modules never needs to be re-listed in an `imports`
# value:
#
# - If `path` is a file, it is a module: `[ path ]`.
# - If `path` is a directory containing `default.nix`, the whole directory
#   is a single module (its other contents, e.g. non-nix template data,
#   are left alone): `[ path ]`.
# - Otherwise `path` is a directory of modules: every `*.nix` file is a
#   module, and every subdirectory is expanded by the same rules
#   (non-`.nix` files are ignored, so a module directory may hold
#   arbitrary supporting data). A directory with no `.nix` files anywhere
#   beneath it contributes nothing.
let
  inherit (builtins) readFileType readDir attrNames concatMap;

  hasNixSuffix =
    name:
    let
      len = builtins.stringLength name;
    in
    len > 4 && builtins.substring (len - 4) 4 name == ".nix";

  modsInDir =
    path:
    if readFileType path == "regular" then
      [ path ]
    else if builtins.pathExists (path + "/default.nix") then
      [ path ]
    else
      let
        entries = readDir path;
      in
      concatMap (
        name:
        if entries.${name} == "directory" || (entries.${name} == "regular" && hasNixSuffix name) then
          modsInDir (path + "/${name}")
        else
          [ ]
      ) (attrNames entries);
in
modsInDir
