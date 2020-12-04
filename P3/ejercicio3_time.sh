# Script para el ejercicio 3, la parte de calcular el tiempo de ejecución, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

# inicializar variables
Ninicio=$((256+256*9))  # tiene que ser 256+256*9
Nfinal=$((256+256*10))  # tiene que ser 256+256*10
Npaso=32                
Niter=4                 # tiene que ser 20
fDAT=mult_time.dat
fPNGT=mult_time.png
fAUXNORMAL=aux_normal_time.dat
fAUXTRASP=aux_trasp_time.dat

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT
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
     "$fDAT" using 1:3 with lines lw 2 title "trasp"
replot
quit
END_GNUPLOT

END_GNUPLOT
