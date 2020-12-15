#!/bin/bash

fTablaTiempo=tablaE3_tiempo_$1.dat
fTablaSpeedup=tablaE3_speedup_$1.dat

rm -f $fTablaTiempo
rm -f $fTablaSpeedup

echo "EJERCICIO 3: valor de n: $1" >> $fTablaTiempo
serie_time=$(./mult_transpuesta $1|grep 'time' | awk '{print $3}') >> $fTablaTiempo

echo "Tiempo serie: $serie_time" >> $fTablaTiempo

echo "Numero de hilos   bucle1      bucle2      bucle3" >> $fTablaTiempo

for i in $(seq 1 4);do
    export OMP_NUM_THREADS=$i
    bucle1_time=$(./mult_transpuesta_bucle1 $1|grep 'time' | awk '{print $3}')
    bucle2_time=$(./mult_transpuesta_bucle2 $1|grep 'time' | awk '{print $3}')
    bucle3_time=$(./mult_transpuesta_bucle3 $1|grep 'time' | awk '{print $3}')

    echo "$i                $bucle1_time    $bucle2_time    $bucle3_time" >> $fTablaTiempo
done

echo "EJERCICIO 3: valor de n: $1" >> $fTablaSpeedup
echo "Tiempo serie: $serie_time" >> $fTablaSpeedup
echo "Numero de hilos   bucle1      bucle2      bucle3" >> $fTablaSpeedup

tail -n 4 $fTablaTiempo | awk -v st=$serie_time '{print $1,"              ","   " st/$2,"   ", st/$3,"  ", st/$4}' >> $fTablaSpeedup