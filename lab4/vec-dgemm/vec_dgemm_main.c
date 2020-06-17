// See LICENSE for license details.

//**************************************************************************
// dgemm benchmark
//--------------------------------------------------------------------------
//
#include "util.h"
#include "dgemm.h"

//--------------------------------------------------------------------------
// Input/Reference Data

#include "dataset1.h"

void dgemm(size_t n, double A[], double B[], double C[])
{
  size_t i;

  for (i = 0; i < (n/4)*4; i += 4) {
    dgemm_inner(n, A, B, C);
    A += 4 * n;
    C += 4 * n;
  }

  for (; i < n; i++) {
    dgemm_remainder(n, A, B, C);
    A += n;
    C += n;
  }
}


//--------------------------------------------------------------------------
// Main

int main( int argc, char* argv[] )
{
  static double output_data[DATA_SIZE * DATA_SIZE] = { 0.0 };

  // Do the dgemm
  setStats(1);
  dgemm(DATA_SIZE, input_data_A, input_data_B, output_data);
  setStats(0);

  // Check the results
  return verifyDouble(DATA_SIZE*DATA_SIZE, output_data, verify_data);
}
