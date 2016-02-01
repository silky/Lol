{-# LANGUAGE ConstraintKinds, FlexibleContexts, FlexibleInstances, MultiParamTypeClasses, 
             PolyKinds, ScopedTypeVariables, TypeFamilies, UndecidableInstances #-}

module Crypto.Lol.Cyclotomic.Tensor.CTensor.Backend
(Dispatch
,dcrt
,dcrtinv
,dgaussdec
,dl
,dlinv
,dnorm
,dmulgpow
,dmulgdec
,dginvpow
,dginvdec
,dadd
,dmul
,marshalFactors
,CPP
,withArray
,withPtrArray
) where

import Control.Applicative
import Control.Monad

import Crypto.Lol.LatticePrelude as LP (Complex, Proxy(..), proxy, (++), map, mapM_, PP, Tagged, tag)
import Crypto.Lol.Reflects
import Crypto.Lol.Types.ZqBasic

import Data.Int
import Data.Vector.Storable          as SV (Vector, (!), replicate, replicateM, thaw, convert, foldl',
                                            unsafeToForeignPtr0, unsafeSlice, mapM, fromList,
                                            generate, foldl1',
                                            unsafeWith, zipWith, map, length, unsafeFreeze, thaw)
import Data.Vector.Storable.Internal (getPtr)

import           Foreign.ForeignPtr (touchForeignPtr)
import           Foreign.Marshal.Array (withArray)
import           Foreign.Marshal.Utils (with)
import           Foreign.Ptr (plusPtr, castPtr, Ptr)
import           Foreign.Storable        (Storable (..))
import qualified Foreign.Storable.Record as Store

marshalFactors :: [PP] -> Vector CPP
marshalFactors = SV.fromList . LP.map (\(p,e) -> CPP (fromIntegral p) (fromIntegral e))

-- http://stackoverflow.com/questions/6517387/vector-vector-foo-ptr-ptr-foo-io-a-io-a
withPtrArray :: (Storable a) => [Vector a] -> (Ptr (Ptr a) -> IO b) -> IO b
withPtrArray v f = do
  let vs = LP.map SV.unsafeToForeignPtr0 v
      ptrV = LP.map (\(fp,_) -> getPtr fp) vs
  res <- withArray ptrV f
  LP.mapM_ (\(fp,_) -> touchForeignPtr fp) vs
  return res

data CPP = CPP {p' :: !Int32, e' :: !Int16}
-- stolen from http://hackage.haskell.org/packages/archive/numeric-prelude/0.4.0.3/doc/html/src/Number-Complex.html#T
-- the NumericPrelude Storable instance for complex numbers
instance Storable CPP where
   sizeOf    = Store.sizeOf store
   alignment = Store.alignment store
   peek      = Store.peek store
   poke      = Store.poke store

store :: Store.Dictionary CPP
store = Store.run $
   liftA2 CPP
      (Store.element p')
      (Store.element e')

instance Show CPP where
    show (CPP p e) = "(" LP.++ (show p) LP.++ "," LP.++ (show e) LP.++ ")"

instance (Storable a, Storable b,
          BasicTypeOf a ~ CTypeOf b) 
  -- enforces right associativity and that each type of 
  -- the tuple has the same C repr, so using an array repr is safe
  => Storable (a,b) where
  sizeOf _ = (sizeOf (undefined :: a)) + (sizeOf (undefined :: b))
  alignment _ = max (alignment (undefined :: a)) (alignment (undefined :: b))
  peek p = do
    a <- peek (castPtr p :: Ptr a)
    b <- peek (castPtr (plusPtr p (sizeOf a)) :: Ptr b)
    return (a,b)
  poke p (a,b) = do
    poke (castPtr p :: Ptr a) a
    poke (castPtr (plusPtr p (sizeOf a)) :: Ptr b) b





data ZqB64D -- for type safety purposes
data ComplexD
data DoubleD
data Int64D

type family BasicTypeOf x where
  BasicTypeOf (ZqBasic (q :: k) Int64) = ZqB64D
  BasicTypeOf Double = DoubleD
  BasicTypeOf Int64 = Int64D
  BasicTypeOf (Complex Double) = ComplexD

type family CTypeOf x where
  CTypeOf (a,b) = BasicTypeOf a
  CTypeOf a = BasicTypeOf a

-- returns the modulus as a nested list of moduli
class GetModPairs a where
  type ModPairs a
  getModuli :: Tagged a (ModPairs a)

instance (Reflects q Int64) => GetModPairs (ZqBasic q Int64) where
  type ModPairs (ZqBasic q Int64) = Int64
  getModuli = tag $ proxy value (Proxy::Proxy q)

instance (GetModPairs b, Reflects q Int64) => GetModPairs (ZqBasic q Int64, b) where
  type ModPairs (ZqBasic q Int64,b) = (Int64, ModPairs b)
  getModuli = 
    let q = proxy value (Proxy::Proxy q)
        qs = proxy getModuli (Proxy :: Proxy b)
    in tag $ (q,qs)

-- counts components in a nested tuple
class RingProduct a where
  numComponents :: Tagged a Int16

instance {-# Overlappable #-} RingProduct a where
  numComponents = tag 1

instance (RingProduct a, RingProduct b) => RingProduct (a,b) where
  numComponents = tag $ (proxy numComponents (Proxy::Proxy a)) + (proxy numComponents (Proxy::Proxy b))

type Dispatch r = (Dispatch' (CTypeOf r) r)

-- | Class to safely match Haskell types with the appropriate C function.
class (repr ~ CTypeOf r) => Dispatch' repr r where
  dcrt      :: Ptr (Ptr r) ->           Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dcrtinv   :: Ptr (Ptr r) -> Ptr r ->  Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dgaussdec :: Ptr (Ptr (Complex r)) -> Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()

  dl        :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dlinv     :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dnorm     :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dmulgpow  :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dmulgdec  :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dginvpow  :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  dginvdec  :: Ptr r -> Int64 -> Ptr CPP -> Int16 -> IO ()
  
  dadd :: Ptr r -> Ptr r -> Int64 -> IO ()
  dmul :: Ptr r -> Ptr r -> Int64 -> IO ()

instance (GetModPairs r, Storable (ModPairs r),
          RingProduct r, CTypeOf r ~ ZqB64D)
  => Dispatch' ZqB64D r where
  dcrt ruptr pout totm pfac numFacts = 
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorCRTRq numPairs (castPtr pout) totm pfac numFacts (castPtr ruptr) (castPtr qsptr)
  dcrtinv ruptr minv pout totm pfac numFacts =
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorCRTInvRq numPairs (castPtr pout) totm pfac numFacts (castPtr ruptr) (castPtr minv) (castPtr qsptr)
  dl pout totm pfac numFacts = 
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorLRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dlinv pout totm pfac numFacts = 
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorLInvRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dnorm = error "cannot call CT normSq on type ZqBasic"
  dmulgpow pout totm pfac numFacts =
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorGPowRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dmulgdec pout totm pfac numFacts =
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorGDecRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dginvpow pout totm pfac numFacts =
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorGInvPowRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dginvdec pout totm pfac numFacts =
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        tensorGInvDecRq numPairs (castPtr pout) totm pfac numFacts (castPtr qsptr)
  dadd aout bout totm = 
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        addRq numPairs (castPtr aout) (castPtr bout) totm (castPtr qsptr)
  dmul aout bout totm = 
    let qs = proxy getModuli (Proxy::Proxy r)
        numPairs = proxy numComponents (Proxy::Proxy r)
    in with qs $ \qsptr ->
        mulRq numPairs (castPtr aout) (castPtr bout) totm (castPtr qsptr)
  dgaussdec = error "cannot call CT gaussianDec on type ZqBasic"

instance (RingProduct r, CTypeOf r ~ ComplexD) => Dispatch' ComplexD r where
  dcrt ruptr pout totm pfac numFacts = 
    tensorCRTC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts (castPtr ruptr)
  dcrtinv ruptr minv pout totm pfac numFacts = 
    tensorCRTInvC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts (castPtr ruptr) (castPtr minv)
  dl pout totm pfac numFacts = 
    tensorLC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dlinv pout totm pfac numFacts = 
    tensorLInvC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dnorm = error "cannot call CT normSq on type Complex Double"
  dmulgpow pout totm pfac numFacts = 
    tensorGPowC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dmulgdec = error "cannot call CT mulGDec on type Complex Double"
  dginvpow pout totm pfac numFacts = 
    tensorGInvPowC (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dginvdec = error "cannot call CT divGDec on type Complex Double"
  dadd aout bout totm = 
    addC (proxy numComponents (Proxy::Proxy r)) (castPtr aout) (castPtr bout) totm
  dmul aout bout totm = 
    mulC (proxy numComponents (Proxy::Proxy r)) (castPtr aout) (castPtr bout) totm
  dgaussdec = error "cannot call CT gaussianDec on type Comple Double"

instance (RingProduct r, CTypeOf r ~ DoubleD) => Dispatch' DoubleD r where
  dcrt = error "cannot call CT Crt on type Double"
  dcrtinv = error "cannot call CT CrtInv on type Double"
  dl pout totm pfac numFacts = 
    tensorLDouble (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dlinv pout totm pfac numFacts = 
    tensorLInvDouble (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dnorm = error "cannot call CT normSq on type Double"
  dmulgpow = error "cannot call CT mulGPow on type Double"
  dmulgdec = error "cannot call CT mulGDec on type Double"
  dginvpow = error "cannot call CT divGPow on type Double"
  dginvdec = error "cannot call CT divGDec on type Double"
  dadd aout bout totm = 
    addD (proxy numComponents (Proxy::Proxy r)) (castPtr aout) (castPtr bout) totm
  dmul = error "cannot call CT (*) on type Double"
  dgaussdec ruptr pout totm pfac numFacts = 
    tensorGaussianDec (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts (castPtr ruptr)

instance (RingProduct r, CTypeOf r ~ Int64D) => Dispatch' Int64D r where
  dcrt = error "cannot call CT Crt on type Int64"
  dcrtinv = error "cannot call CT CrtInv on type Int64"
  dl pout totm pfac numFacts = 
    tensorLR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dlinv pout totm pfac numFacts = 
    tensorLInvR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dnorm pout totm pfac numFacts = 
    tensorNormSqR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dmulgpow pout totm pfac numFacts = 
    tensorGPowR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dmulgdec pout totm pfac numFacts = 
    tensorGDecR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dginvpow pout totm pfac numFacts = 
    tensorGInvPowR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dginvdec pout totm pfac numFacts = 
    tensorGInvDecR (proxy numComponents (Proxy::Proxy r)) (castPtr pout) totm pfac numFacts
  dadd aout bout totm = 
    addR (proxy numComponents (Proxy::Proxy r)) (castPtr aout) (castPtr bout) totm
  dmul = error "cannot call CT (*) on type Int64"
  dgaussdec = error "cannot call CT gaussianDec on type Int64"

foreign import ccall unsafe "tensorLR" tensorLR ::                  Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorLInvR" tensorLInvR ::            Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorLRq" tensorLRq ::                Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorLInvRq" tensorLInvRq ::          Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorLDouble" tensorLDouble ::       Int16 -> Ptr Double -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorLInvDouble" tensorLInvDouble :: Int16 -> Ptr Double -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorLC" tensorLC ::       Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorLInvC" tensorLInvC :: Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16          -> IO ()

foreign import ccall unsafe "tensorNormSqR" tensorNormSqR ::     Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()

foreign import ccall unsafe "tensorGPowR" tensorGPowR ::         Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGPowRq" tensorGPowRq ::       Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorGPowC" tensorGPowC ::         Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGDecR" tensorGDecR ::         Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGDecRq" tensorGDecRq ::       Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorGInvPowR" tensorGInvPowR ::   Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGInvPowRq" tensorGInvPowRq :: Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorGInvPowC" tensorGInvPowC ::   Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGInvDecR" tensorGInvDecR ::   Int16 -> Ptr Int64 -> Int64 -> Ptr CPP -> Int16          -> IO ()
foreign import ccall unsafe "tensorGInvDecRq" tensorGInvDecRq :: Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr Int64 -> IO ()

foreign import ccall unsafe "tensorCRTRq" tensorCRTRq ::         Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr (Ptr (ZqBasic q Int64)) -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorCRTC" tensorCRTC ::           Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16 -> Ptr (Ptr (Complex Double)) -> IO ()
foreign import ccall unsafe "tensorCRTInvRq" tensorCRTInvRq ::   Int16 -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr CPP -> Int16 -> Ptr (Ptr (ZqBasic q Int64)) -> Ptr (ZqBasic q Int64) -> Ptr Int64 -> IO ()
foreign import ccall unsafe "tensorCRTInvC" tensorCRTInvC ::     Int16 -> Ptr (Complex Double) -> Int64 -> Ptr CPP -> Int16 -> Ptr (Ptr (Complex Double)) -> Ptr (Complex Double) -> IO ()

foreign import ccall unsafe "tensorGaussianDec" tensorGaussianDec :: Int16 -> Ptr Double -> Int64 -> Ptr CPP -> Int16 -> Ptr (Ptr (Complex Double)) ->  IO ()

foreign import ccall unsafe "mulRq" mulRq :: Int16 -> Ptr (ZqBasic q Int64) -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "mulC" mulC :: Int16 -> Ptr (Complex Double) -> Ptr (Complex Double) -> Int64 -> IO ()

foreign import ccall unsafe "addRq" addRq :: Int16 -> Ptr (ZqBasic q Int64) -> Ptr (ZqBasic q Int64) -> Int64 -> Ptr Int64 -> IO ()
foreign import ccall unsafe "addR" addR :: Int16 -> Ptr Int64 -> Ptr Int64 -> Int64 -> IO ()
foreign import ccall unsafe "addC" addC :: Int16 -> Ptr (Complex Double) -> Ptr (Complex Double) -> Int64 -> IO ()
foreign import ccall unsafe "addD" addD :: Int16 -> Ptr Double -> Ptr Double -> Int64 -> IO ()