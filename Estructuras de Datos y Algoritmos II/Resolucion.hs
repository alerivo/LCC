-- Estructuras de Datos y Algoritmos II
-- Trabajo Practico I
-- Realizado por: Alonso Pablo
--                Rivosecchi Alejandro

import Data.List -- Funciones de listas
import Control.Exception.Base -- Funcion assert para testing

-- Estructura para representar arboles binarios de puntos
data NdTree p = Node (NdTree p) p (NdTree p) Int
                | Empty
    deriving(Eq, Ord, Show)

-- Clase Punto con algunas funciones asociadas.
-- ord compara la n componente de dos puntos
-- cmp devuelve True si la n componente del primer punto es mayor o
-- igual a la del segundo, sino devuelve False.
class Punto p where
    dimension :: p -> Int
    coord :: Int -> p -> Double
    ord :: Int -> p -> p -> Ordering
    ord n p1 p2 = compare (coord n p1) (coord n p2)
    cmp :: Int -> p -> (p -> Bool)
    cmp n p1 p2 = (ord n p1 p2) == GT || (ord n p1 p2) == EQ
-- Ejercicio 1
-- Enunciado a
    dist :: p -> p -> Double
    dist p1 p2 = sqrt (dist' (dimension p1 -1) p1 p2) where
        dist' n p1 p2 | n == 0 = ((coord n p1) - (coord n p2) )^2 
                        | n > 0  = ((coord n p1) - (coord n p2) )^2 + dist' (n-1) p1 p2 
                        | otherwise = error "La dimension del Punto debe ser mayor a 0" 

-- Enunciado b

-- Defino nuevos tipos de dato para puntos de 2 y 3 dimensiones.
newtype Punto2d = P2d(Double, Double) deriving (Show, Eq)
newtype Punto3d = P3d(Double,Double,Double) deriving (Show, Eq)

-- Se define Punto2d instancia de la clase Punto
instance Punto Punto2d where
    dimension p = 2
    coord 0 (P2d (x,_)) = x
    coord 1 (P2d (_,y)) = y
    
-- Se define Punto3d instancia de la clase Punto
instance Punto Punto3d where
    dimension p = 3
    coord 0 (P3d (x,_,_)) = x
    coord 1 (P3d (_,y,_)) = y
    coord 2 (P3d (_,_,z)) = z

-- Ejercicio 2

-- fromList toma una lista de Puntos y devuelve un NdTree (arbol binario
-- de Puntos) con los puntos que estan en la lista. 
fromList :: Punto p => [p] -> NdTree p
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
                           in Node (hacerArbol (n+1)  listaSubArbolIzq) valorNodo (hacerArbol (n+1) listaSubArbolDer) eje

-- Ejercicio 3

-- inserta un Punto en el NdTree, por mas que ya este agregado
insertar :: Punto p => p -> NdTree p -> NdTree p
insertar p t = agregarNodo 0 p t (dimension p) where
    agregarNodo n p Empty d = Node Empty p Empty n
    agregarNodo n p (Node lt x rt e) d | cmp e x p = Node (agregarNodo (mod (e+1) d) p lt d) x rt e 
                                        | otherwise  =  Node lt x (agregarNodo (mod (e+1) d) p rt d) e 

-- Ejercicio 4

-- minNodo devuelve el punto con el menor valor en la componente eje del NdTree pasado
minNodo :: (Eq p, Punto p) => NdTree p -> Int -> p
minNodo (Node lt x rt e) eje | eje == e = if lt == Empty
                                                then x
                                                else minNodo lt eje
                             | otherwise = let minizq = if lt /= Empty then (minNodo lt eje) else x
                                               minder = if rt /= Empty then (minNodo rt eje) else x
                                               minambos = if cmp eje minizq minder
                                                              then minder
                                                              else minizq
                                           in if cmp eje x minambos
                                                  then minambos
                                                  else x
                                                
-- maxNodo devuelve el nodo con el mayor valor en la componente eje del NdTree pasado
maxNodo :: (Eq p, Punto p) => NdTree p -> Int -> p
maxNodo (Node lt x rt e) eje | eje == e = if rt == Empty
                                                then x
                                                else maxNodo rt eje
                             | otherwise = let maxizq = if lt /= Empty then (maxNodo lt eje) else x
                                               maxder = if rt /= Empty then (maxNodo rt eje) else x
                                               maxambos = if cmp eje maxizq maxder
                                                              then maxizq 
                                                              else maxder 
                                           in if cmp eje x maxambos
                                                  then x 
                                                  else maxambos

-- eliminar elimina la primer aparicion que encuentra en el NdTree del Punto pasado
eliminar :: (Eq p,Punto p) => p -> NdTree p -> NdTree p
eliminar p Empty = Empty
eliminar p t@(Node lt x rt e) | x == p = if rt /= Empty
                                            then let reemplazo = minNodo rt e
                                                     (Node lt2 x2 rt2 e2) = eliminar reemplazo t
                                                 in (Node lt2 reemplazo rt2 e)
                                            else if lt /= Empty 
                                                    then let reemplazo = maxNodo lt e
                                                             (Node lt2 x2 rt2 e2) = eliminar reemplazo t
                                                         in (Node lt2 reemplazo rt2 e)
                                                    else Empty
                              | cmp e x p = (Node (eliminar p lt) x rt e)
                              | otherwise = (Node lt x (eliminar p rt) e)

-- Ejercicio 5

-- Rect representa un rectangulo en el plano a partir de dos puntos, que
-- son los extremos de alguna de sus dos diagonales.
type Rect = (Punto2d, Punto2d)

-- minxRec devuelve la posicion del lado vertical izquierdo del rectangulo
minxRect :: Rect -> Double
minxRect (P2d (x1,y1), P2d (x2,y2)) = min x1 x2

-- maxxRec devuelve la posicion del lado vertical derecho del rectangulo
maxxRect :: Rect -> Double
maxxRect (P2d (x1,y1), P2d (x2,y2)) = max x1 x2

-- minyRec devuelve la posicion del lado horizontal inferior del rectangulo
minyRect :: Rect -> Double
minyRect (P2d (x1,y1), P2d (x2,y2)) = min y1 y2

-- maxyRec devuelve la posicion del lado horizontal superior del rectangulo
maxyRect :: Rect -> Double
maxyRect (P2d (x1,y1), P2d (x2,y2)) = max y1 y2

-- estaDentro devuelve True si el punto esta contenido en Rect y False sino.
estaDentro :: Punto2d -> Rect -> Bool
estaDentro (P2d (x,y)) rec = let minx = minxRect rec
                                 maxx = maxxRect rec
                                 miny = minyRect rec
                                 maxy = maxyRect rec
                             in (x>=minx && x<=maxx && y>=miny && y<=maxy)

-- ortogonalSearch devuelve una lista de puntos con los puntos pertencientes
-- al NdTree contenidos en en rectangulo pasado
ortogonalSearch :: NdTree Punto2d -> Rect -> [Punto2d]
ortogonalSearch Empty _ = []
ortogonalSearch (Node lt p rt e) rec =
    let ptoRecMax = (P2d (maxxRect rec, maxyRect rec))
        ptoRecMin = (P2d (minxRect rec, minyRect rec))
    in
-- Si el punto esta dentro del rectangulo hay que seguir buscando en
-- ambos subarboles salvo que la componente del eje asociado sea igual al
-- maximo del rectangulo, en ese caso hay que observar solo subarbol izquierdo.
    if estaDentro p rec
        then if (ord e p ptoRecMax) == EQ
            then p:ortogonalSearch lt rec
            else p:ortogonalSearch lt rec++ortogonalSearch rt rec
-- Si el punto no esta dentro del rectangulo, la componente del eje que
-- tiene asociado puede ser: menor a la del minimo del rectangulo, mayor
-- al minimo y menor al maximo o mayor al maximo.
        else if (ord e p ptoRecMin) == LT
            then ortogonalSearch rt rec-- Caso punto menor al minimo del rectangulo
            else if (ord e p ptoRecMax) == GT || (ord e p ptoRecMax) == EQ
                then ortogonalSearch lt rec -- Caso punto mayor o igual al maximo del rectangulo
                else ortogonalSearch lt rec ++ ortogonalSearch rt rec-- Caso punto mayor o igual al minimo y menor al maximo del rectangulo 

-- Puntos 2d
a = P2d(0,0)
b = P2d(5,7)
c = P2d(-1,-5)
d = P2d(-2,9)
e = P2d(0,6)                

ptos2d = [a,b,c,d,e]
arbol2d = (fromList ptos2d)
arbol2d2 = insertar (P2d(6,9)) arbol2d

-- Puntos 3d                           
aa = P3d(0,0,0)
bb = P3d(-1,2,-2)
cc = P3d(5,2,0)
dd = P3d(0,-2,-2)
ee = P3d(1,3,0)
ff = P3d(1,2,1)

ptos3d = [aa,bb,cc,dd,ee,ff]
arbol3d = (fromList ptos3d)

main = do

-- Inicio testing
    print (assert (estaDentro (P2d(0.5,0.5)) (P2d(1,0), P2d(0,1)) == True) "Test exitoso")
    print (assert (estaDentro (P2d(1,0)) (P2d(1,0), P2d(0,1)) == True) "Test exitoso")
    print (assert (estaDentro (P2d(5,0)) (P2d(1,0), P2d(0,1)) == False) "Test exitoso")
    
    print (assert (fromList ([]::[Punto2d]) == Empty) "Test exitoso")
    print (assert (fromList ([]::[Punto3d]) == Empty) "Test exitoso")
    print (assert (fromList ptos2d == (Node (Node (Node Empty (P2d (-1.0,-5.0)) Empty 0) (P2d (0.0,0.0)) (Node Empty (P2d (-2.0,9.0)) Empty 0) 1) (P2d (0.0,6.0)) (Node Empty (P2d (5.0,7.0)) Empty 1) 0) ) "Test exitoso")
    print (assert (fromList ptos3d == (Node (Node (Node (Node Empty (P3d (0.0,-2.0,-2.0)) Empty 0) (P3d (0.0,0.0,0.0)) Empty 2) (P3d (-1.0,2.0,-2.0)) (Node Empty (P3d (1.0,3.0,0.0)) Empty 2) 1) (P3d (1.0,2.0,1.0)) (Node Empty (P3d (5.0,2.0,0.0)) Empty 1) 0)) "Test exitoso")
 
    print (assert (insertar (P2d(0,0)) Empty ==  (Node Empty (P2d(0,0)) Empty 0)) "Test exitoso")
    print (assert (insertar (P3d(0,0,0)) Empty ==  (Node Empty (P3d(0,0,0)) Empty 0)) "Test exitoso")
    print (assert (insertar (P2d(6,9)) arbol2d == (Node (Node (Node Empty (P2d (-1.0,-5.0)) Empty 0) (P2d (0.0,0.0)) (Node Empty (P2d (-2.0,9.0)) Empty 0) 1) (P2d (0.0,6.0)) (Node Empty (P2d (5.0,7.0)) (Node Empty (P2d (6.0,9.0)) Empty 0) 1) 0)) "Test exitoso") 
    print (assert (insertar (P3d(3,1,9)) arbol3d == (Node (Node (Node (Node Empty (P3d (0.0,-2.0,-2.0)) Empty 0) (P3d (0.0,0.0,0.0)) Empty 2) (P3d (-1.0,2.0,-2.0)) (Node Empty (P3d (1.0,3.0,0.0)) Empty 2) 1) (P3d (1.0,2.0,1.0)) (Node (Node Empty (P3d (3,1,9)) Empty 2) (P3d (5.0,2.0,0.0)) Empty 1) 0)) "Test exitoso")
    
    print (assert (eliminar (P2d(0,0)) Empty == Empty) "Test exitoso")
    print (assert (eliminar (P3d(0,0,0)) Empty == Empty) "Test exitoso")
    print (assert (eliminar (P2d(-1,-1)) arbol2d2 == arbol2d2) "Test exitoso")
    print (assert (eliminar (P2d(6,9)) arbol2d2 == (Node (Node (Node Empty (P2d (-1.0,-5.0)) Empty 0) (P2d (0.0,0.0)) (Node Empty (P2d (-2.0,9.0)) Empty 0) 1) (P2d (0.0,6.0)) (Node Empty (P2d (5.0,7.0)) Empty 1) 0)) "Test exitoso")
    print (assert (eliminar (P2d(-1,-5)) arbol2d2 == (Node (Node Empty (P2d (0.0,0.0)) (Node Empty (P2d (-2.0,9.0)) Empty 0) 1) (P2d (0.0,6.0)) (Node Empty (P2d (5.0,7.0)) (Node Empty (P2d (6.0,9.0)) Empty 0) 1) 0)) "Test exitoso")
    print (assert (eliminar (P2d(0,6)) arbol2d2 == (Node (Node (Node Empty (P2d (-1.0,-5.0)) Empty 0) (P2d (0.0,0.0)) (Node Empty (P2d (-2.0,9.0)) Empty 0) 1) (P2d (5.0,7.0)) (Node Empty (P2d (6.0,9.0)) Empty 1) 0)) "Test exitoso")
    print (assert (eliminar (P3d(-1,-1,-1)) arbol3d == arbol3d) "Test exitoso")
    print (assert (eliminar (P3d(0,-2,-2)) arbol3d == (Node (Node (Node Empty (P3d (0.0,0.0,0.0)) Empty 2) (P3d (-1.0,2.0,-2.0)) (Node Empty (P3d (1.0,3.0,0.0)) Empty 2) 1) (P3d (1.0,2.0,1.0)) (Node Empty (P3d (5.0,2.0,0.0)) Empty 1) 0) ) "Test exitoso")
    print (assert (eliminar (P3d(1,2,1)) arbol3d == (Node (Node (Node (Node Empty (P3d (0.0,-2.0,-2.0)) Empty 0) (P3d (0.0,0.0,0.0)) Empty 2) (P3d (-1.0,2.0,-2.0)) (Node Empty (P3d (1.0,3.0,0.0)) Empty 2) 1) (P3d (5.0,2.0,0.0)) Empty 0) ) "Test exitoso")
  
    print (assert (ortogonalSearch arbol2d2 (P2d(4,6),P2d(6,10)) == [P2d (5.0,7.0),P2d (6.0,9.0)]) "Test exitoso")
    print (assert (ortogonalSearch arbol2d2 (P2d(8,2),P2d(7,1)) == []) "Test exitoso")
    print (assert (ortogonalSearch arbol2d2 (P2d(4,6),P2d(5.5,7.2)) == [P2d (5.0,7.0)]) "Test exitoso")
    print (assert (ortogonalSearch arbol2d2 (P2d(-4,-6),P2d(10,20)) == [P2d (0.0,6.0),P2d (0.0,0.0),P2d (-1.0,-5.0),P2d (-2.0,9.0),P2d (5.0,7.0),P2d (6.0,9.0)]) "Test exitoso")

-- Fin testing


