#!/bin/bash

fDAT1=5_tabla.dat

jpg[0]="SD.jpg"
jpg[1]="HD.jpg"
jpg[2]="FHD.jpg"
jpg[3]="4k.jpg"
jpg[4]="8k.jpg"

aux=1
aux2=8
mess[0]="RESULTADOS SD"
mess[1]="RESULTADOS HD"
mess[2]="RESULTADOS FHD"
mess[3]="RESULTADOS 4K"
mess[4]="RESULTADOS 8K"

rm -f $fDAT1
touch $fDAT1


echo "working"
for i in $(seq 0 4);do
    echo " "
    echo ">>>>>>>>>>>>>>>>>> ${mess[$i]}" >> $fDAT1

    timeserie=0
    time3=0
    time4=0
    time5=0
    time7=0

    for j in $(seq 1 8);do

        temp=$(./edgeDetector2 ${jpg[$i]} | grep "Tiempo" | awk '{print $2}')
        timeserie=$(echo "$timeserie + $temp"|bc -l)

        temp=$(./edgeDetector3 ${jpg[$i]} | grep "Tiempo" | awk '{print $2}')
        time3=$(echo "$time3 + $temp"|bc -l)

        temp=$(./edgeDetector4 ${jpg[$i]} | grep "Tiempo" | awk '{print $2}')
        time4=$(echo "$time4 + $temp"|bc -l)

        temp=$(./edgeDetector5 ${jpg[$i]} | grep "Tiempo" | awk '{print $2}')
        time5=$(echo "$time5 + $temp"|bc -l)

        temp=$(./edgeDetector7 ${jpg[$i]} | grep "Tiempo" | awk '{print $2}')
        time7=$(echo "$time7 + $temp"|bc -l)

    done

    timeserie=$(echo "$timeserie / $aux2"|bc -l)
    time3=$(echo "$time3 / $aux2"|bc -l)
    time4=$(echo "$time4 / $aux2"|bc -l)
    time5=$(echo "$time5 / $aux2"|bc -l)
    time7=$(echo "$time7 / $aux2"|bc -l)

    
    fps=$(echo "$aux / $timeserie"|bc -l)

    echo "tiempo edgeDetector2: $timeserie   " >> $fDAT1
    echo "fps edgeDetector2: $fps   " >> $fDAT1

    
    fps3=$(echo "$aux / $time3"|bc -l)
    speedup3=$(echo "$timeserie / $time3"|bc -l)

    echo "tiempo edgeDetector3: $time3   " >> $fDAT1
    echo "fps edgeDetector3: $fps3   " >> $fDAT1
    echo "speedup edgeDetector3: $speedup3   " >> $fDAT1

    
    fps4=$(echo "$aux / $time4"|bc -l)
    speedup4=$(echo "$timeserie / $time4"|bc -l)

    echo "tiempo edgeDetector4: $time4   " >> $fDAT1
    echo "fps edgeDetector4: $fps4   " >> $fDAT1
    echo "speedup edgeDetector4: $speedup4   " >> $fDAT1

    
    fps5=$(echo "$aux / $time5"|bc -l)
    speedup5=$(echo "$timeserie / $time5"|bc -l)

    echo "tiempo edgeDetector5: $time5   " >> $fDAT1
    echo "fps edgeDetector5: $fps5   " >> $fDAT1
    echo "speedup edgeDetector5: $speedup5   " >> $fDAT1

    
    fps7=$(echo "$aux / $time7"|bc -l)
    speedup7=$(echo "$timeserie / $time7"|bc -l)

    echo "tiempo edgeDetector7: $time7   " >> $fDAT1
    echo "fps edgeDetector7: $fps7   " >> $fDAT1
    echo "speedup edgeDetector7: $speedup7   " >> $fDAT1


done








