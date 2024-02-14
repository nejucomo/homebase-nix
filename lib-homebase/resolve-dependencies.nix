homebase:
let
  inherit (builtins)
    attrNames
    foldl'
    functionArgs
    hasAttr
    isAttrs
    isList
    isString
    listToAttrs
  ;
  inherit (homebase.nixpkgs.lib.attrsets)
    foldlAttrs
  ;

  # :: Resolved -> Specs -> TargetName -> Resolved
  # 
  # Returns `resolved` such that `target-name` is resolved
  resolve-target = resolved: specs: target-name:
    assert (isAttrs resolved);
    assert (isAttrs specs);
    assert (isString target-name);
    if hasAttr target-name resolved
    then resolved
    else
      let
        mk-target = specs.${target-name};
        dependency-names = attrNames (functionArgs mk-target);
        resolved' = resolve-target-dependency-names resolved specs dependency-names;
        attr-of-resolved' = name: {
          inherit name;
          value = resolved'.${name};
        };
        dependencies = listToAttrs (map attr-of-resolved' dependency-names);
        target = mk-target dependencies;
      in
        resolved' // { ${target-name} = target; };

  # :: Resolved -> Specs -> [TargetName] -> Resolved
  #
  # Returns `resolved` such that every arg to `target-spec` is resolved.
  resolve-target-dependency-names = resolved: specs: target-names:
    assert (isAttrs resolved);
    assert (isAttrs specs);
    assert (isList target-names);
    foldl' (resolved: name: resolve-target resolved specs name) resolved target-names;

in
  resolved: specs:
    assert (isAttrs resolved);
    assert (isAttrs specs);
    let
      resolve-attr = resolved: name: _spec:
        assert (isAttrs resolved);
        assert (isString name);
        resolve-target resolved specs name;
    in
      foldlAttrs resolve-attr resolved specs
