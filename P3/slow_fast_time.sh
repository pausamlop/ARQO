# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
Ninicio=$((1024 * 2))
Npaso=64
Nfinal=$((Ninicio + 1024))
Niter=30
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
fAUX=aux_slow_fast_time.dat

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG
rm -f $fAUX

# generar el fichero DAT vacío
touch $fDAT
touch $fAUX

echo "Running slow and fast..."
# bucle para N desde P hasta Q 

for i in $(seq 1 $Niter);do
	for N in $(seq $Ninicio $Npaso $Nfinal);do
		echo "N: $N / $Nfinal..."
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		echo "$N	$slowTime	$fastTime" >> $fAUX
	done
done

echo "Creado el archivo auxiliar:" #debug

sort  $fAUX #debug

echo "Haciendo las medias..." #debug

# ahora hay que calcular las medias

for N in $(seq $Ninicio $Npaso $Nfinal);do
	slowTime_mean=$(cat $fAUX | grep $N | awk '{print $2}' | paste -sd+ |bc)
	echo "Suma de las slow: $slowTime_mean" #debug
	slowTime_mean=$(echo "$slowTime_mean / $Niter"|bc -l)

	fastTime_mean=$(cat $fAUX | grep $N | awk '{print $3}' | paste -sd+ |bc)
	fastTime_mean=$(echo "$fastTime_mean / $Niter"|bc -l)

	echo "Media de $N: $slowTime_mean	$fastTime_mean" #debug

	echo "$N	$slowTime_mean	$fastTime_mean" >> $fDAT
done

echo "Creado el archivo definitivo" #debug

cat $fDAT #debug

# for N in $(seq $Ninicio $Npaso $Nfinal);do
# 	echo "N: $N / $Nfinal..."
	
# 	# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
# 	# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
# 	# tercera columna (el valor del tiempo). Dejar los valores en variables
# 	# para poder imprimirlos en la misma línea del fichero de datos
# 	slowTime=$(./slow $N | grep 'time' | awk '{print $3}')
# 	fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

# 	echo "$N	$slowTime	$fastTime" >> $fDAT
# done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
