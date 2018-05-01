#!/usr/bin/python2

# Autor: Alejandro Rivosecchi

import Gnuplot
import random
import argparse
import sys
from time import sleep
from math import ceil

# Definicion de constantes
ARCHIVO = 'grafo.data'
ANCHO = 1000
ALTO = 1000
ANCHOMIN = 10
ANCHOMAX = 990
ALTOMIN = 10
ALTOMAX = 990
TEMPENFRIAMIENTOINIC = (((ANCHOMAX-ANCHOMIN)+(ALTOMAX-ALTOMIN))/2)/50
TEMPCALENTAMIENTOINIC = (((ANCHOMAX-ANCHOMIN)+(ALTOMAX-ALTOMIN))/2)/200
CDefault = 0.7
FONDODefault = 'grey'
COLNOMBRENODODefault = 'red'
COLLINEASDefault = 'blue2'
IteracionesDefault = 100
MoverLabel = ANCHO/100 # Constante para que el nombre del nodo no quede sobre el nodo

# LeerArchivo
# Proposito: leer archivo que posee la informacion del grafo
# y devolver el grafo representado como lista
# Asignatura: String -> ([Char],[(Char,Char)])
def LeerArchivo(direccion):
    V = []
    E = []
    with open(direccion,'r') as f:
        N = int(f.readline())
        for linea in f:
            if(N>0):
                Indice = linea.find("\n")
                V.append(linea[0:Indice])
                N -= 1
            else:
                Indice1erNodo = linea.find(" ")
                Indice2doNodo = linea.find("\n")
                if(Indice2doNodo == -1): Indice2doNodo = len(linea)
                TempArista = (linea[0:Indice1erNodo],linea[Indice1erNodo+1:Indice2doNodo])
                E.append(TempArista)
    return (V,E)

# DistVectorPos
# Proposito: vector es de la pinta [x,y,w,z], calculo distancia del vector (x,y)
# Asignatura: [float, float, float, float] -> float
def DistVectorPos(vector): 
    return (vector[0]**2+vector[1]**2)**.5

# DistVectorDisp
# Proposito: vector es de la pinta [x,y,w,z], calculo distancia del vector (w,z)
# Asignatura: [float, float, float, float] -> float
def DistVectorDisp(vector): 
    return (vector[2]**2+vector[3]**2)**.5

# DistVector
# Proposito: Calculo la distancia de vector
# Asignatura: [float, float] -> float
def DistVector(vector): 
    dist = (vector[0]**2+vector[1]**2)**.5
    if(dist == 0): dist = 0.001
    return dist
    
# FuerzaAtraccion
# Proposito: Calcula fuerza de atraccion
# Asignatura: [float, float] -> float
def FuerzaAtraccion(distancia, k):
    return ( distancia**2/k )

# FuerzaRepulsion
# Proposito: Calcula fuerza de repulsion
# Asignatura: [float, float] -> float
def FuerzaRepulsion(distancia, k):
    return ( k**2/distancia )

# enfriar
# Proposito: Formula de enfriamiento
# Asignacion: integer -> integer
def enfriar(t):
    return t*.99

# Notificar
# Proposito: Escribir string recibida en pantalla si Verbose se declaro True
# Proposito: String -> Nada
def notificar(string):
    if(Verbose): print(string)
    return

# calentar
# Proposito: Formula de calentamiento
# Asignacion: integer -> integer
def calentar(t):
    return t*1.001

def Graficador(Grafo):
    V, E = Grafo
    t = TEMPCALENTAMIENTOINIC
    area = (ANCHOMAX-ANCHOMIN) * (ALTOMAX - ALTOMIN)
    CantNodos = len(Grafo[0])
    if CantNodos <= 0:
        print('La cantidad de nodos debe ser mayor a 0')
        return
#   Cada nodo lo representare con una lista [x,y,w,z]
#    pos = (x,y) sera la posicion del nodo en el grafico
#    disp = (w,z) sera el vector de desplazamiento del nodo
    Nodos ={}
# Les doy una posicion inicial al azar a los nodos.
    for x in V:
        Nodos[x] = ( [random.randint(ANCHOMIN, ANCHOMAX), random.randint(ALTOMIN, ALTOMAX), 0 , 0] )
    k = ((area/CantNodos)**0.5)*C
    notificar('Posicion asignada a los nodos al azar.')
    '''
    Inicio gnuplot y le paso algunas configuraciones
    '''
    proc = Gnuplot.Gnuplot()
# defino el linestyle 1 para los puntos del extremo del grafico. Seran blancos para que no se vean
    proc('set style line 1 lc rgb \'{0}\' lt 1 lw 2 pt 7 ps 1.5'.format(FONDO))
# defino el linestyle 2 para las propiedades visuales del grafo
    proc('set style line 2 lc rgb \'{0}\' lw 2 pt 7 ps 2'.format(COLLINEAS))
# elimino ejes del grafico
    proc('unset xtics; unset ytics')
# color del fondo
    proc('set object rectangle from screen 0,0 to screen 1,1 behind fillcolor rgb \'{0}\' fillstyle solid noborder'.format(FONDO))
    notificar('gnuplot inicializado correctamente.\nComienzan las iteraciones.\nIteraciones concluidas: ')
    for i in range(Iteraciones):
        for ClaveV, v in Nodos.iteritems(): # ClaveV es la clave del Nodo. v es de la pinta [x,y,w,z], calculo fuerza repulsion
            v[2] = 0; v[3] = 0 # (w,z) = (0,0)
            for ClaveU, u in Nodos.iteritems():
                if (ClaveU == ClaveV): continue
                VectorDiferencia = ( v[0]-u[0], v[1]-u[1] ) # Vector diferencia entre pos de v y pos de u
                FzaRep = FuerzaRepulsion(DistVector(VectorDiferencia), k) # Fuerza de repulsion entre u y v
                v[2] += (VectorDiferencia[0]/DistVector(VectorDiferencia))*FzaRep # Actualizo variable x del vector desplazamiento de v
                v[3] += (VectorDiferencia[1]/DistVector(VectorDiferencia))*FzaRep # Actualizo variable y del vector desplazamiento de v
        for x, y in E: # calculo las fuerzas de atraccion
            if( x == y ): continue # si es una arista bucle continuo
            VectorResta = ( Nodos[x][0]-Nodos[y][0], Nodos[x][1]-Nodos[y][1] ) 
            FzaAtr = FuerzaAtraccion(DistVector(VectorResta), k) # Fuerza de atraccion entre nodos x e y
            VectorRestaUnitario = ( VectorResta[0]/DistVector(VectorResta), VectorResta[1]/DistVector(VectorResta) )
            Nodos[x][2] -= VectorRestaUnitario[0] * FzaAtr
            Nodos[x][3] -= VectorRestaUnitario[1] * FzaAtr 
            Nodos[y][2] += VectorRestaUnitario[0] * FzaAtr
            Nodos[y][3] += VectorRestaUnitario[1] * FzaAtr
# Las cuatro lineas superiores actualizan el vector desplazamiento de x e y
        for ClaveV, v in Nodos.iteritems(): # Muevo cada vertice segun su vector 
# desplazamiento y verifico que no salga del sector de graficado
            Distancia=DistVectorDisp(v)
            if( Distancia == 0): continue # si el vector desplazamiento
            # tiene longitud 0 entonces no hay que desplazar
            v[0] += (v[2]/Distancia)*min(Distancia,t)
            v[1] += (v[3]/Distancia)*min(Distancia,t)
            v[0] = min(ANCHOMAX,max(ANCHOMIN,v[0]))
            v[1] = min(ALTOMAX,max(ALTOMIN,v[1]))
            if( i<Iteraciones/2 ):
                t = calentar(t)
            else:
                if( i==ceil(Iteraciones/2) ):
                    t = TEMPENFRIAMIENTOINIC
                t = enfriar(t)
        ''' 
        Escribo en el ARCHIVO los puntos para que sean graficados 
        '''
        # Abro el ARCHIVO borrando su contenido y escribo los puntos extremos del area a graficar
        f = open(ARCHIVO,"w")
        f.write('0 0\n\n')
        f.write('0 ')
        f.write(str(ALTO))
        f.write('\n\n')
        f.write(str(ANCHO))
        f.write(' ')
        f.write(str(ALTO))
        f.write('\n\n')
        f.write(str(ANCHO))
        f.write(' 0\n\n\n')
        proc('unset label')
        for ClaveX, x in Nodos.iteritems():
            proc('set label "{0}" at {1},{2} front textcolor rgb \'{3}\' font",20"'.format(ClaveX, x[0]+MoverLabel, x[1], COLNOMBRENODO)) # grafico nombre del nodo
            f.write(str(x[0])) # grafico todos los nodos por si alguno no tiene aristas
            f.write(' ')
            f.write(str(x[1]))
            f.write('\n')
            f.write('\n')
        for x, y in E:
            if( x == y ): continue # si la arista es un bucle no la grafico
            f.write(str(Nodos[x][0]))
            f.write(' ')
            f.write(str(Nodos[x][1]))
            f.write('\n')
            f.write(str(Nodos[y][0]))
            f.write(' ')
            f.write(str(Nodos[y][1]))
            f.write('\n')
            f.write('\n')
        f.close()
# grafico los datos que estan en ARCHIVO con plotting style 'linespoints' usando linestyle 1
# notitle hace que no salga el nombre del archivo
        if(i==0):
            proc('plot \'{0}\' index 0 with linespoints ls 1 notitle, \'{0}\' index 1 with linespoints ls 2 notitle'.format(ARCHIVO))
        if(i!=0):
            proc('replot')
        if(Verbose): 
            print i+1,
            sys.stdout.write('') # para que no haga salto de linea
            print " ",
            sys.stdout.write('') # para que no haga salto de linea
            sys.stdout.flush() # flush de stdout
        sleep(0.05)
    notificar("")
    raw_input('Presiona Enter para cerrar')
    return



def main():
    # Inicializamos los argumentos de linea de comando que aceptamos
    parser = argparse.ArgumentParser()

    # Archivo del cual leer el grafo
    parser.add_argument('direccion', 
                        help='Archivo del cual leer el grafo a dibujar')
    # Verbosidad, opcional, False por defecto
    parser.add_argument('-v', '--verbose', 
                        action='store_true', 
                        help='Muestra mas informacion')
    # Cantidad de iteraciones, opcional
    parser.add_argument('--iters', type=int, 
                        help='Cantidad de iteraciones a efectuar', 
                        default=IteracionesDefault)
    # Constante C, opcional
    parser.add_argument('--CteC', type=float, 
                        help='Constante C', 
                        default=CDefault)
    # Color del fondo
    parser.add_argument('--ColFon', 
                        help='Color del fondo',
                        default=FONDODefault)
    # Color nombres de los nodos
    parser.add_argument('--ColNomNod', 
                        help='Color nombres de los nodos',
                        default=COLNOMBRENODODefault)
    # Color de las aristas y de los nodos
    parser.add_argument('-ColArYNod', 
                        help='Color de las aristas y de los nodos',
                        default=COLLINEASDefault)
                        
    args = parser.parse_args() # Funcionamiento del argparse

    # Seteo los valores introducidos por la terminal de manera global
    global C, FONDO, COLNOMBRENODO, COLLINEAS, Iteraciones, Verbose
    C = args.CteC
    FONDO = args.ColFon
    COLNOMBRENODO = args.ColNomNod
    COLLINEAS = args.ColArYNod
    Iteraciones = args.iters
    Verbose = args.verbose
    
    Grafo = LeerArchivo(args.direccion)
    notificar('Archivo leido correctamente.')
    Graficador(Grafo)
    
if __name__ == '__main__':
    main()
