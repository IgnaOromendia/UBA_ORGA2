#ifndef CHECKPOINTS_H
#define CHECKPOINTS_H

#include <stdint.h>	//contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...

typedef struct data_s{
    uint16_t a[8];
    uint16_t b[8];
    uint32_t c[8];
} data_t;

void invertirBytes_c(uint8_t* p, uint8_t n, uint8_t m);
void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m);
uint8_t checksum_c(void* array, uint32_t n);
uint8_t checksum_asm(void* array, uint32_t n);

#endif
