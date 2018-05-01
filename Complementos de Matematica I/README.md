# Graficador de grafos 

Basado en el estudio realizado por Thomas M. J. Fruchterman y Edward M. Reingold en [Graph  Drawing  by  Force-directed  Placement](www.stat.cmu.edu/~brian/780/bibliography/00 layout and rendering/fruchterman-reingold.pdf).

Este programa grafica un grafo representado en un archivo cuya primer linea es un entero N que es la
cantidad de nodos, las proximas N lineas son los nombres de los nodos y las proximas 0 <= M lineas
son M aristas, que tienen la pinta x y, que significa que hay una arista entre x e y.
 
Esta hecho en Python2 y requiere [Gnuplot.py Python package](http://gnuplot-py.sourceforge.net/),
que implementa la comunicacion con [gnuplot](http://www.gnuplot.info/) (también requerido). Gnuplot.py necesita [NumPy package](http://www.numpy.org/).

El funcionamiento general del programa es:

Se lee el archivo y se procesan los datos.

Se disponen los nodos en una posicion al azar.

Se realizan iteraciones en las que en cada una se calcula la fuerza
de atraccion de cada nodo (solamente con sus vecinos) y la fuerza de
repulsion de cada nodo (con todos los nodos). Luego se ajusta cada nodo
de acuerdo a las fuerzas de atraccion y repulsion, con un limite que esta dado
por la temperatura.

La primer mitad de las iteraciones la temperatura ira aumentando y en la segunda
mitad esta ira banajando.

Las temperaturas iniciales, las funciones enfriar y calentar y la constante C se obtuvieron de manera experimental.

En cada iteracion, una vez calculada la nueva posicion de todos los nodos, se guarda
en grafo.data la informacion de los nodos, su posicion y las aristas de manera
tal que gnuplot los pueda interpretar.

Luego mediante gnuplot se grafica el grafo en pantalla.

El directorio grafos contiene varios grafos definidos para probar el programa, creados por Damian Ariel.

Para correr el programa basta con:
* python2 GraficadorDeGrafos.py GRAFO

Para obtener mas ayuda de los parametros opcionales use:
* python2 GraficadorDeGrafos.py -h
