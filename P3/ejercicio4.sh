# Script para el ejercicio 4, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

# inicializar variables
Ninicio=$((2))
Nfinal=$((40))
Npaso=2
Niter=1
TamL1=4096
Vias=1
LineSize=64


fDAT=mult_e4.dat
fPNGC=mult_cache_e4.png
fPNGT=mult_time_e4.png
fAUXNORMAL=aux_normal_time_e4.dat
fAUXTRASP=aux_trasp_time_e4.dat

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT 
rm -f $fPNGC
rm -f $fPNGT
rm -f $fAUXNORMAL
rm -f $fAUXTRASP

# generar el fichero DAT vacío
touch $fDAT
touch $fAUXNORMAL
touch $fAUXTRASP

# TIEMPO

for i in $(seq 1 $Niter);do
	for N in $(seq $Ninicio $Npaso $Nfinal);do
		echo "N(normal): $N / $Nfinal..."
		normalTime=$(./mult $N | grep 'time' | awk '{print $3}')

		echo "$N	$normalTime" >> $fAUXNORMAL
	done

	for N in $(seq $Ninicio $Npaso $Nfinal);do
		echo "N(trasp): $N / $Nfinal..."
		traspTime=$(./mult_transpuesta $N | grep 'time' | awk '{print $3}')

		echo "$N	$traspTime" >> $fAUXTRASP
	done
done

# ahora hay que calcular las medias

for N in $(seq $Ninicio $Npaso $Nfinal);do
	normalTime_mean=$(cat $fAUXNORMAL | grep $N | awk '{print $2}' | paste -sd+ |bc)
	echo "Suma de las normal: $normalTime_mean" #debug
	normalTime_mean=$(echo "$normalTime_mean / $Niter"|bc -l)

	traspTime_mean=$(cat $fAUXTRASP | grep $N | awk '{print $2}' | paste -sd+ |bc)
	echo "Suma de las trasp: $traspTime_mean" #debug
	traspTime_mean=$(echo "$traspTime_mean / $Niter"|bc -l)

	echo "Media de $N: $normalTime_mean	$traspTime_mean" #debug

	echo "$N	$normalTime_mean	$traspTime_mean" >> $fDAT
done

# VALGRIND

#Normal
#bucle for cambiando el tamano de las matrices desde Ninicio hasta Nfinal con saltos de Npaso

for N in $(seq $Ninicio $Npaso $Nfinal);do
    echo "N: $N / $Nfinal..."
    #ejecutar normal con valgring modificanfo las caracteristicas de las caches
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat --I1=$TamL1,$Vias,$LineSize ./mult $N
    #obtener D1mr y D1mw y eliminar las comas
    D1mr=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $5}' | sed -e 's/,//g')
    D1mw=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $8}' | sed -e 's/,//g')

    #conseguir los datos anteriores
    TNormal=$(head -1 $fDAT |  awk '{print $2}')
    TTrasp=$(head -1 $fDAT |  awk '{print $3}')

    #borrar esa linea del fichero (la primera)
    sed -i -e "1d" $fDAT

    #anadirlo al fichero
    echo "$N $TNormal $D1mr $D1mw $TTrasp" >> $fDAT
done

#Trasp
#bucle for cambiando el tamano de las matrices desde Ninicio hasta Nfinal con saltos de Npaso

for N in $(seq $Ninicio $Npaso $Nfinal);do
    echo "N: $N / $Nfinal..."
    #ejecutar trasp con valgring modificanfo las caracteristicas de las caches
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat --I1=$TamL1,$Vias,$LineSize ./mult_transpuesta $N
    #obtener D1mr y D1mw y eliminar las comas
    D1mr=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $5}' | sed -e 's/,//g')
    D1mw=$(cg_annotate aux.dat | head -n 30 | grep "TOTALS" | awk '{print $8}' | sed -e 's/,//g')

    #conseguir los datos anteriores
    TNormal=$(head -1 $fDAT |  awk '{print $2}')
    D1mrNormal=$(head -1 $fDAT |  awk '{print $3}')
    D1mwNormal=$(head -1 $fDAT |  awk '{print $4}')
    TTrasp=$(head -1 $fDAT |  awk '{print $5}')

    #borrar esa linea del fichero (la primera)
    sed -i -e "1d" $fDAT

    #anadir todos los datos en una unica linea al final del fichero
    echo "$N    $TNormal    $D1mrNormal    $D1mwNormal    $TTrasp    $D1mr    $D1mw" >> $fDAT

done

rm -f $fAUXNORMAL
rm -f $fAUXTRASP

# GNUPLOT
echo "Generating plot..."

#grafica de lectura
gnuplot << END_GNUPLOT
set title "Normal-Trasp Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGT"
plot "$fDAT" using 1:2 with lines lw 2 title "normal", \
     "$fDAT" using 1:5 with lines lw 2 title "trasp"
replot
quit
END_GNUPLOT

#grafica de escritura
gnuplot << END_GNUPLOT
set title "Normal-Trasp Misses. L1: $TamL1 Bytes, Vias: $Vias, LineSize: $LineSize Bytes"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGC"
plot "$fDAT" using 1:3 with lines lw 2 title "read normal", \
     "$fDAT" using 1:6 with lines lw 2 title "read Trasp"
replot
quit
END_GNUPLOT
