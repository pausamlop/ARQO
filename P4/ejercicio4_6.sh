#!/bin/bash

fTime=e4_5_tabla.png
rm -f $fTime

n=100

tiempo4=0
tiempo5=0
for i in $(seq 1 $n);
do
    echo ">>>Bucle $i/$n"
    t4=$(./pi_par4|grep "Tiempo"|awk '{print $2}')
    t5=$(./pi_par5|grep "Tiempo"|awk '{print $2}')
    echo "$t4   $t5"
    tiempo4=$(echo "$tiempo4 + $t4"|bc -l)
    tiempo5=$(echo "$tiempo5 + $t5"|bc -l)
done

media4=$(echo "$tiempo4/$n"|bc -l)
echo "Media pi_par4.c: $media4"

media5=$(echo "$tiempo5/$n"|bc -l)
echo "Media pi_par5.c: $media5"