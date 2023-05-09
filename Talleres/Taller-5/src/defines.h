/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Misc */
/* -------------------------------------------------------------------------- */
// Y Filas
#define SIZE_N 40
#define ROWS   SIZE_N

// X Columnas
#define SIZE_M 80
#define COLS   SIZE_M

/* Privilegios */
/* -------------------------------------------------------------------------- */

#define PRIV_0 0
#define PRIV_1 1
#define PRIV_2 2
#define PRIV_3 3

/* Present */
/* -------------------------------------------------------------------------- */

#define PRESENT_DISK 0
#define PRESENT_MEM 1

/* AVL */
/* -------------------------------------------------------------------------- */

#define AVL  1
#define NAVL 0

/* Granularity */
/* -------------------------------------------------------------------------- */

#define BYTE_GRAN 1
#define KB4_GRAN 0

/* D/B */
/* -------------------------------------------------------------------------- */

#define BIG     1
#define DEFAULT 0

/* L */
/* -------------------------------------------------------------------------- */

#define LONG  1
#define NLONG 0

/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT         35

#define GDT_IDX_NULL_DESC 0
#define GDT_IDX_CODE_0 1
#define GDT_IDX_CODE_3 2
#define GDT_IDX_DATA_0 3
#define GDT_IDX_DATA_3 4
#define GDT_IDX_VIDEO  5

/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_VIDEO  (GDT_IDX_VIDEO << 3)

/* COMPLETAR - Valores para los selectores de segmento de la GDT 
 * Definirlos a partir de los indices de la GDT, definidos más arriba 
 * Hint: usar operadores "<<" y "|" (shift y or) */

#define GDT_CODE_0_SEL (GDT_IDX_CODE_0 << 3)
#define GDT_DATA_0_SEL (GDT_IDX_DATA_0 << 3)
#define GDT_CODE_3_SEL (GDT_IDX_CODE_3 << 3) | PRIV_3
#define GDT_DATA_3_SEL (GDT_IDX_DATA_3 << 3) | PRIV_3

// Macros para trabajar con segmentos de la GDT.

// SEGM_LIMIT_4KIB es el limite de segmento visto como bloques de 4KIB
// principio del ultimo bloque direccionable.
#define GDT_LIMIT_4KIB(X)  (((X) / 4096) - 1)
#define GDT_LIMIT_BYTES(X) ((X)-1)

// Los ands se usan como mascaras
#define GDT_LIMIT_LOW(limit)  (uint16_t)(((uint32_t)(limit)) & 0x0000FFFF)
#define GDT_LIMIT_HIGH(limit) (uint8_t)((((uint32_t)(limit)) >> 16) & 0x0F)

#define GDT_BASE_LOW(base)  (uint16_t)(((uint32_t)(base)) & 0x0000FFFF)
#define GDT_BASE_MID(base)  (uint8_t)((((uint32_t)(base)) >> 16) & 0xFF)
#define GDT_BASE_HIGH(base) (uint8_t)((((uint32_t)(base)) >> 24) & 0xFF)

/* COMPLETAR - Valores de atributos */ 
#define DESC_CODE_DATA         (uint8_t)(1)
#define DESC_SYSTEM            (uint8_t)(0)
#define DESC_TYPE_EXECUTE_READ (uint8_t)(10)
#define DESC_TYPE_READ_WRITE   (uint8_t)(2)

/* COMPLETAR - Tamaños de segmentos */ 
#define FLAT_SEGM_SIZE (uint32_t)(1 << 20)
//#define VIDEO_SEGM_SIZE   TODO preguntar a que se refiere.


/* Direcciones de memoria */ 
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000


#endif //  __DEFINES_H__