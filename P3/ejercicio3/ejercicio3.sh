# Script para el ejercicio 3, para P3 arq 2020-2021
# Autores: Pablo Izaguirre y Paula Samper

#!/bin/bash

# inicializar variables
Ninicio=$((256+256*9))  # tiene que ser 256+256*9
Nfinal=$((256+256*10))  # tiene que ser 256+256*10
Npaso=32                
Niter=4                 # tiene que ser 20
fDAT=mult.dat
fPNGC=mult_cache.png
fPNGT=mult_time.png
fAUXNORMAL=aux_normal_time.dat
fAUXTRASP=aux_trasp_time.dat

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
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat ./mult $N
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
    valgrind --tool=cachegrind --cachegrind-out-file=aux.dat ./mult_transpuesta $N
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
set output "mult_time.png"
plot "mult.dat" using 1:2 with lines lw 2 title "normal", \
     "mult.dat" using 1:5 with lines lw 2 title "trasp"
replot
quit
END_GNUPLOT

#grafica de escritura
gnuplot << END_GNUPLOT
set title "Normal-Trasp Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_cache.png"
plot "mult.dat" using 1:3 with lines lw 2 title "read normal", \
     "mult.dat" using 1:4 with lines lw 2 title "write normal", \
     "mult.dat" using 1:6 with lines lw 2 title "read Trasp", \
     "mult.dat" using 1:7 with lines lw 2 title "write Trasp"
replot
quit
END_GNUPLOT
