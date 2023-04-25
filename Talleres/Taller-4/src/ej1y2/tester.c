#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <float.h>

#include "test-utils.h"
#include "checkpoints.h"

#define ARR_LENGTH  4
#define ROLL_LENGTH 16

static uint32_t x[ROLL_LENGTH];
static double   f[ROLL_LENGTH];

void shuffle(uint32_t max){
	for (int i = 0; i < ROLL_LENGTH; i++) {
		x[i] = (uint32_t) rand() % max;
	}
}

uint32_t shuffle_int(uint32_t min, uint32_t max){
		return (uint32_t) (rand() % max) + min;
}

/**
 * Tests checkpoint 1
 */

//void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m)

TEST(test_invertirBytes) {
	for (int i = 0; i < 100; i++) {
        uint8_t* test_bytes_c = (uint8_t*) malloc(16);
        uint8_t* test_bytes_asm = (uint8_t*) malloc(16);
        shuffle(256);
        uint8_t m = shuffle_int(0,16);
        uint8_t n = shuffle_int(0,16);
        for (int k = 0; k < 16; k++){
            test_bytes_c[k] = x[k];
            test_bytes_asm[k] = x[k];
        }
        
		sprintf(assert_name, "invertirBytes_asm(test_bytes, %u, %u)", n,m);
        invertirBytes_c(test_bytes_c, n, m);
        invertirBytes_asm(test_bytes_asm, n, m);

		TEST_ASSERT_EQUALS_ARRAY(uint8_t, test_bytes_c,test_bytes_asm,16);

        if(*test__fallo){

            for(uint32_t j = 0; j < 16; j++){
                printf("test_bytes_c[%2u] = %3u\t", j, test_bytes_c[j]);
                printf("test_bytes_asm[%2u] = %3u\t", j, test_bytes_asm[j]);
                printf("%s\n", (test_bytes_c[j] == test_bytes_asm[j])? "OK": "FAIL");
            }
            
            free(test_bytes_c);
            free(test_bytes_asm);
            return;
        }
        free(test_bytes_c);
        free(test_bytes_asm);
	}
}

/**
 * Tests checkpoint 2
 */

TEST(test_checksum_ok) {
	for (int i = 0; i < 100; i++) {
        uint32_t array_size = shuffle_int(1,20);
        data_t* test_data = (data_t*) malloc(sizeof(data_t)*array_size);
        for(uint32_t j = 0; j < array_size; j++){
            shuffle(1000);
            for (int k = 0; k < 8; k++){
                test_data[j].a[k] = x[k];
                test_data[j].b[k] = x[k+8];
                test_data[j].c[k] = ((uint32_t) test_data[j].a[k] + (uint32_t) test_data[j].b[k])*8;
            }
        }
		sprintf(assert_name, "checksum_asm(test_data, %u)", array_size);

		TEST_ASSERT_EQUALS(uint32_t, checksum_c(test_data, array_size), checksum_asm(test_data, array_size));

        if(*test__fallo){

            for(uint32_t j = 0; j < array_size; j++){
                for (int k = 0; k < 8; k++){
                    printf("test_data[%2u].a[%d] = %3u\t", j, k, test_data[j].a[k]);
                    printf("test_data[%2u].b[%d] = %3u\t", j, k, test_data[j].b[k]);
                    printf("test_data[%2u].c[%d] = %3u\t", j, k, test_data[j].c[k]);
                    printf("%s\n", test_data[j].c[k] ==  ((uint32_t) test_data[j].a[k] + (uint32_t) test_data[j].b[k])*8? "OK": "FAIL");
                }
            }
            free(test_data);
            return;
        }
        free(test_data);
	}
}

TEST(test_checksum_almost_never_ok) {
	for (int i = 0; i < 100; i++) {
        uint32_t array_size = shuffle_int(1,20);
        data_t* test_data = (data_t*) malloc(sizeof(data_t)*array_size);
        for(uint32_t j = 0; j < array_size; j++){
            shuffle(1000);
            for (int k = 0; k < 8; k++){
                test_data[j].a[k] = x[k];
                test_data[j].b[k] = x[k+8];
                uint32_t value = shuffle_int(5,10);
                test_data[j].c[k] = ((uint32_t) test_data[j].a[k] + (uint32_t) test_data[j].b[k])*value;
                }
                
            }

		sprintf(assert_name, "checksum_asm(test_data, %u)", array_size);

		TEST_ASSERT_EQUALS(uint32_t, checksum_c(test_data, array_size), checksum_asm(test_data, array_size));

        if(*test__fallo){

            for(uint32_t j = 0; j < array_size; j++){
                for (int k = 0; k < 8; k++){
                    printf("test_data[%2u].a[%d] = %3u\t", j, k, test_data[j].a[k]);
                    printf("test_data[%2u].b[%d] = %3u\t", j, k, test_data[j].b[k]);
                    printf("test_data[%2u].c[%d] = %3u\t", j, k, test_data[j].c[k]);
                    printf("%s\n", test_data[j].c[k] ==  ((uint32_t) test_data[j].a[k] + (uint32_t) test_data[j].b[k])*8? "OK": "FAIL");
                }
            }
            free(test_data);
            return;
        }
        free(test_data);
	}
}

int main() {
	srand(0);

	printf("= Checkpoint 1\n");
	printf("==============\n");
    test_invertirBytes();
	printf("\n");

	printf("= Checkpoint 2\n");
	printf("==============\n");
    test_checksum_ok();
    test_checksum_almost_never_ok();
	printf("\n");

	tests_end();
	return 0;
}
