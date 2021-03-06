module MagicHaskeller.LibTHDefinitions where

import Language.Haskell.TH
import Data.Generics(mkT, everywhere)

{-
changeName :: Name -> Name -> Name -> Name
changeName ni nf n = if ni == n then nf else n

declare :: String -> DecsQ -> DecsQ
declare s dsQ = do
  let nf = mkName s
  ds@(SigD ni _ : _) <- dsQ
  return (everywhere (mkT $ changeName ni nf) ds)
-}

allDeclarations :: DecsQ
allDeclarations = concat <$> sequence [natParaDeclaration, hdDeclaration, tlDeclaration
                              , natCataDeclaration, iFDeclaration, listParaDeclaration
                              , magicIfDeclaration
                              ]

-- Nat paramorphism
natParaDeclaration :: DecsQ
natParaDeclaration =
  [d|
  nat_para :: Integral i => i -> a -> (i -> a -> a) -> a
  nat_para i x f = np (abs i) -- Version 0.8 does not deal with partial functions very well.
    where np 0 = x
          np i = let i' = i-1
                 in f i' (np i')
    |]

-- f = \n -> nat_para n (iF (n `mod` 2 == 0) "I hate it" "I love it") (\f i s -> iF ((n-i) `mod` 2 == 0) "I hate that " "I love that "  ++ s)

hdDeclaration :: DecsQ
hdDeclaration =
  [d|
  hd :: [a] -> a
  hd [] = error "empty head"
  hd (a:as) = a
    |]

tlDeclaration :: DecsQ
tlDeclaration =
  [d|
  tl = drop 1
    |]

natCataDeclaration :: DecsQ
natCataDeclaration =
  [d|
  -- Nat paramorphism.  nat_cata i x f == iterate f x `genericIndex` abs i holds, but the following implementation is much more efficient (and thus safer).
  nat_cata :: Integral i => i -> a -> (a -> a) -> a
  nat_cata i x f = nc (abs i) -- Version 0.8 does not deal with partial functions very well.
      where nc 0 = x
            nc i = f (nc (i-1))
    |]

iFDeclaration :: DecsQ
iFDeclaration =
  [d|
  iF :: Bool -> a -> a -> a
  iF True  t f = t
  iF False t f = f
    |]


listParaDeclaration :: DecsQ
listParaDeclaration =
  [d|
  -- List paramorphism
  list_para :: [b] -> a -> (b -> [b] -> a -> a) -> a
  list_para []     x f = x
  list_para (y:ys) x f = f y ys (list_para ys x f)
    |]

magicIfDeclaration :: DecsQ
magicIfDeclaration =
  [d|
  magiciF :: Bool -> String
  magiciF b = if b then "EASY" else "HARD"
    |]
