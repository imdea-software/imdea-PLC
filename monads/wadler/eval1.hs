{- IMDEA PLC Meeting 1 -}

module MonadicEval where

import Prelude
import Control.Monad
import Basic

{- Modern Haskell wants instances of Functor amd
   "Applicative" before Monad -}

-- Q: What's Applicative?
-- A: It sounds like you are volunteering for chairing another meeting.

instance Functor E where
   fmap f (OK a) = OK $ f a
   fmap f (Raise e) = Raise e

instance Applicative E where
   pure = OK
   fa <*> fb = case (fa, fb) of
                 (OK f, OK val) -> OK $ f val
                 (_ , Raise ev) -> Raise ev
                 (Raise ef, _)  -> Raise ef               

instance Monad E where
  return = pure
  a >>= f   = case a of
               Raise e -> Raise e
               OK b  -> f b

runE m = case m of
            Raise e -> Left e
            OK a -> Right a

-- we cannot make S a Functor without defining it as a dataype

data SS s a = SS { unstate :: s -> (a,s) }

instance Functor (SS s) where
   fmap f pkg  = SS $ \ s -> let (a, _) = unstate pkg s
                             in  (f a, s)

instance Applicative (SS s) where
   pure a    = SS $ \ s -> (a, s)
   sf <*> sv = SS $ \ s -> let (f, s1) =  unstate sf s in
                           let (e, s2) =  unstate sv s1
                           in (f e , s2)

instance Monad (SS s) where
   return = pure
   m >>= k  = SS $ \ s -> let (a, s1) = unstate m s
                          in  unstate (k a) s1 


runS :: SS Int a -> (a, Int)
runS m = unstate m 0 


-- Skeleton for a monadic evaluator, works with any monad now:

evalM  :: Monad m => Term -> m Int
evalM (Con a)    = return a
evalM (Div mt mu ) =
         do vt <- evalM mt
            vu <- evalM mu
            return (vt `div` vu)
evalM (Plus mt mu ) =
         do vt <- evalM mt
            vu <- evalM mu
            return (vt + vu)

--- tryMe
trySS :: Term -> (Int, Int)
trySS = runS . evalM

tryE = runE . evalM


{- So we have a generic evaluator that does not
   introduce new effects incorporoate the effects,
   just binds arrow pure computations }

