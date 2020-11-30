# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
Ninicio=$((10000 + 1024 * 9))
Npaso=64
Nfinal=$((Ninicio + 1024))
Niter=20
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
fAUXSLOW=aux_slow_time.dat
fAUXFAST=aux_fast_time.dat

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG
rm -f $fAUXSLOW
rm -f $fAUXFAST

# generar el fichero DAT vacío
touch $fDAT
touch $fAUXSLOW
touch $fAUXFAST

echo "Running slow and fast..."
# bucle para N desde P hasta Q 

for i in $(seq 1 $Niter);do
	for N in $(seq $Ninicio $Npaso $Nfinal);do
		echo "N(slow): $N / $Nfinal..."
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')

		echo "$N	$slowTime" >> $fAUXSLOW
	done

	for N in $(seq $Ninicio $Npaso $Nfinal);do
		echo "N(fast): $N / $Nfinal..."
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		echo "$N	$fastTime" >> $fAUXFAST
	done
done

echo "Creado el archivo auxiliar:" #debug

sort  $fAUXSLOW #debug

echo "fast:" #debug

sort $fAUXFAST # debug

echo "Haciendo las medias..." #debug

# ahora hay que calcular las medias

for N in $(seq $Ninicio $Npaso $Nfinal);do
	slowTime_mean=$(cat $fAUXSLOW | grep $N | awk '{print $2}' | paste -sd+ |bc)
	echo "Suma de las slow: $slowTime_mean" #debug
	slowTime_mean=$(echo "$slowTime_mean / $Niter"|bc -l)

	fastTime_mean=$(cat $fAUXFAST | grep $N | awk '{print $2}' | paste -sd+ |bc)
	echo "Suma de las fast: $fastTime_mean" #debug
	fastTime_mean=$(echo "$fastTime_mean / $Niter"|bc -l)

	echo "Media de $N: $slowTime_mean	$fastTime_mean" #debug

	echo "$N	$slowTime_mean	$fastTime_mean" >> $fDAT
done

echo "Creado el archivo definitivo" #debug

cat $fDAT #debug

# borramos los archivos auxiliares

rm -f $fAUXSLOW
rm -f $fAUXFAST

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
