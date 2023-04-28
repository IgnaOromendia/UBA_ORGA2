#ifndef EJ2_H
#define EJ2_H

#include <stdio.h> 		//encabezado de funciones de entrada y salida fopen, fclose, fgetc, printf, fprintf ...
#include <stdlib.h>		//biblioteca estándar, atoi, atof, rand, srand, abort, exit, system, NULL, malloc, calloc, realloc...
#include <stdint.h>		//contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...
#include <ctype.h>		//contiene funciones relacionadas a caracteres, isdigit, islower, tolower...
#include <string.h>		//contiene las funciones relacionadas a strings, memcmp, strcat, memset, memmove, strlen,strstr...
#include <math.h>		//define funciones matemáticas como cos, sin, abs, sqrt, log...
#include <stdbool.h>	//contiene las definiciones de datos booleanos, true (1), false (0)
#include <unistd.h>		//define constantes y tipos standard, NULL, R_OK, F_OK, STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO...
#include <assert.h>		//provee la macro assert que evalúa una condición, y si no se cumple provee información diagnóstica y aborta la ejecución

//*************************************
//Declaración de estructuras
//*************************************
typedef struct bgra_t {
    unsigned char b, g, r, a;
} __attribute__((packed)) bgra_t;

#define USE_ASM_IMPL 1


//*******************************
//Declaración de funciones de ej2
//*******************************
void miraQueCoincidencia( uint8_t *A, uint8_t *B, uint32_t N, 
                          uint8_t *laCoincidencia );
void miraQueCoincidencia_c( uint8_t *A, uint8_t *B, uint32_t N, 
                          uint8_t *laCoincidencia );

#endif
