#!/bin/bash

P=4
Extra=$((512))
Ninicio=$((512+$P))
Nfinal=$((1024+512+$P+$Extra))
Nincr=64
Niter=3

fTime=e3_tiempo.dat
fTimePNG=e3_grafica_tiempo.png
fSpeedupPNG=e3_grafica_speedup.png

rm -f $fTime
rm -f $fSpeedupPNG
rm -f $fTimePNG

touch $fSpeedupPNG
touch $fTimePNG

for n in $(seq $Ninicio $Nincr $Nfinal);do
    echo "n: $n/$Nfinal"
    serie_time=0
    par_time=0
    for i in $(seq 1 $Niter);do
        echo "  iteracion: $i"
        st=$(./mult_transpuesta $n|grep 'time' | awk '{print $3}')
        pt=$(./mult_transpuesta_bucle3 $n|grep 'time' | awk '{print $3}')
        serie_time=$(echo "$serie_time + $st"|bc -l)
        par_time=$(echo "$par_time + $pt"|bc -l)
    done
    serie_time=$(echo "$serie_time/$Niter"|bc -l)
    par_time=$(echo "$par_time/$Niter"|bc -l)
    speedup=$(echo "$serie_time / $par_time"|bc -l)

    echo "$n    $serie_time $par_time   $speedup" >> $fTime
done

echo "Generating time plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Execution Time Serie-Paralelo"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fTimePNG"
plot "$fTime" using 1:2 with lines lw 2 title "serie", \
     "$fTime" using 1:3 with lines lw 2 title "paralelo"
replot
quit
END_GNUPLOT

echo "Generating speedup plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Speedup Paralelo vs Serie"
set ylabel "Speedup"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fSpeedupPNG"
plot "$fTime" using 1:4 with lines lw 2 title "Speedup"
replot
quit
END_GNUPLOT