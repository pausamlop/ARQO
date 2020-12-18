#!/bin/bash

fTime=e4_5_tabla.dat
rm -f $fTime

for i in 1 2 4 6 7 8 9 10 12
do
    echo ">>>Ejecutando pi_par3.c con valor de padding: $i"
    salida=$(./pi_par3_v2 $i)
    tiempo=$(echo "$salida"|grep "Tiempo"|awk '{print $2}')
    echo "$salida"
    echo "$i    $tiempo" >> $fTime
done