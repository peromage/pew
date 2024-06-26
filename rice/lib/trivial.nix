{ self, nixpkgs, ... }:

let
  lib = nixpkgs.lib;

in with self; {
  /* Join a list of strings/paths with separaters.

     Type:
       joinStrs :: String -> [Any] -> String
  */
  joinStrs = sep: list: with lib; foldl' (a: i: a + "${sep}${i}") (head list) (tail list);

  /* Join a list of paths.

     Type:
       joinPaths :: [Path] -> Path
  */
  joinPaths = joinStrs "/";

  /* Concatenate strings.

     Type:
       concatStrs :: String -> String -> String
  */
  concatStrs = a: b: a + b;

  /* Concatenate lists.

     Type:
       concatLists :: [Any] -> [Any] -> [Any]
  */
  concatLists = a: b: a ++ b;

  /* Merge attribute sets.

     Type:
       mergeAttrs :: AttrSet -> AttrSet -> AttrSet
  */
  mergeAttrs = a: b: a // b;

  /* Like `mergeAttrs' but merge the first level instead of top level.

     Type:
       mergeAttrsFirstLevel :: [AttrSet] -> AttrSet
  */
  mergeAttrsFirstLevel = lib.foldAttrs mergeAttrs {};

  /* Return the first non-null value between a and b.
     If both are null the result is null.

     Type:
       either :: Any -> Any -> Any
  */
  either = a: b: if null != a then a else if null != b then b else null;

  /* Like `either' but a default return value can be specified.

     Type:
       either' :: Any -> Any -> Any -> Any
  */
  either' = a: b: r: let x = either a b; in if null != x then x else r;

  /* Return the first argument passed to this function.

     Type:
       pairFirst :: a -> b -> a
  */
  pairFirst = a: b: a;

  /* Return the second argument passed to this function.

     Type:
       pairSecond :: a -> b -> b
  */
  pairSecond = a: b: b;

  /* Return true if the function pred returns true for at least one element of
     attrs, and false otherwise.

     Type:
       anyAttrs :: (String -> Any -> Bool) -> AttrSet -> Bool

  */
  anyAttrs = pred: attrs: with lib; any id (mapAttrsToList pred attrs);

  /* Return true if the function pred returns true for all elements of attrs,
     and false otherwise.

     Type:
       allAttrs :: (String -> Any -> Bool) -> AttrSet -> Bool
  */
  allAttrs = pred: attrs: with lib; all id (mapAttrsToList pred attrs);

  /* Get attribute base on a list of names.
     This is useful for nested access.

     Type:
       getNestedAttrs :: [String] -> AttrSet -> Any
  */
  getNestedAttrs = names: attrs: with lib; foldl' (a: n: getAttr n a) attrs names;

  /* Logic not.

     Type:
       not :: Bool -> Bool
  */
  not = a: !a;

  /* Logic and.

     Type:
       and :: Bool -> Bool -> Bool
  */
  and = a: b: a && b;

  /* logic or.

     Type:
       and :: Bool -> Bool -> Bool
  */
  or = a: b: a || b;

  /* Comparison equal to.

     Type:
       eq :: a -> a -> Bool
  */
  eq = a: b: a == b;

  /* Comparison not equal to.

     Type:
       ne :: a -> a -> Bool
  */
  ne = a: b: a != b;

  /* Comparison greater than.

     Type:
       gt :: a -> a -> Bool
  */
  gt = a: b: a > b;

  /* Comparison greater than or equal to.

     Type:
       ge :: a -> a -> Bool
  */
  ge = a: b: a >= b;

  /* Comparison less than.

     Type:
       lt :: a -> a -> Bool
  */
  lt = a: b: a < b;

  /* Comparison less than or equal to.

     Type:
       le :: a -> a -> Bool
  */
  le = a: b: a <= b;

  /* Increment by 1.

     Type:
       addOne :: Number -> Number
  */
  addOne = a: a + 1;

  /* Decrement by 1.

     Type:
       addOne :: Number -> Number
  */
  minusOne = a: a - 1;

  /* Apply a list of arguments to the function.

     Type:
       apply :: (Any -> Any) -> [Any] -> Any
  */
  apply = lib.foldl' (f: x: f x);

  /* Filter the return value of the original function.

     Note that n (the number of arguments) must be greater than 0 since a
     function should at least have one argument.  This is required because for
     curried functions the number of arguments can not be known beforehand.  The
     caller must tell this function where to end.

     Type:
       wrapReturn :: Number -> (Any -> Any) -> (Any -> ... -> Any) -> Any
  */
  wrapReturn = n: wf: f:
    let wrap = f: n: a: if n == 1 then wf (f a) else wrap (f a) (n - 1);
    in assert n > 0; wrap f n;

  /* Filter the arguments of the original function.

     Note that n (the number of arguments) must be greater than 0 since a
     function should at least have one argument.  This is required because for
     curried functions the number of arguments can not be known beforehand.  The
     caller must tell the wrapper function where to end.

     The wrapper function must have the same signature of the original function
     and return a list of altered arguments.

     Type:
       wrapArgs :: Number -> (Any -> ... -> [Any]) -> (Any -> ... -> Any) -> Any
  */
  wrapArgs = n: wf: f:
    let wrap = wf: n: a: if n == 1 then apply f (wf a) else wrap (wf a) (n - 1);
    in assert n > 0; wrap wf n;

  /* Fix point and override pattern.
     See: http://r6.ca/blog/20140422T142911Z.html
  */
  fixOverride = f: let x = f x; in x // {
    override = overrides: fixOverride (self: f self // (
      if builtins.isFunction overrides then
        overrides self
      else
        overrides
    ));
  };
}
