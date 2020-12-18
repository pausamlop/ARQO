// ----------- Arqo P4-----------------------
// pescalar_par3
// Versión corregida cde pescalar_par1 usando reduction
//
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char **argv)
{
	int size;
	if(argc < 2) size = M;
	else size = atoll(argv[1]);
	
	int nproc;
	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	double sum=0;
     	
       
	A = generateVectorOne(size);
	B = generateVectorOne(size);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	
        nproc=omp_get_num_procs();
        //omp_set_num_threads(nproc);   
        printf("Se han lanzado %d hilos.\n",omp_get_max_threads());

	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	
    #pragma omp parallel for reduction (+:sum) if (size > 100000) 
	for(k=0;k<size;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
