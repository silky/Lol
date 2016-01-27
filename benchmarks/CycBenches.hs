{-# LANGUAGE ConstraintKinds, DataKinds, FlexibleContexts, FlexibleInstances, 
             GADTs, MultiParamTypeClasses,NoImplicitPrelude, RankNTypes, 
             RebindableSyntax, ScopedTypeVariables, TypeFamilies, 
             TypeOperators, UndecidableInstances #-}

module CycBenches (cycBenches) where

import Control.Applicative
import Control.Monad.Random

import Crypto.Lol
import Crypto.Lol.Types.Random
import Crypto.Random.DRBG

import Data.Singletons
import Data.Promotion.Prelude.List
import Data.Promotion.Prelude.Eq
import Data.Singletons.TypeRepStar

import Criterion
import Utils

cycBenches :: (MonadRandom rnd) => rnd Benchmark
cycBenches = bgroupRnd "Cyc"
  [bgroupRnd "CRT + *" $ bench2Arg bench_mulPow,
   bgroupRnd "*"       $ bench2Arg bench_mul,
   bgroupRnd "crt"     $ bench1Arg bench_crt,
   bgroupRnd "crtInv"  $ bench1Arg bench_crtInv,
   bgroupRnd "l"       $ bench1Arg bench_l,
   bgroupRnd "*g Pow"  $ bench1Arg bench_mulgPow,
   bgroupRnd "*g CRT"  $ bench1Arg bench_mulgCRT,
   bgroupRnd "lift"    $ benchLift bench_liftPow,
   bgroupRnd "error"   $ benchError $ bench_errRounded 0.1
   -- sanity checks
   --, bgroupRnd "^2" $ groupC $ wrap1Arg bench_sq,             -- should take same as bench_mul
   --, bgroupRnd "id2" $ groupC $ wrap1Arg bench_advisePowPow -- should take a few nanoseconds: this is a no-op
  ]

-- convert both arguments to CRT basis, then multiply them coefficient-wise
bench_mulPow :: (BasicCtx t m r) => Cyc t m r -> Cyc t m r -> Benchmarkable
bench_mulPow a b = 
  let a' = advisePow a
      b' = advisePow b
  in nf (a' *) b'

-- no CRT conversion, just coefficient-wise multiplication
bench_mul :: (BasicCtx t m r) => Cyc t m r -> Cyc t m r -> Benchmarkable
bench_mul a b = 
  let a' = adviseCRT a
      b' = adviseCRT b
  in nf (a' *) b'

-- convert input from Pow basis to CRT basis
bench_crt :: (BasicCtx t m r) => Cyc t m r -> Benchmarkable
bench_crt x = let y = advisePow x in nf adviseCRT y

-- convert input from CRT basis to Pow basis
bench_crtInv :: (BasicCtx t m r) => Cyc t m r -> Benchmarkable
bench_crtInv x = let y = adviseCRT x in nf advisePow y

-- convert input from Dec basis to Pow basis
bench_l :: (BasicCtx t m r) => Cyc t m r -> Benchmarkable
bench_l x = let y = adviseDec x in nf advisePow y

-- lift an element in the Pow basis
bench_liftPow :: forall t m r . (LiftCtx t m r) => Cyc t m r -> Benchmarkable
bench_liftPow x = let y = advisePow x in nf (liftCyc Pow :: Cyc t m r -> Cyc t m (LiftOf r)) y

-- multiply by g when input is in Pow basis
bench_mulgPow :: (BasicCtx t m r) => Cyc t m r -> Benchmarkable
bench_mulgPow x = let y = advisePow x in nf mulG y

-- multiply by g when input is in CRT basis
bench_mulgCRT :: (BasicCtx t m r) => Cyc t m r -> Benchmarkable
bench_mulgCRT x = let y = adviseCRT x in nf mulG y

-- generate a rounded error term
bench_errRounded :: forall t m r gen . (LiftCtx t m r, CryptoRandomGen gen) 
  => Double -> Proxy gen -> Proxy (t m r) -> Benchmarkable
bench_errRounded v _ _ = nfIO $ do
  gen <- newGenIO
  return $ evalRand (errorRounded v :: Rand (CryptoRand gen) (Cyc t m (LiftOf r))) gen

{-
-- sanity check: this test should take the same amount of time as bench_mul
-- if it takes less, then random element generation is being counted!
bench_sq :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_sq a = nf (a *) a

-- sanity check: this should be a no-op
bench_advisePowPow :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_advisePowPow x = let y = advisePow x in nf advisePow y
-}

type Tensors = '[CT,RT]
type MM'RCombos = 
  '[ '(F4, F128, Zq 257),
     '(F1, PToF Prime281, Zq 563),
     '(F12, F32 * F9, Zq 512),
     '(F12, F32 * F9, Zq 577),
     '(F12, F32 * F9, Zq (577 ** 1153)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457 ** 6337)),
     '(F12, F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457 ** 6337 ** 7489)),
     '(F12, F32 * F9 * F25, Zq 14401)
    ]
-- EAC: must be careful where we use Nub: apparently TypeRepStar doesn't work well with the Tensor constructors
type AllParams = Map Unpack (( '(,) <$> Tensors) <*> (Nub (Map RemoveM MM'RCombos)))
type LiftParams = Map Unpack (( '(,) <$> Tensors) <*> (Nub (Filter Liftable (Map RemoveM MM'RCombos))))

data Unpack :: TyFun (Factored -> * -> *, (Factored, *)) (Factored -> * -> *, Factored, *) -> *
type instance Apply Unpack '(a, '(c,d)) = '(a,c,d)

data Liftable :: TyFun (Factored, *) Bool -> *
type instance Apply Liftable '(m',r) = Int64 :== (LiftOf r)

data RemoveM :: TyFun (Factored, Factored, *) (Factored, *) -> *
type instance Apply RemoveM '(m,m',r) = '(m',r)


data BasicCtxD
type BasicCtx t m r = (CElt t r, Fact m, Show (BenchType '(t,m,r)))
data instance ArgsCtx BasicCtxD where
  BC :: (BasicCtx t m r) => Proxy '(t,m,r) -> ArgsCtx BasicCtxD
hideTMR :: (forall t m r . (BasicCtx t m r) => Proxy '(t,m,r) -> rnd Benchmark) -> ArgsCtx BasicCtxD -> rnd Benchmark
hideTMR f (BC p) = f p

instance (Run BasicCtxD params, BasicCtx t m r) => Run BasicCtxD ( '(t,m,r) ': params) where
  runAll _ f = (f $ BC (Proxy::Proxy '(t,m,r))) : (runAll (Proxy::Proxy params) f)


wrap1Arg :: forall t m r rnd . (BasicCtx t m r, MonadRandom rnd) 
  => (Cyc t m r -> Benchmarkable) -> Proxy '(t,m,r) -> rnd Benchmark
wrap1Arg f _ = bench (show (BT :: BenchType '(t,m,r))) <$> genArgs f

bench1Arg :: (MonadRandom rnd)
  => (forall t m r . (BasicCtx t m r) => Cyc t m r -> Benchmarkable) -> [rnd Benchmark]
bench1Arg g = runAll (Proxy::Proxy AllParams) $ hideTMR $ wrap1Arg g

wrap2Arg :: forall t m r rnd . (BasicCtx t m r, MonadRandom rnd)
  => (Cyc t m r -> Cyc t m r -> Benchmarkable) -> Proxy '(t,m,r) -> rnd Benchmark
wrap2Arg f _ = bench (show (BT :: BenchType '(t,m,r))) <$> genArgs f

bench2Arg :: (MonadRandom rnd) 
  => (forall t m r . (BasicCtx t m r) => Cyc t m r -> Cyc t m r -> Benchmarkable) -> [rnd Benchmark]
bench2Arg g = runAll (Proxy::Proxy AllParams) $ hideTMR $ wrap2Arg g


data LiftCtxD
type LiftCtx t m r = (BasicCtx t m r, CElt t (LiftOf r), Lift' r, ToInteger (LiftOf r))
data instance ArgsCtx LiftCtxD where
  LC :: (LiftCtx t m r) => Proxy '(t,m,r) -> ArgsCtx LiftCtxD
hideLift :: (forall t m r . (LiftCtx t m r) => Proxy '(t,m,r) -> rnd Benchmark) -> ArgsCtx LiftCtxD -> rnd Benchmark
hideLift f (LC p) = f p

instance (Run LiftCtxD params, LiftCtx t m r) => Run LiftCtxD ( '(t,m,r) ': params) where
  runAll _ f = (f $ LC (Proxy::Proxy '(t,m,r))) : (runAll (Proxy::Proxy params) f)

wrapLift :: forall t m r rnd . (LiftCtx t m r, MonadRandom rnd)
  => (Cyc t m r -> Benchmarkable) -> Proxy '(t,m,r) -> rnd Benchmark
wrapLift f _ = bench (show (BT :: BenchType '(t,m,r))) <$> genArgs f

benchLift :: (MonadRandom rnd) 
  => (forall t m r . (LiftCtx t m r) => Cyc t m r -> Benchmarkable) -> [rnd Benchmark]
benchLift g = runAll (Proxy::Proxy LiftParams) $ hideLift $ wrapLift g

wrapError :: forall t m r gen rnd . (LiftCtx t m r, CryptoRandomGen gen, Monad rnd)
  => (Proxy gen -> Proxy (t m r) -> Benchmarkable) 
     -> Proxy gen -> Proxy '(t,m,r) -> rnd Benchmark
wrapError f _ _ = return $ bench (show (BT :: BenchType '(t,m,r))) $ f Proxy Proxy

benchError :: (MonadRandom rnd) 
  => (forall t m r gen . (LiftCtx t m r, CryptoRandomGen gen) => Proxy gen -> Proxy (t m r) -> Benchmarkable) -> [rnd Benchmark]
benchError g = [
  bgroupRnd "HashDRBG" $ runAll (Proxy::Proxy LiftParams) $ hideLift $ wrapError g (Proxy::Proxy HashDRBG),
  bgroupRnd "SysRand" $ runAll (Proxy::Proxy LiftParams) $ hideLift $ wrapError g (Proxy::Proxy SystemRandom)]
