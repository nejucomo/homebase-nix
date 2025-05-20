lib:

let mergeStrict = {
  # lib.mergeStrict :: Attrset -> Attrset -> Attrset (or throw)
  #
  # Merge two attrsets ensuring they have no attrNames in common.
  __functor = _: a: b: (
    let
      inherit (builtins) attrNames intersectAttrs;
      inherit (lib.trivial) throwIfNot;

      union = a // b;
      intersection = attrNames (intersectAttrs a b);
      empty = intersection == [];
      assertMsg = "colliding attrs: ${intersection}";

    in throwIfNot empty assertMsg union
  );

  # lib.mergeStrict.list :: [Attrset] -> Attrset (or throw)
  #
  # Merge any number of attrsets, ensuring they have no attrNames in common.
  list = builtins.foldl' mergeStrict {};
};

in mergeStrict
