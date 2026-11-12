# Derive a nix source filter from the `package.include` lists of every crate
# in a cargo workspace, so that non-rust files a crate needs at build time
# (e.g. via `include_str!` / `include_dir!`) survive source cleaning without
# repeating that information in nix.
#
# `include` entries are gitignore-style globs relative to the crate root:
# - a pattern containing a non-trailing `/` is anchored at the crate root,
#   otherwise it matches at any depth,
# - a trailing `/` matches only directories (and thus their contents),
# - `*`, `?`, `**` and `[...]` behave as globs,
# - a leading `!` negates, and the last matching pattern wins.
{ lib }:

let
  inherit (builtins)
    elem
    fromTOML
    match
    pathExists
    readDir
    readFile
    replaceStrings
    ;

  # `replaceStrings` tries patterns in order at each position, so `**/` and
  # `**` take precedence over `*`.
  globToRegex = replaceStrings
    [ "**/" "**" "*" "?" "." "+" "(" ")" "{" "}" "^" "$" "|" "\\" ]
    [ "(.*/)?" ".*" "[^/]*" "[^/]" "\\." "\\+" "\\(" "\\)" "\\{" "\\}" "\\^" "\\$" "\\|" "\\\\" ];

  hasGlobChars = s: match ".*[*?[].*" s != null;

  joinRel = dir: name: if dir == "" then name else "${dir}/${name}";

  subPath = root: rel: if rel == "" then root else root + "/${rel}";

  readManifest = dir: fromTOML (readFile (dir + "/Cargo.toml"));

  compilePattern =
    pattern:
    let
      negated = lib.hasPrefix "!" pattern;
      unnegated = lib.removePrefix "!" pattern;
      dirOnly = lib.hasSuffix "/" unnegated;
      trimmed = lib.removeSuffix "/" unnegated;
      anchored = lib.hasInfix "/" trimmed;
      body = lib.removePrefix "/" trimmed;
    in
    {
      inherit negated;
      regex =
        (if anchored then "" else "(.*/)?") + globToRegex body + (if dirOnly then "/.*" else "(/.*)?");
    };

  matchesPatterns =
    compiled: relPath:
    lib.foldl' (acc: c: if match c.regex relPath != null then !c.negated else acc) false compiled;

  # Expand a workspace `members` entry (which may contain globs) into the
  # list of matching directories, relative to `root`.
  expandMemberGlob =
    root: glob:
    let
      components = lib.filter (c: c != "" && c != ".") (lib.splitString "/" glob);
      step =
        dirs: component:
        lib.concatMap (
          dir:
          if hasGlobChars component then
            let
              entries = readDir (subPath root dir);
              regex = globToRegex component;
            in
            map (name: joinRel dir name) (
              lib.filter (name: entries.${name} == "directory" && match regex name != null) (
                lib.attrNames entries
              )
            )
          else
            lib.optional (pathExists (subPath root (joinRel dir component))) (joinRel dir component)
        ) dirs;
    in
    lib.foldl' step [ "" ] components;

  # Relative paths ("" for the root) of every crate in the workspace at `root`.
  workspaceCrates =
    root:
    let
      manifest = readManifest root;
      workspace = manifest.workspace or { };
      excluded = map (lib.removeSuffix "/") (workspace.exclude or [ ]);
      members = lib.concatMap (expandMemberGlob root) (workspace.members or [ ]);
      rootCrate = lib.optional (manifest ? package) "";
    in
    lib.filter (crate: !(elem crate excluded) && pathExists (subPath root crate + "/Cargo.toml")) (
      lib.unique (rootCrate ++ members)
    );

in
{
  # A `cleanSourceWith`-style filter accepting exactly those paths under
  # `root` which some workspace crate lists in its `package.include`.
  mkFilter =
    root:
    let
      rootStr = toString root;
      entries = lib.filter (e: e.patterns != [ ]) (
        map (crate: {
          prefix = if crate == "" then "" else "${crate}/";
          patterns = map compilePattern ((readManifest (subPath root crate)).package.include or [ ]);
        }) (workspaceCrates root)
      );
    in
    path: _type:
    let
      rel = lib.removePrefix "${rootStr}/" (toString path);
    in
    lib.any (
      e: lib.hasPrefix e.prefix rel && matchesPatterns e.patterns (lib.removePrefix e.prefix rel)
    ) entries;
}
