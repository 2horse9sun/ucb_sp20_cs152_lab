// See LICENSE for license details.

#ifndef __DGEMM_H
#define __DGEMM_H

#include <stddef.h>

extern void dgemm_inner(size_t, double [], double [], double []);
extern void dgemm_remainder(size_t, double [], double [], double []);

#endif /* __DGEMM_H */
