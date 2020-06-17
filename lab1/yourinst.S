# See LICENSE for license details.

#*****************************************************************************
# yourinst.S
#-----------------------------------------------------------------------------
#
# This is the most basic self checking test. If your simulator does not
# pass thiss then there is little chance that it will pass any of the
# more complicated self checking tests.
#

#include "riscv_test.h"
#include "test_macros.h"



RVTEST_RV64U
RVTEST_CODE_BEGIN

# FIXME: Add your tests here
# See the tests in movn.S for examples


  
  TEST_ST_OP(2,lw,sw,0x00aa00aa,0,0x000000f0);
  TEST_ST_OP(3,lw,sw,0xaa00aa00,4,0x000000f0);
  TEST_ST_OP(4,lw,sw,0x00000000,8,0x000000f0);
  li x1, 0x000000f0;
  li x2, 0x000f0000;
  .word 0x00008157;
  TEST_LD_OP(5,lw,0x00aa00aa,0,0x000f0000);
  TEST_LD_OP(6,lw,0xaa00aa00,4,0x000f0000);
  TEST_LD_OP(7,lw,0x00000000,8,0x000f0000);



  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA




RVTEST_DATA_END
