{-  IMDEA PLC Meeting 1 -}

-- Haskell Code from P. Wadler's Monads for Functional Programming

module Basic where


import Prelude

{- The algebraic datatype of Constants and Divisions: a binary tree
with Int leaves. Fancy stuff. -}

data Term = Con Int
     | Div Term Term
     | Plus Term Term

eval            :: Term -> Int
eval (Con a)    = a
eval (Div  t u) = eval t `div` eval u
eval (Plus t u) = eval t + eval u


-- Does it work ?

answer, bad :: Term
answer = Div (Div (Con 1972) (Con 2)) (Con 23)

bad  = Div (Con 1) (Con 0)


-- Adding our own exceptions

data E a = Raise String | OK a
   deriving Show


evalE           :: Term -> E Int
evalE (Con a)   = OK a
evalE (Div t u) =
     case evalE t of
         Raise e1 -> Raise e1
         OK a -> case evalE u of
                   Raise e2 -> Raise e2
                   OK b -> if b == 0
                          then Raise "Dividing by 0"
                          else OK $ a `div` b
{- evalE (Plus a1 a2) = ?? -}

-- Insn't it getting a bit annoying? to repeat eval/catch trick again and again

-- Variation 2: Now, with state

-- The state passing/transformer monad

type S b a  = b -> (a,b)

-- eval with a one cell accumulator, counting calls to Div

evalA             :: Term -> S Int Int
evalA (Con a)   s = (a,0)
evalA (Div t u) s = let (a,i) = evalA t s in
                        
:
     case evalE t of
         Raise e1 -> Raise e1
         OK a -> case evalE u of
                   Raise e2 -> Raise e2
                   OK b -> if b == 0
                          then Raise "Dividing by 0"
                          else OK $ a `div` b


{- From one cell to actual heaps is a long way, but we might get
   there. Do you have plans for the weekend? -}


{- Excercice: Design and evaluator supporting both Errors
   and once cell State like in the example above.
     Don't introduce a new datatype -}
