# Script para el ejercicio 3, hacer plot de los write misses, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

fPNG=mult_misses_write.png
fDAT=mult.dat

# GNUPLOT
echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Normal-Trasp Write Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:4 with lines lw 2 title "write normal", \
     "$fDAT" using 1:7 with lines lw 2 title "write trasp"
replot
quit