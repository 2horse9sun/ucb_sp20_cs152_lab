#include "mt-vvadd.h"

// min-sharing:
// vvadd_opt MSI: 24376 cycles, 24.3 cycles/iter, 6.0 CPI
// vvadd_opt MI: 24265 cycles, 24.2 cycles/iter, 6.0 CPI

// min-sharing unrolling:
// vvadd_opt MSI: 23114 cycles, 23.1 cycles/iter, 10.4 CPI
// vvadd_opt MI: 23472 cycles, 23.4 cycles/iter, 10.5 CPI

void vvadd_opt(int coreid, int ncores, size_t n, const data_t* x, const data_t* y, data_t* z)
{
    /* TODO */

    //min-sharing:
    // size_t i = (coreid * n) / ncores;
    // size_t j = ((coreid + 1) * n) / ncores;
    // for (; i < j; i+=1)
    // {
    //     z[i] = x[i] + y[i];
    // }

    // min-sharing unrolling:
    size_t i = (coreid * n) / ncores;
    size_t j = ((coreid + 1) * n) / ncores;
    size_t k = j - j % 16;
    for (; i < k; i+=16)
    {
        z[i] = x[i] + y[i];
        z[i + 1] = x[i + 1] + y[i + 1];
        z[i + 2] = x[i + 2] + y[i + 2];
        z[i + 3] = x[i + 3] + y[i + 3];
        z[i + 4] = x[i + 4] + y[i + 4];
        z[i + 5] = x[i + 5] + y[i + 5];
        z[i + 6] = x[i + 6] + y[i + 6];
        z[i + 7] = x[i + 7] + y[i + 7];
        z[i + 8] = x[i + 8] + y[i + 8];
        z[i + 9] = x[i + 9] + y[i + 9];
        z[i + 10] = x[i + 10] + y[i + 10];
        z[i + 11] = x[i + 11] + y[i + 11];
        z[i + 12] = x[i + 12] + y[i + 12];
        z[i + 13] = x[i + 13] + y[i + 13];
        z[i + 14] = x[i + 14] + y[i + 14];
        z[i + 15] = x[i + 15] + y[i + 15];
    }
    for(i = k; i < j; i++)
    {
        z[i] = x[i] + y[i];
    }



}
