# Script para el ejercicio 2, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

# inicializar variables
Ninicio=6608 #deberia ser 6608
Nfinal=7120 #deberia ser 7120
Npaso=64
fPNR=cache_lectura.png
fPNW=cache_escritura.png


# borrar los ficheros y pngs anteriores
rm -f $fPNGR
rm -f $fPNGW

# FICHEROS

#bucle for tamano cache
for size in 1024 2048 4096 8192;do

  #diccionario de ficheros
  file[$size]=cache_$size.dat
  #borrar el fichero anterior si existía
  rm -f ${file[$size]}
  #creoa fichero nuevo vacio
  touch ${file[$size]}

  #Slow
  #bucle for cambiando el tamano de las matrices desde Ninicio hasta Nfinal con saltos de Npaso
  for N in $(seq $Ninicio $Npaso $Nfinal);do
    echo "N: $N / $Nfinal..."
    #ejecutar slow con valgring modificanfo las caracteristicas de las caches
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./slow $N
    #obtener D1mr y D1mw
    D1mr=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $5}')
    D1mw=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $8}')
    #anadirlo al fichero
    echo "$N $D1mr $D1mw" >> ${file[$size]}
  done

  #Fast
  #bucle for cambiando el tamano de las matrices desde Ninicio hasta Nfinal con saltos de Npaso
  for N in $(seq $Ninicio $Npaso $Nfinal);do
    echo "N: $N / $Nfinal..."
    #ejecutar fast con valgring modificanfo las caracteristicas de las caches
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./fast $N
    #obtener D1mr y D1mw y eliminar las comas
    D1mr=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $5}' | sed -e 's/,//g')
    D1mw=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $8}' | sed -e 's/,//g')
    #obtener los datos D1mr y D1mw del caso slow para el mismo tamano, previamente guardados en el fichero
    #sera la primera  linea del fichero ya que a ,edida que las leemos, las eliminamos
    #para anadir la version definitiva al final
    #eliminar sus comas con sed
    A=$(head -1 ${file[$size]} |  awk '{print $2}' | sed -e 's/,//g')
    B=$(head -1 ${file[$size]} |  awk '{print $3}' | sed -e 's/,//g')
    #borrar esa linea del fichero (la primera)
    sed -i -e "1d" ${file[$size]}
    #anadir todos los datos en una unica linea al final del fichero
    echo "$N    $A    $B    $D1mr    $D1mw" >> ${file[$size]}

  done
done

# GNUPLOT
echo "Generating plot..."

#grafica de lectura
gnuplot << END_GNUPLOT
set title "Slow-Fast Read Misses"
set ylabel "Read Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "cache_lectura.png"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "1024B slow", \
     "cache_1024.dat" using 1:4 with lines lw 2 title "1024B fast", \
     "cache_2048.dat" using 1:2 with lines lw 2 title "2048B slow", \
     "cache_2048.dat" using 1:4 with lines lw 2 title "2048B fast", \
     "cache_4096.dat" using 1:2 with lines lw 2 title "4096B slow", \
     "cache_4096.dat" using 1:4 with lines lw 2 title "4096B fast", \
     "cache_8192.dat" using 1:2 with lines lw 2 title "8192B slow", \
     "cache_8192.dat" using 1:4 with lines lw 2 title "8192B fast"
replot
quit
END_GNUPLOT

#grafica de escritura
gnuplot << END_GNUPLOT
set title "Slow-Fast Write Misses"
set ylabel "Write Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "cache_escritura.png"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "1024B slow", \
     "cache_1024.dat" using 1:5 with lines lw 2 title "1024B fast", \
     "cache_2048.dat" using 1:3 with lines lw 2 title "2048B slow", \
     "cache_2048.dat" using 1:5 with lines lw 2 title "2048B fast", \
     "cache_4096.dat" using 1:3 with lines lw 2 title "4096B slow", \
     "cache_4096.dat" using 1:5 with lines lw 2 title "4096B fast", \
     "cache_8192.dat" using 1:3 with lines lw 2 title "8192B slow", \
     "cache_8192.dat" using 1:5 with lines lw 2 title "8192B fast"
replot
quit
END_GNUPLOT
