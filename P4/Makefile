LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -lm -Wall -D_GNU_SOURCE -fopenmp -O3

.PHONY: clean all

all: omp1 omp2 pescalar_serie pescalar_par1 pescalar_par2 pescalar_par3 pescalar_par3_v2 pescalar_par0 edgeDetector edgeDetector2 edgeDetector3 edgeDetector4 edgeDetector5 edgeDetector6 edgeDetector7 mult_transpuesta mult_transpuesta_bucle1 mult_transpuesta_bucle2 mult_transpuesta_bucle3 pi_serie pi_par1 pi_par2 pi_par3 pi_par3_v2 pi_par4 pi_par5 pi_par6 pi_par7 clear

omp1: omp1.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

omp2: omp2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_serie: pescalar_serie.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par0: pescalar_par0.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)
	
pescalar_par1: pescalar_par1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par2: pescalar_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par3: pescalar_par3.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par3_v2: pescalar_par3_v2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

edgeDetector: edgeDetector.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector.c $(LIBS)
	
edgeDetector2: edgeDetector2.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector2.c $(LIBS)

edgeDetector3: edgeDetector3.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector3.c $(LIBS)

edgeDetector4: edgeDetector4.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector4.c $(LIBS)

edgeDetector5: edgeDetector5.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector5.c $(LIBS)

edgeDetector6: edgeDetector6.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector6.c $(LIBS)

edgeDetector7: edgeDetector7.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector7.c $(LIBS)

mult_transpuesta: mult_transpuesta.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

mult_transpuesta_bucle1: mult_transpuesta_bucle1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

mult_transpuesta_bucle2: mult_transpuesta_bucle2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

mult_transpuesta_bucle3: mult_transpuesta_bucle3.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_serie: pi_serie.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par1: pi_par1.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par2: pi_par2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par3: pi_par3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par3_v2: pi_par3_v2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par4: pi_par4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par5: pi_par5.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par6: pi_par6.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par7: pi_par7.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)


stb_image.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

stb_image_write.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

clean:
	rm -f *.o *~ omp1 omp2 pescalar_serie pescalar_par1 pescalar_par2 pescalar_par3 pescalar_par0 edgeDetector edgeDetector2 edgeDetector3 edgeDetector4 edgeDetector5 edgeDetector6 edgeDetector7 mult_transpuesta mult_transpuesta_bucle1 mult_transpuesta_bucle2 mult_transpuesta_bucle3 pi_serie pi_par1 pi_par2 pi_par3 pi_par3_v2 pi_par4 pi_par5 pi_par6 pi_par7
	
clear:
	rm -f *.o *~
