-- Estructuras de Datos y Algoritmos II
-- Trabajo Practico I
-- Realizado por: Alonso Pablo
--                Rivosecchi Alejandro

import Data.List

data NdTree p = Node (NdTree p) p (NdTree p) Int
                | Empty
    deriving(Eq, Ord, Show)
    
-- ord compara la n componente de dos puntos
-- cmp devuelve True si la n componente del primer punto es mayor o
-- igual a la del segundo, sino devuelve False.
class Punto p where
    dimension::p -> Int
    coord::Int -> p -> Double
    dist::p -> p -> Double
    dist p1 p2 =  sqrt (distAux ((dimension p1) -1) p1 p2)
    ord::Int -> (p -> p -> Ordering)
    cmp::Int -> p -> (p -> Bool)
    
    

-- Ejercicio 1
-- Enunciado a

-- distAux: Calcula el cuadrado de la distancia entre p1 y p2. Su primer
-- argumento es la dimension de p1 y p2 menos uno.
distAux::Punto p => Int -> p -> p -> Double        
distAux n p1 p2 | n == 0 = ((coord n p1) - (coord n p2) )^2 
                | n > 0 = ((coord n p1) - (coord n p2) )^2 + distAux (n-1) p1 p2 
                | otherwise = error "La dimension del Punto debe ser mayor a 0" 


-- Enunciado b

newtype Punto2d = P2d(Double, Double) deriving Show
newtype Punto3d = P3d(Double,Double,Double) deriving Show


instance Punto Punto2d where
    dimension p = 2
    
    coord 0 (P2d (x,_)) = x
    coord 1 (P2d (_,y)) = y
    coord _ _ = error "La coordenada es 0 o 1"
    
    ord 0 (P2d (x,_)) (P2d (y,_)) = compare x y
    ord 1 (P2d (_,x)) (P2d (_,y)) = compare x y
    ord _ _ _ = error "Punto de dos dimensiones, se puede ordenar solo con componente 0 o 1"
    
    cmp 0 (P2d (x,_)) (P2d (y,_)) = x >= y
    cmp 1 (P2d (_,x)) (P2d (_,y)) = x >= y
    cmp _ _ _= error "Punto de dos dimensiones, solo se puede comparar la componente 0 o 1" 
    
instance Punto Punto3d where
    dimension p = 3
    
    coord 0 (P3d (x,_,_)) = x
    coord 1 (P3d (_,y,_)) = y
    coord 2 (P3d (_,_,z)) = z
    coord _ _ = error "La coordenada es 0, 1 o 2"
    
    ord 0 (P3d (x,_,_)) (P3d (y,_,_)) = compare x y
    ord 1 (P3d (_,x,_)) (P3d (_,y,_)) = compare x y
    ord 2 (P3d (_,_,x)) (P3d (_,_,y)) = compare x y
    ord _ _ _ = error "Punto de tres dimensiones, se puede ordenar solo con componente 0, 1 o 2"
    
    cmp 0 (P3d (x,_,_)) (P3d (y,_,_)) = x >= y
    cmp 1 (P3d (_,x,_)) (P3d (_,y,_)) = x >= y
    cmp 2 (P3d (_,_,x)) (P3d (_,_,y)) = x >= y
    cmp _ _ _ = error "Punto de tres dimensiones, solo se puede comparar la componente 0, 1 o 2"


instance Eq Punto2d where
    (==) (P2d(x1,y1)) (P2d(x2,y2))  = x1 == x2 && y1 == y2

instance Eq Punto3d where
    (==) (P2d(x1,y1,z1)) (P2d(x2,y2,z2))  = x1 == x2 && y1 == y2 && z1 == z2
    
-- Ejercicio 2
fromList::Punto p => [p] -> NdTree p
fromList s = hacerArbol 0 s where
    hacerArbol _ []     = Empty
    hacerArbol n (x:xs) =  let eje = mod n (dimension x)
                               ordenada = sortBy (ord eje) (x:xs)
                               posMediana = div (length ordenada) 2
                               mediana = ordenada !! posMediana
                               parteIzq = takeWhile (cmp eje mediana) ordenada -- Su ult elemento es el correspondiente al nodo que estamos creando
                               -- Es menor o igual a todos los otros elementos en parteIzq.
                               listaSubArbolIzq = init parteIzq
                               valorNodo = last parteIzq
                               listaSubArbolDer = drop ((length listaSubArbolIzq) + 1) ordenada  
                           in
                           Node (hacerArbol (n+1)  listaSubArbolIzq) valorNodo (hacerArbol (n+1) listaSubArbolDer) eje



insertar::Punto p =>p -> NdTree p -> NdTree p
insertar p1 t = agregarNodo 0 p1 t (dimension p1) where
    agregarNodo n p1 Empty d = Node Empty p1 Empty n
    agregarNodo n p1 (Node lt x rt e) d | cmp e x p1 = Node (agregarNodo (mod (e+1) d) p1 lt d) x rt e 
                                        | otherwise  =  Node lt x (agregarNodo (mod (e+1) d) p1 rt d) e 



minNodo (Node lt2 x2 rt2 e2) e| e == e2 = if lt2 == Empty then x2
                                          else minNodo lt2 e
                              | otherwise = min (minNodo lt2 e) (minNodo rt2 e)


maxNodo (Nodo lt2 x2 rt2 e2) e| e == e2 if rt2 == Empty then x2
                                        else maxNodo rt2 e
                               |otherwise = max (maxNodo lt2) (maxNodo rt2)
 



eliminar::(Eq p,Punto p) =>p -> NdTree p -> NdTree p
eliminar p1 Empty = Empty
eliminar p1 (Node lt x rt e) | x == p1 = if rt /= Empty  then x = minNodo rt e where
                                                        minNodo (Node lt2 x2 rt2 e2) e| e == e2 |  
                                    
                             | cmp e x p1 = eliminar p1 lt
                             | otherwise = eliminar p1 rt















-- Puntos 2d
a = P2d(0,0)
b = P2d(5,7)
c = P2d(-1,-5)
d = P2d(-2,9)
e = P2d(0,6)                

ptos2d = [a,b,c,d,e]

res =insertar (P2d(6,9)) (fromList [a,c,b])

res2 = insertar (P2d(1,9)) res
  
-- Puntos 3d                           
aa = P3d(0,0,0)
bb = P3d(-1,2,-2)
cc = P3d(5,2,0)
dd = P3d(0,-2,-2)
ee = P3d(1,3,0)
ff = P3d(1,2,1)

ptos3d = [aa,bb,cc,dd,ee,ff]


