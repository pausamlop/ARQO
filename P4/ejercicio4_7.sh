#!/bin/bash

n=100

tiempo6=0
tiempo7=0
for i in $(seq 1 $n);
do
    echo ">>>Bucle $i/$n"
    t6=$(./pi_par6|grep "Tiempo"|awk '{print $2}')
    t7=$(./pi_par7|grep "Tiempo"|awk '{print $2}')
    echo "$t6   $t7"
    tiempo6=$(echo "$tiempo6 + $t6"|bc -l)
    tiempo7=$(echo "$tiempo7 + $t7"|bc -l)
done

media6=$(echo "$tiempo6/$n"|bc -l)
echo "Media pi_par6.c: $media6"

media7=$(echo "$tiempo7/$n"|bc -l)
echo "Media pi_par7.c: $media7"