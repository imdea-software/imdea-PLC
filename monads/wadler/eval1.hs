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

runSS :: SS Int a -> (a, Int)
runSS m = unstate m 0 


data OO a = OO { trace :: String, run :: a}

instance Functor OO where
   fmap f pkg  = OO (trace pkg) $ f $ run pkg
   
instance Applicative OO where
   pure a    = OO "" a
   sf <*> sv = OO (trace sf ++ trace sv) $ run sf $ run sv

instance Monad OO where
   ma >>= mk = let av = run ma in
               let m2 = mk av
               in OO (trace ma ++ trace m2 ) $ run m2


-- Skeleton for a monadic evaluator, works with any monad now:

evalM  :: Monad m => Term -> m Int
evalM (Con a)    = return a
evalM (Div mt mu ) =
         do vt <- evalM mt
            vu <- evalM mu
            return $ vt `div` vu
evalM (Plus mt mu ) =
         do vt <- evalM mt
            vu <- evalM mu
            return $ vt + vu

--- tryMe
trySS :: Term -> (Int, Int)
trySS = runSS . evalM

tryE m = putStr $ case (evalM m) of
                    Raise e ->  e
                    OK a -> show a ++ "\n"

tryOO m =
   do putStr $ trace $ evalM m
      putStrLn $ show $ run $ evalM m

{- So we have a generic evaluator that does not introduce new effects,
   just binds pure computations -}

{- Let's put the effects back in -}

evalR  :: Term -> E Int
evalR (Con a)    = return a
evalR (Div mt mu ) =
         do vt <- evalR mt
            vu <- evalR mu
            if vu == 0 then Raise "I ain't gonna divide by 0\n"
            else return $ vt `div` vu
evalR (Plus mt mu ) =
         do vt <- evalR mt
            vu <- evalR mu
            return $ vt + vu

tryE2 m = putStr $ case (evalR m) of
                    Raise e ->  e
                    OK a -> show a ++ "\n"

{- For the division acumulator, we define an incrementor function, and
 inline it before returning -}

tick  :: SS Int ()
tick = SS $ \s -> ((), s + 1)

evalS  :: Term -> SS Int Int
evalS (Con a)    = return a
evalS (Div mt mu ) =
         do vt <- evalS mt
            vu <- evalS mu
            tick
            return $ vt `div` vu
evalS (Plus mt mu ) =
         do vt <- evalS mt
            vu <- evalS mu
            return (vt + vu)

trySS2 = runSS . evalS


{- Finally, the tracing evaluator: -}


out t a = OO (line t a) ()

evalO  :: Term -> OO Int
evalO t@(Con a)  = out t a >> return a
evalO t@(Div mt mu) =
         do vt <- evalO mt
            out mt vt
            vu <- evalO mu
            out mu vu
            let c = vt `div` vu
            out t c
            return c
evalO t@(Plus mt mu ) =
         do vt <- evalO mt
            out mt vt
            vu <- evalO mu
            out mu vu
            let c = vt + vu
            out t c
            return c

tryO2 m =
   do putStr $ trace $ evalO m
      putStrLn $ show $ run $ evalO m


{- Excercise: Combine the three monads into a big fat one

  Dividing by 0 should return a trace finalizing with the exception
  raised, and a "stack dump" of the current state.

-}
