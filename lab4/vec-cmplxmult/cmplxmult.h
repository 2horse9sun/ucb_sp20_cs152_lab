// See LICENSE for license details.

#ifndef __CMPLXMULT_H
#define __CMPLXMULT_H

#include <stddef.h>

struct Complex
{
  float real;
  float imag;
};

extern void cmplxmult(size_t, const struct Complex [], const struct Complex [], struct Complex []);

#endif /* __CMPLXMULT_H */
