#include "ejs.h"
#include "str.h"


void  strArrayAddLast(str_array_t* a, char* data) {
    if(a->size != a->capacity) {
        a->data[a->size] = strClone(data);
        a->size = a->size + 1;
    }
}

void strArrayPrint(str_array_t* a, FILE* pFile) {
    fprintf(pFile, "[");
    for(int i=0; i<a->size-1; i++) {
        strPrint(a->data[i], pFile);
        fprintf(pFile, ",");
    }
    if(a->size >= 1) {
        strPrint(a->data[a->size-1], pFile);
    }
    fprintf(pFile, "]");
}


void strArraySwap(str_array_t* a, uint8_t i, uint8_t j) {
    if(a->size > i && a->size > j) {
        void* temp = a->data[i];
        a->data[i] = a->data[j];
        a->data[j] = temp;
    }
}