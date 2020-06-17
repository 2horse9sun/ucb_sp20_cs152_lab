#include "mt-matmul.h"



// cache blocking -4 :
// matmul_opt MSI: 437309 cycles, 13.3 cycles/iter, 2.7 CPI
// matmul_opt MI: 1347918 cycles, 41.1 cycles/iter, 8.3 CPI

// cache blocking -8 :
// matmul_opt MSI: 305435 cycles, 9.3 cycles/iter, 2.2 CPI
// matmul_opt MI: 2002040 cycles, 61.0 cycles/iter, 14.7 CPI

// cache blocking -16 :
// matmul_opt MSI: 235247 cycles, 7.1 cycles/iter, 1.8 CPI
// matmul_opt MI: 734581 cycles, 22.4 cycles/iter, 5.8 CPI

// cache blocking -32 :
// matmul_opt MSI: 881826 cycles, 26.9 cycles/iter, 3.6 CPI
// matmul_opt MI: 891629 cycles, 27.2 cycles/iter, 3.7 CPI

// cache blocking -16 unrolling :
// matmul_opt MSI: 226890 cycles, 6.9 cycles/iter, 2.0 CPI
// matmul_opt MI: 757033 cycles, 23.1 cycles/iter, 6.6 CPI

void matmul_opt(unsigned int coreid, unsigned int ncores, const size_t lda,  const data_t* A, const data_t* B, data_t* C)
{
    /* TODO */

    size_t i, j, k, kk, jj, blocksize;
    blocksize = 16;
    data_t sum;
    for (kk = 0; kk < lda; kk += blocksize) {
        for (jj = blocksize*coreid; jj < lda; jj += blocksize*ncores) {
            for (i = 0; i < lda; i++) {
                for (j = jj; j < jj + blocksize; j++) {
                    sum = C[i*lda + j];
                    for (k = kk; k < kk + blocksize; k++) {
                        sum += A[i*lda + k] * B[k*lda + j];
                    }
                    C[i*lda + j] = sum;
                }
            }
        }
    }

    // size_t i, j, k, kk, jj, blocksize;
    // blocksize = 16;
    // data_t sum;
    // for (kk = 0; kk < lda; kk += blocksize) {
    //     for (jj = blocksize*coreid; jj < lda; jj += blocksize*ncores) {
    //         for (i = 0; i < lda; i++) {
    //             for (j = jj; j < jj + blocksize; j++) {
    //                 sum = C[i*lda + j];
    //                 sum += A[i*lda + kk + 0] * B[(kk + 0)*lda + j]
    //                         + A[i*lda + kk + 1] * B[(kk + 1)*lda + j]
    //                         + A[i*lda + kk + 2] * B[(kk + 2)*lda + j]
    //                         + A[i*lda + kk + 3] * B[(kk + 3)*lda + j]
    //                         + A[i*lda + kk + 4] * B[(kk + 4)*lda + j]
    //                         + A[i*lda + kk + 5] * B[(kk + 5)*lda + j]
    //                         + A[i*lda + kk + 6] * B[(kk + 6)*lda + j]
    //                         + A[i*lda + kk + 7] * B[(kk + 7)*lda + j]
    //                         + A[i*lda + kk + 8] * B[(kk + 8)*lda + j]
    //                         + A[i*lda + kk + 9] * B[(kk + 9)*lda + j]
    //                         + A[i*lda + kk + 10] * B[(kk + 10)*lda + j]
    //                         + A[i*lda + kk + 11] * B[(kk + 11)*lda + j]
    //                         + A[i*lda + kk + 12] * B[(kk + 12)*lda + j]
    //                         + A[i*lda + kk + 13] * B[(kk + 13)*lda + j]
    //                         + A[i*lda + kk + 14] * B[(kk + 14)*lda + j]
    //                         + A[i*lda + kk + 15] * B[(kk + 15)*lda + j];
    //                 C[i*lda + j] = sum;
    //             }
    //         }
    //     }
    // }

}
