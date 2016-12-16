{- IMDEA PLC Meeting 1 -}

module MonadicSIL where

import Prelude

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


data Arr
type Val = Int
type Id = String

{- Excercise 1: Complete implementation of functional arrays using lazy
 lists.

Define functions:
-}


newarray :: Val -> Arr
newarray = undefined

index :: Id -> Arr -> Val
index = undefined

update :: Id -> Val -> Arr -> Arr
update = undefined

{-
such that it satisfies the algebraic properties specified in the
paper.
-}

--  A simple imperative array language

data Term = Var Id | Con Int | Add Term Term
  deriving Show

data Comm = Asgn Id Term | Seq Comm Comm | If Term Comm Comm
  deriving Show

data Prog = Prog Comm Term
  deriving Show

eval             :: Term -> Arr -> Int
eval (Var i) x   = index i x
eval (Con a) x   = a
eval (Add t u) x = eval t x + eval u x

exec              :: Comm -> Arr  -> Arr
exec (Asgn i t) x = update i (eval t x) x
exec (Seq c d) x  = exec d (exec c x)
exec (If t c d) x = if eval t x == 0 then exec c x else exec d x

elab :: Prog -> Int
elab (Prog c t) = eval t $ exec c $ newarray 0

{- Exercice2: What if i \notin x?

   hint: Combine Maybe with SS

-}

-- Monadic version

block :: Val ->  SS Arr a -> a
block v m = let (a, x) = (unstate m) $ newarray v in a

{-

I did not understand the whole bussiness with single threadness
 property. My hunch is that block forces the evaluation of the monadic
 thunk so it becomes strict on the state. But, I'm not exactly sure.

-}

fetch :: Id ->  SS Arr Val
fetch = undefined

assign :: Id -> Val -> SS Arr ()
assign = undefined


eval'           :: Term -> SS Arr Int
eval' (Var i)   = fetch i
eval' (Con a)   = return a
eval' (Add t u) =
          do a <- eval' t
             b <- eval' u
             return (a + b)

exec'            :: Comm -> SS Arr ()
exec' (Asgn i t) = eval' t >>=  assign i
exec' (Seq c d)  = exec' c >> exec' d >> return ()
exec'  (If t c d) =
  do b <- eval' t
     if b == 0 then exec' c else exec' d

elab' :: Prog  -> Int
elab' (Prog c t) = block 0 $ exec' c >> eval' t

{- Excercise 3: Replace undefined for proper definitions -}


{-- RR : Reader monad -}

data RR s a = RR { unread :: s -> a } 

instance Functor (RR s) where
  fmap f pkg = RR $ \ s -> f $ unread pkg s

instance Applicative (RR s) where
  pure a     = RR $ \ _ -> a
  mf <*> mb  = RR $ \ s -> let f = unread mf s in
                           let b = unread mb s
                           in f b
instance Monad (RR s) where
  ma >>= mk =  RR $ \ s -> let a = unread ma s in unread (mk a) s


fetchR   :: Id -> RR Arr Val
fetchR i = RR $ \ s -> index i s 

{-- coerce: monad morphism from RR to SS -}

coerce   :: RR s a -> SS s a
coerce m =  SS $ \ s -> let a = unread m s in (a,s)

{- Excercise 4:
   Prove:
      a) Monad laws for RR, commutativity of R
      b) coerce is an actual monad morphism
-}


-- Fancy RR/SS interpreter

evalR           :: Term -> RR Arr Int
evalR (Var i)   = fetchR i
evalR (Con a)   = return a
evalR (Add t u) =
          do a <- evalR t
             b <- evalR u
             return (a + b)

execC            :: Comm -> SS Arr ()
execC (Asgn i t) =
  do e <- coerce $ evalR t
     assign i e     
execC (Seq c d)  =
  do execC c
     execC d
     return ()
execC  (If t c d) =
  do b <- coerce $ evalR t
     if b == 0 then exec' c else exec' d

elabF :: Prog  -> Int
elabF (Prog c t) = block 0 $ execC c >> coerce (evalR t)


{- Excercise 5: Extend the SIL with the full Term Language from eval0.hs -}
