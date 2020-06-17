// See LICENSE for license details.

//**************************************************************************
// imax benchmark
//--------------------------------------------------------------------------
//

#include "util.h"
#include "imax.h"
#include <stdio.h>

//--------------------------------------------------------------------------
// Input/Reference Data

#include "dataset1.h"

//--------------------------------------------------------------------------
// Main

int main( int argc, char* argv[] )
{
  size_t index;
  const float max = input_data[verify_index];

  // Do the imax
  setStats(1);
  index = imax(DATA_SIZE, input_data);
  setStats(0);

  // Check the results
  printf("index = %lu\n" "expected = %lu\n", index, verify_index);
  return (index != verify_index) + ((input_data[index] != max) << 1);
}
