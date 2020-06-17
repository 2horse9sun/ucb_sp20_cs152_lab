// See LICENSE for license details.

//**************************************************************************
// dgemv benchmark
//--------------------------------------------------------------------------
//

#include "util.h"
#include "dgemv.h"

//--------------------------------------------------------------------------
// Input/Reference Data

#include "dataset1.h"

//--------------------------------------------------------------------------
// Main

int main( int argc, char* argv[] )
{
  static double output_data[ROW_SIZE] = { 0.0 };

  // Do the saxpy
  setStats(1);
  dgemv(ROW_SIZE, COL_SIZE, input_data_A, input_data_x, output_data);
  setStats(0);

  // Check the results
  return verifyDouble(ROW_SIZE, output_data, verify_data);
}
