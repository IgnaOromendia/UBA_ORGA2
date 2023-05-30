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
#define NOT_AVL 0

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
#define NOT_LONG 0

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
#define GDT_OFF_VIDEO     (GDT_IDX_VIDEO << 3)

/* COMPLETAR - Valores para los selectores de segmento de la GDT 
 * Definirlos a partir de los indices de la GDT, definidos más arriba 
 * Hint: usar operadores "<<" y "|" (shift y or) */
// El selector de segemnto tiene 16 bits, los primeros 13 de indice, uno de ldt o gdt y los utlimos 2 de privilegio

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
#define FLAT_SEGM_SIZE  (uint32_t)((1 << 20) * 817)
#define VIDEO_SEGM_SIZE (uint32_t)(50 * 80 * 2)


/* Direcciones de memoria */ 
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000
// direccion fisica de la pagina de memoria compartida
#define SHARED 0x0001D000

/* MMU */
/* -------------------------------------------------------------------------- */
/* Definan:
VIRT_PAGE_OFFSET(X) devuelve el offset dentro de la página, donde X es una dirección virtual
VIRT_PAGE_TABLE(X)  devuelve la page table entry correspondiente, donde X es una dirección virtual
VIRT_PAGE_DIR(X)    devuelve el page directory entry, donde X es una dirección virtual
CR3_TO_PAGE_DIR(X)  devuelve el page directory, donde X es el contenido del registro CR3
MMU_ENTRY_PADDR(X)  devuelve la dirección física de la base de un page frame o de un page table, donde X es el campo de 20 bits en una PTE o PDE
dir virt = |10 bits de Directorio| 10 bits de Table | 12 de Offset|
*/

#define VIRT_PAGE_OFFSET(X) X & 0xFFF
#define VIRT_PAGE_TABLE(X)  (X >> 12) & 0x3FF
#define VIRT_PAGE_DIR(X)    (X >> 22) & 0x3FF
#define CR3_TO_PAGE_DIR(X)  X & 0xFFFFF000
#define MMU_ENTRY_PADDR(X)  X // TODO CHECKEAR VERACIDAD DE ESTE DEFINE

#define MMU_P (1 << 0)
#define MMU_W (1 << 1)
#define MMU_U (1 << 2)

#define PAGE_SIZE 4096

// direccion virtual del codigo
#define TASK_CODE_VIRTUAL 0x08000000
#define TASK_CODE_PAGES   2
#define TASK_STACK_BASE   0x08003000
#define TASK_SHARED_PAGE  0x08003000

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */
#define KERNEL_PAGE_DIR     (0x00025000)
#define KERNEL_PAGE_TABLE_0 (0x00026000)
#define KERNEL_STACK        (0x00025000)

#endif //  __DEFINES_H__