homebase:
let
  inherit (builtins)
    foldl'
    functionArgs
    listToAttrs
  ;
  inherit (homebase.nixpkgs.lib.attrsets)
    foldlAttrs
  ;
  
  # :: Resolved -> Specs -> TargetName -> Resolved
  # 
  # Returns `resolved` such that `target-name` is resolved
  resolve-target = resolved: specs: target-name:
    if resolved ? target-name
    then resolved
    else
      let
        mk-target = specs.${target-name};
        dependency-names = functionArgs mk-target;
        resolved' = resolve-target-dependency-names resolved specs dependency-names;
        attr-of-resolved' = name: {
          inherit name;
          value = resolved'.${name};
        };
        dependencies = listToAttrs (map attr-of-resolved dependency-names);
        target = target-spec dependencies;
      in
        resolved' // { ${target-name} = target; };

  # :: Resolved -> Specs -> [TargetName] -> Resolved
  #
  # Returns `resolved` such that every arg to `target-spec` is resolved.
  resolve-target-dependency-names = resolved: specs:
    foldl' (resolved: name: resolve-target resolved specs name) resolved;

in
  resolved: specs:
    let
      resolve-attr = name: _spec: resolved:
        resolve-target resolved specs name;
    in
      foldlAttrs resolve-attr resolved specs
