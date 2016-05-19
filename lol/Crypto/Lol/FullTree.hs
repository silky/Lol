{-# LANGUAGE ConstraintKinds, DataKinds, ExplicitNamespaces, FlexibleContexts, GADTs,
             InstanceSigs, KindSignatures, PartialTypeSignatures, PolyKinds,
             ScopedTypeVariables, StandaloneDeriving, TemplateHaskell, TypeFamilies, TypeOperators,
             UndecidableInstances #-}

module Crypto.Lol.FullTree
( augmentSBS
, augmentVector
, flipBit
, FullTree(..)
, rootValue
) where

import Crypto.Lol.Gadget
import Crypto.Lol.LatticePrelude
import Crypto.Lol.MMatrix
import Crypto.Lol.PosBinDefs
import Crypto.Lol.Reflects
import Crypto.Lol.SafeBitString

import Crypto.Lol.Types.Numeric as N

import Data.Functor.Trans.Tagged

import qualified MathObj.Matrix as M
-- n = numLeaves, l = leafType, v = vectorRq
data FullTree (n :: Pos) l v where
  Leaf :: l -> v -> FullTree O l v
  Internal :: v -> FullTree nl l v
                -> FullTree nr l v
                -> FullTree (AddPos nl nr) l v

-- | Returns the vector attached to the FullTree.
rootValue :: FullTree n l v -> v
rootValue (Leaf b v) = v
rootValue (Internal v l r) = v

-- | Augments the leaves of the FullTree with Bool values.
augmentSBS :: FullTree n () () -> -- ^ Full tree T (topology)
                    SafeBitString n -> -- Bit string x
                    FullTree n Bool () -- ^ Full tree T (bit on each leaf)
augmentSBS (Leaf _ _) (Bit b) = Leaf b ()
--augmentBitString (Internal _ left right) bits =
  --let (leftBits, rightBits) = splitSBS bits
  --in Internal () (augmentSBS left leftBits) (augmentSBS right rightBits)

-- | Augments the nodes of the FullTree with MMatrix values.
augmentVector :: (Ring (DecompOf a), Lift a (DecompOf a), Reduce (DecompOf a) a,
                 Decompose (BaseBGad 2) a, LiftOf a ~ DecompOf a) =>
                 MMatrix a -> -- ^ Base vector a0
                 MMatrix a -> -- ^ Base vector a1
                 FullTree n Bool () -> -- ^ Full tree T (bit on each leaf)
                 FullTree n Bool (MMatrix a) -- ^ Full tree T (calculated a_T(x))
augmentVector a0 a1 (Leaf bit _)
  | bit = Leaf bit a1
  | otherwise = Leaf bit a0
augmentVector a0 a1 (Internal _ l r) =
  let l' = augmentVector a0 a1 l
      r' = augmentVector a0 a1 r
      c = combineVectors (rootValue l') (rootValue r')
  in (Internal c l' r')

-- | Flip the boolean value at a chosen leaf.
flipBit :: (Ring a) =>
           MMatrix a -> -- ^ Base vector a0
           MMatrix a -> -- ^ Base vector a1
           Pos -> -- ^ # of bit to flip
           FullTree n Bool (MMatrix a) -> -- ^ Full Tree T
           FullTree n Bool (MMatrix a) -- ^ Full Tree T (after bit flip)
flipBit a0 a1 O (Leaf b v)
  | b = Leaf (not b) a0
  | otherwise = Leaf (not b) a1
-- pseudocode available for the other case in 5/13/16 log.
