#include "mt-vvadd.h"
// vvadd_naive MSI: 48651 cycles, 48.6 cycles/iter, 9.6 CPI
// vvadd_naive MI: 53450 cycles, 53.4 cycles/iter, 10.6 CPI
void vvadd_naive(int coreid, int ncores, size_t n, const data_t* x, const data_t* y, data_t* z)
{
    size_t i;
    // Interleave accesses
    for (i = coreid; i < n; i += ncores) {
        z[i] = x[i] + y[i];
    }
}
