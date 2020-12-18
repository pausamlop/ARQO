#!/bin/bash

fRES=2_aux.dat
fDAT1=2_time.dat
fDAT2=2_speedup.dat
fPNG1=2_time.png
fPNG2=2_speedup.png


# borrar los ficheros y pngs anteriores
rm -f $fPNG1
rm -f $fPNG2
rm -f $fRES
rm -f $fDAT1
rm -f $fDAT2
touch $fRES
touch $fDAT2
touch $fDAT1
touch $fPNG1
touch $fPNG2

echo "EJERCICIO 2" >> $fRES
echo "Resultado de usar critical" >> $fRES
./pescalar_par0 >> $fRES
echo "Resultado de usar atomic" >> $fRES
./pescalar_par2 >> $fRES
echo "Resultado de usar reduction" >> $fRES
./pescalar_par3 >> $fRES

# EJERCICIO 2.5


size[0]=15000000
size[1]=50000000
size[2]=100000000
size[3]=200000000
size[4]=400000000

data=(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)
old=(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)
su=(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)
var=5

echo "PRUEBAS" >> $fRES

#recorremos los tamaños
for j in $(seq 0 4);do

    #recorremos las cores
    for i in $(seq 1 8);do
        export OMP_NUM_THREADS=$i
        echo "Ejecutando size: ${size[$j]}, numero de threads: $i"
        if [ $i -eq 1 ];then

            for k in $(seq 0 4);do
                aux=$(./pescalar_serie ${size[$j]} | grep "Tiempo" | awk '{print $2}')
                data[$i]=$(echo "${data[$i]} + $aux"|bc -l)
            done
        else
            for k in $(seq 0 4);do
                aux=$(./pescalar_par3 ${size[$j]})
                echo "$aux"
                aux=$(echo "$aux"|grep "Tiempo" | awk '{print $2}')
                data[$i]=$(echo "${data[$i]} + $aux"|bc -l)
            done
        fi
        data[$i]=$(echo "${data[$i]} / $var"|bc -l)
        
    done

    # cada tamaño con sus 8 tiempos correspondientes
    echo "${size[$j]} ${data[1]} ${data[2]} ${data[3]} ${data[4]} ${data[5]} ${data[6]} ${data[7]} ${data[8]}" >> $fDAT1

    # si no es el primero calculamos el speedup
    if [ $j -ne 0 ];then
        for k in $(seq 1 8);do
            su[$k]=$(echo "${data[$k]} / ${old[$k]} "|bc -l)
        done
        echo "${size[$j]} ${su[1]} ${su[2]} ${su[3]} ${su[4]} ${su[5]} ${su[6]} ${su[7]} ${su[8]}" >> $fDAT2
    fi

    for i in $(seq 1 8);do
        old[$i]=${data[$i]}
        data[$i]=0.0
    done

    
done


#grafica de lectura
gnuplot << END_GNUPLOT
set title "Execution Time"
set ylabel "Execution time (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "2_time.png"
plot "2_time.dat" using 1:2 with lines lw 2 title "1 thread", \
     "2_time.dat" using 1:3 with lines lw 2 title "2 threads", \
     "2_time.dat" using 1:4 with lines lw 2 title "3 threads", \
     "2_time.dat" using 1:5 with lines lw 2 title "4 threads", \
     "2_time.dat" using 1:6 with lines lw 2 title "5 threads", \
     "2_time.dat" using 1:7 with lines lw 2 title "6 threads", \
     "2_time.dat" using 1:8 with lines lw 2 title "7 threads", \
     "2_time.dat" using 1:9 with lines lw 2 title "8 threads"
replot
quit
END_GNUPLOT

#grafica de lectura
gnuplot << END_GNUPLOT
set title "Speed up"
set ylabel "Speed up"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "2_speedup.png"
plot "2_speedup.dat" using 1:2 with lines lw 2 title "1 thread", \
     "2_speedup.dat" using 1:3 with lines lw 2 title "2 threads", \
     "2_speedup.dat" using 1:4 with lines lw 2 title "3 threads", \
     "2_speedup.dat" using 1:5 with lines lw 2 title "4 threads", \
     "2_speedup.dat" using 1:6 with lines lw 2 title "5 threads", \
     "2_speedup.dat" using 1:7 with lines lw 2 title "6 threads", \
     "2_speedup.dat" using 1:8 with lines lw 2 title "7 threads", \
     "2_speedup.dat" using 1:9 with lines lw 2 title "8 threads"
replot
quit
END_GNUPLOT