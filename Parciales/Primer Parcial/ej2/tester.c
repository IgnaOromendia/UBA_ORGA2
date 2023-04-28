#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej2.h"

#define N 20

static uint32_t a[N][N];
static uint32_t b[N][N];
static uint32_t c[N][N];

void shuffle(uint32_t max){
	for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++){
		    a[i][j] = (uint32_t) rand() % max;
            b[i][j] = (uint32_t) rand() % max;
            if ( j % 2 == 0){
                c[i][j] = a[i][j];
            }else{
                c[i][j] = b[i][j];
            }
        }
	}
}

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej2 =  "salida.propios.ej2.txt";
void test_ej2(char* filename);


int main() {
	srand(0);
    remove(filename_ej2);
	test_ej2(filename_ej2);
	return 0;
}


uint32_t shuffle_int(uint32_t min, uint32_t max){
	return (uint32_t) (rand() % (max + 1)) + min;
}

void test_ej2(char* filename) {
    
    void (*func_coincidencia)( uint8_t *, uint8_t *, uint32_t , 
                               uint8_t *);
    if (USE_ASM_IMPL){
        func_coincidencia = miraQueCoincidencia;
    }else{
        func_coincidencia = miraQueCoincidencia_c;
    }

    FILE* pfile;
    shuffle(INT32_MAX);
    RUN(filename, fprintf(pfile, "== Ejercicio 2 ==\n");) NL(filename)
    RUN(filename, fprintf(pfile, "== Iguales ==\n");) NL(filename)

    uint8_t *result = malloc(N*N);
    func_coincidencia((uint8_t*)a,(uint8_t*)a,N,result);

    for(int i=0;i<N;++i){
        for(int j=0;j<N;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*N +j]);)
        }
        NL(filename)
    }


    RUN(filename, fprintf(pfile, "\n== Distinto(random) ==\n");) NL(filename)

    func_coincidencia((uint8_t*)a,(uint8_t*)b,N,result);

    for(int i=0;i<N;++i){
        for(int j=0;j<N;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*N +j]);)
        }
        NL(filename)
    }

    RUN(filename, fprintf(pfile, "\n== Alternado 1==\n");) NL(filename)

    func_coincidencia((uint8_t*)c,(uint8_t*)b,N,result);

    for(int i=0;i<N;++i){
        for(int j=0;j<N;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*N +j]);)
        }
        NL(filename)
    }

    RUN(filename, fprintf(pfile, "\n== Alternado 2==\n");) NL(filename)

    func_coincidencia((uint8_t*)c,(uint8_t*)a,N,result);

    for(int i=0;i<N;++i){
        for(int j=0;j<N;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*N +j]);)
        }
        NL(filename)
    }

    free(result);
}

