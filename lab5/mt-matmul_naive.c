#include "mt-matmul.h"

// matmul_naive MSI: 541951 cycles, 16.5 cycles/iter, 4.5 CPI
// matmul_naive MI: 2064555 cycles, 63.0 cycles/iter, 17.1 CPI


void matmul_naive(unsigned int coreid, unsigned int ncores, const size_t lda,  const data_t* A, const data_t* B, data_t* C)
{
    size_t i, j, k;

    for (i = 0; i < lda; i++) {
        for (j = coreid; j < lda; j += ncores) {
            data_t sum = 0;
            for (k = 0; k < lda; k++) {
                sum += A[j*lda + k] * B[k*lda + i];
            }
            C[i + j*lda] = sum;
        }
    }
}
