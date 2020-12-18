#!/bin/bash

fDAT1=5_pruebas.dat

rm -f $fDAT1
touch $fDAT1

var=12
aux1=0
aux2=0
aux3=0
aux4=0
aux5=0
aux6=0

# apartado 2


for j in $(seq 1 12);do
    a=$(./edgeDetector "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    b=$(./edgeDetector2 "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    c=$(./edgeDetector3 "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    d=$(./edgeDetector4 "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    e=$(./edgeDetector5 "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    f=$(./edgeDetector6 "4k.jpg" | grep "Tiempo" | awk '{print $2}')
    
    aux1=$(echo "$aux1 + $a"|bc -l)
    aux2=$(echo "$aux2 + $b"|bc -l)
    aux3=$(echo "$aux3 + $c"|bc -l)
    aux4=$(echo "$aux4 + $d"|bc -l)
    aux5=$(echo "$aux5 + $e"|bc -l)
    aux6=$(echo "$aux6 + $f"|bc -l)

done

aux1=$(echo "$aux1 / $var"|bc -l)
aux2=$(echo "$aux2 / $var"|bc -l)
aux3=$(echo "$aux3 / $var"|bc -l)
aux4=$(echo "$aux4 / $var"|bc -l)
aux5=$(echo "$aux5 / $var"|bc -l)
aux6=$(echo "$aux6 / $var"|bc -l)


echo "edgeDetector:     $aux1" >> $fDAT1
echo "edgeDetector2:    $aux2" >> $fDAT1
echo "edgeDetector3:    $aux3" >> $fDAT1
echo "edgeDetector4:    $aux4" >> $fDAT1
echo "edgeDetector5:    $aux5" >> $fDAT1
echo "edgeDetector6:    $aux6" >> $fDAT1

