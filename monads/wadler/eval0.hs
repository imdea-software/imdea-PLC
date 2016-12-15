{-  IMDEA PLC Meeting 1 -}

-- Haskell Code from P. Wadler's Monads for Functional Programming

module Basic where


import Prelude

{- The algebraic datatype of Constants and Divisions: a binary tree
with Int leaves. Fancy stuff. -}

data Term = Con Int
     | Div Term Term
     | Plus Term Term
     deriving Show

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
                          then Raise "I ain't gonna divide by 0 \n"
                          else OK $ a `div` b
{- evalE (Plus a1 a2) = FILL ME!! -}

-- Insn't it getting a bit annoying? to repeat eval/catch trick again
-- and again

-- Variation 2: Now, with state

-- The state passing/transformer monad

type S b a  = b -> (a,b)

-- eval with a one cell accumulator, counting calls to Div

evalA              :: Term -> S Int Int
evalA (Con a)    s = (a,0)
evalA (Div t u)  s = let (a,i) = evalA t s in
                     let (b,j) = evalA u i
                     in  (a `div` b, i + j + 1)
evalA (Plus t u) s = let (a,i) = evalA t s in
                     let (b,j) = evalA u i
                     in  (a + b, i + j)

{- From one cell to actual heaps is a long way, but we might get
   there. Do you have plans for the weekend? -}

{- Excercice 1: Implement a smarter datatype of terms.
     hint: Ever heard of high order sintax? -}
    
{- Excercice 2:

Design and evaluator supporting both Errors and once cell State like
     in the example above.

 hint: Don't introduce a new datatype

-}

-- Variation 3: Stone Age Output

type O a = (String, a)

line     :: Term -> Int -> String
line t a  = "eval (" ++ show t ++ " <= " ++ show a ++ "\n"

evalT   :: Term -> O Int
evalT s@(Con a) = (line s a, a)
evalT s@(Div t v) =
   let (t1, a) = evalT t in
   let (t2, b) = evalT v in
   let       c = a `div` b  
   in  (t1 ++ t1 ++ line s c, c)

-- Actually running our traces with Haskell's I/O

runT m = let (a ,_) = evalT m
         in putStr a



