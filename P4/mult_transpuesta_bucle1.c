#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo4.h"

void compute(float **matrixA, float **matrixB, float **mult, int n);
void printMatrix(float **m, int n);

int main(int argc, char *argv[]){

    int n;
	float **mA=NULL, **mB=NULL, **mult=NULL;
	struct timeval fin,ini;

	//printf("Word size: %ld bits\n",8*sizeof(float));

	if( argc!=2 )
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n=atoi(argv[1]);
	mA=generateMatrix(n);
    mB=generateMatrix(n);
    mult=generateEmptyMatrix(n);

	if( !mA || !mB )
	{
		return -1;
	}

    // printf("Matriz A:\n");
    // printMatrix(mA, n);
    // printf("Matriz B:\n");
    // printMatrix(mB, n);
	
	gettimeofday(&ini,NULL);

    /* Main computation */
	compute(mA, mB, mult, n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	/*printf("Total: %lf\n",res);*/
	
    // printf("Resultado:\n");
    // printMatrix(mult, n);

	freeMatrix(mA);
    freeMatrix(mB);
    freeMatrix(mult);
	return 0;
}

void compute(float **matrixA, float **matrixB, float **mult, int n){
    
    int i, j, k;

    float aux;

    // transponemos la matriz b:

    for(i = 0; i < n; i++){
        for(j = i + 1; j < n; j++){
            aux = matrixB[i][j];
            matrixB[i][j] = matrixB[j][i];
            matrixB[j][i] = aux;
        }
    }
    
    for(i = 0; i < n; i++){
        for(j = 0; j < n; j++){
            mult[i][j] = 0;
            #pragma omp parallel for shared(matrixA, matrixB, mult, n)
            for(k = 0; k < n; k++){
                mult[i][j] += matrixA[i][k] * matrixB[j][k];
            }
        }
    }
}

void printMatrix(float **m, int n){
    int i,j;

    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            printf("%f ", m[i][j]);
        }
        printf("\n");
    }
}