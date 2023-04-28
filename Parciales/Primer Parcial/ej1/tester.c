#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej1.h"


#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej1 =  "salida.propios.ej1.txt";
void test_ej1a(char* filename);
void test_ej1b(char* filename);


int main() {
	srand(0);
    remove(filename_ej1);
	test_ej1a(filename_ej1);
	test_ej1b(filename_ej1);
	return 0;
}

#define ARRAY_SIZE 100
#define NUM_ARRAYS 50

uint32_t shuffle_int(uint32_t min, uint32_t max){
	return (uint32_t) (rand() % (max + 1)) + min;
}

void test_ej1a(char* filename) {
    
    uint32_t (*func_cuantos)(templo* , size_t );
    if (USE_ASM_IMPL){
        func_cuantos = cuantosTemplosClasicos;
    }else{
        func_cuantos = cuantosTemplosClasicos_c;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "== Ejercicio 1a ==\n");) NL(filename)

    for (int j=0; j<NUM_ARRAYS; ++j){
       templo* arrayTemplos = malloc(ARRAY_SIZE*sizeof(templo));

        for (int i=0; i<ARRAY_SIZE; ++i){
            arrayTemplos[i].colum_corto = shuffle_int(1,1024);
            if (shuffle_int(0,1))
                arrayTemplos[i].colum_largo = 2 * arrayTemplos[i].colum_corto + 1;
            else
                arrayTemplos[i].colum_largo = shuffle_int(1,2048);
        }
        RUN(filename, fprintf(pfile, "Clásicos %d: %d\n", j,func_cuantos(arrayTemplos, ARRAY_SIZE));)
        free(arrayTemplos);
    }
}


void test_ej1b(char* filename){
    
    templo* (*func_templos)(templo* , size_t );
    uint32_t (*func_cuantos)(templo* , size_t );
    if (USE_ASM_IMPL){
        func_templos = templosClasicos;
        func_cuantos = cuantosTemplosClasicos;
    }else{
        func_templos = templosClasicos_c;
        func_cuantos = cuantosTemplosClasicos_c;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "\n== Ejercicio 1b ==\n");) NL(filename)

    for (int j=0; j<NUM_ARRAYS; ++j){
       templo* arrayTemplos = malloc(ARRAY_SIZE*sizeof(templo));

        for (int i=0; i<ARRAY_SIZE; ++i){
            arrayTemplos[i].colum_corto = shuffle_int(1,1024);
            if (shuffle_int(0,1))
                arrayTemplos[i].colum_largo = 2 * arrayTemplos[i].colum_corto + 1;
            else
                arrayTemplos[i].colum_largo = shuffle_int(1,2048);
        }
        templo* clasicos = func_templos(arrayTemplos,ARRAY_SIZE);
        int arrayLen = func_cuantos(arrayTemplos, ARRAY_SIZE);

        RUN(filename, fprintf(pfile, "Array %d:[",j);)
        for (int i=0; i<arrayLen; ++i){
            RUN(filename, fprintf(pfile, "(%d, %d)", clasicos[i].colum_corto, clasicos[i].colum_largo);)
        }
        RUN(filename, fprintf(pfile, "]\n");)

        free(arrayTemplos);
        free(clasicos);
    }
}