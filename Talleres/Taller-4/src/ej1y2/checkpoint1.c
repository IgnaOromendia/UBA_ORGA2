#include "checkpoints.h"

void invertirBytes_c(uint8_t* p, uint8_t n, uint8_t m){
    uint8_t p_n = p[n];
	p[n] = p[m];
    p[m] = p_n;
}

