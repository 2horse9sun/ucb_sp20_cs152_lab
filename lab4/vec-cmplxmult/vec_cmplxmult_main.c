// See LICENSE for license details.

//**************************************************************************
// cmplxmult benchmark
//--------------------------------------------------------------------------
//

#include "util.h"
#include "cmplxmult.h"

//--------------------------------------------------------------------------
// Input/Reference Data

#include "dataset1.h"

static int verifyComplex(size_t n, const volatile struct Complex *test, const struct Complex *verify)
{
  size_t i;
  // Unrolled for faster verification
  for (i = 0; i < n/2*2; i+=2)
  {
    struct Complex t0 = test[i], t1 = test[i+1];
    struct Complex v0 = verify[i], v1 = verify[i+1];
    int eq1 = (t0.real == v0.real) && (t0.imag == v0.imag);
    int eq2 = (t1.real == v1.real) && (t1.imag == v1.imag);
    if (!(eq1 & eq2)) return i+1+eq1;
  }
  if (n % 2 != 0 && (test[n-1].real != verify[n-1].real || test[n-1].imag != verify[n-1].imag))
    return n;
  return 0;
}

//--------------------------------------------------------------------------
// Main

int main( int argc, char* argv[] )
{
  static struct Complex output_data[DATA_SIZE];

  // Do the cmplxmult
  setStats(1);
  cmplxmult(DATA_SIZE, input_data_A, input_data_B, output_data);
  setStats(0);

  // Check the results
  return verifyComplex(DATA_SIZE, output_data, verify_data);
}
