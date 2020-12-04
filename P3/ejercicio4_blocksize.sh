# Script para el ejercicio 4, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

# inicializar variables
Binicio=$((32))
Bfinal=$((1024))
Bpaso=2
Niter=1
TamL1=4096
Vias=1
LineSize=64
N=$((256*4))


fDAT=mult_e4_blocksize.dat
fPNG=mult_cache_e4_blocksize.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT 
rm -f $fPNGC
rm -f $fPNGT

# generar el fichero DAT vacío
touch $fDAT

# VALGRIND

#Trasp
#bucle for cambiando el tamano de las matrices desde Ninicio hasta Nfinal con saltos de Npaso

for ((LineSize = Binicio ; LineSize <= Bfinal ; LineSize *= Bpaso)); do
    echo "LineSize: $LineSize / $Bfinal..."
    #ejecutar trasp con valgring modificanfo las caracteristicas de las caches
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat --I1=$TamL1,$Vias,$LineSize --D1=$TamL1,$Vias,$LineSize --LL=8388608,1,64 ./mult_transpuesta $N
    #obtener D1mr y D1mw y eliminar las comas
    D1mr=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $5}' | sed -e 's/,//g')
    D1mw=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $8}' | sed -e 's/,//g')

    #anadir todos los datos en una unica linea al final del fichero
    echo "$LineSize   $D1mr    $D1mw" >> $fDAT

done

# GNUPLOT
echo "Generating plot..."


#grafica de escritura
gnuplot << END_GNUPLOT
set title "Trasp Misses. L1: $TamL1 Bytes, N: $N, Vias: $Vias"
set ylabel "Number of Misses"
set xlabel "Blocks size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "read", \
     "$fDAT" using 1:3 with lines lw 2 title "write"
replot
quit
END_GNUPLOT
