#ifndef CHECKPOINTS_H
#define CHECKPOINTS_H
/*
Sobre Ifndef
======
ifndef es una construcción de pre compilación que sólo incorpora el texto entre "#ifndef SYMBOL ... #endif sólo si el símbolo SYMBOL aún no fue definido
se suele utilizar esta combinación de 
#ifndef SYMBOL 
#define SYMBOL
para que el pre-procesador sólo evalúe una vez los encabezados antes de comenzar la compilación

Sobre includes
==============
Recuerden que los include son directivas que incluyen,
en este caso, las definiciones y encabezados de las funciones de uso común que queremos 
utilizar en nuestro programa
*/
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

typedef struct complex_item_str{
    uint64_t w;    
    uint32_t x;
    uint64_t y;
    uint32_t z;
} complex_item;

typedef struct  __attribute__((__packed__)) packed_complex_item_str{
    uint64_t w;    
    uint32_t x;
    uint64_t y;
    uint32_t z;
} packed_complex_item;

//****************************************
//Declaración de funciones de checkpoint 2
//****************************************

// devuelve el resultado de la operación x1 - x2 + x3 - x4
uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);

// devuelve el resultado la operación x1 - x2 + x3 - x4, usando obligatoriamente para las operaciones 
// las funciones provistas sumar_c y restar_c
int32_t alternate_sum_4_using_c(uint32_t x1,uint32_t x2,uint32_t x3,uint32_t x4);

// devuelve el resultado la operación x1 - x2 + x3 - x4. Esta función no crea ni el epílogo ni el prólogo
uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);

// devuelve el resultado de la operación x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8
uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);

// Hace la multiplicación x1 * f1 y el resultado se almacena en destination. Los dígitos decimales del resultado se eliminan mediante truncado
void product_2_f(uint32_t * destination, uint32_t x1, float f1);

//****************************************
//Declaración de funciones de checkpoint 3
//****************************************

// Devuelve la suma del atributo z de todos los complex_item's del array
uint32_t complex_sum_z(complex_item *arr, uint32_t arr_length);

// Devuelve la suma del atributo z de todos los packed_complex_item's del array
uint32_t packed_complex_sum_z(packed_complex_item *arr, uint32_t arr_length);

// Convierte todos los parámetros a double, realiza la multiplicación de todos ellos y 
// aloja el resultado en destination. 
// Nota de implementación: Ir multiplicando todos los floats en primer lugar, luego, 
// ir multiplicando ese resultado con cada entero, uno a uno.
void product_9_f(double * destination
, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
, uint32_t x9, float f9);

//****************************************
//Declaración de funciones de checkpoint 4
//****************************************

/* String */

// Compara dos strings en orden lexicográfico. Ver https://es.wikipedia.org/wiki/Orden_lexicografico.
// Debe retornar: 
// 0 si son iguales
// 1 si a < b
//-1 si a > b
int32_t strCmp(char* a, char* b);

// Genera una copia del string pasado por parámetro. El puntero pasado siempre es válido
// aunque podría corresponderse a la cadena vacía.
char* strClone(char* a);

// Borra el string pasado por parámetro. Esta función es equivalente a la función free.
void strDelete(char* a);

// Escribe el string en el stream indicado a través de pFile. Si el string es vacío debe escribir "NULL"
void strPrint(char* a, FILE* pFile);

// Retorna la cantidad de caracteres distintos de cero del \emph{string} pasado por parámetro. 
uint32_t strLen(char* a);

//***********************************
//Declaración de funciones auxiliares
//***********************************

uint32_t sumar_c(uint32_t a, uint32_t b); 
uint32_t restar_c(uint32_t a, uint32_t b); 

#endif
