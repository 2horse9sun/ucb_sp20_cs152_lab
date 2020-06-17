// See LICENSE for license details.

//**************************************************************************
// Vectorized index of maximum
//--------------------------------------------------------------------------

    .text
    .align 2

    .global imax
    .type imax,@function
/*
 * size_t imax(size_t n, const float x[]);
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: const float *x
 * Return value:
 *     a0: index
 */
imax:
1:  auipc t0, %pcrel_hi(input_inf)
    flw ft0, %pcrel_lo(1b)(t0)  # initialize maximum to -infinity
    vsetvli zero, zero, e32, m8 # preconfigure vector state
    vfmv.s.f v24, ft0           # move -infinity to scalar in v24;
                                # may be useful for reductions
    li t1, 0                    # initialize index
    mv t2, a0                   # save n for index calculations

imax_loop:
    vsetvli t0, a0, e32, m8     # configure SEW=32 LMUL=8

    # TODO: load x[k] vector
    vle.v v0, (a1)
    # TODO: find maximum value in vector
    vredmax.vs  v16, v0, v24
    # TODO: compare against global maximum
    vfmv.f.s ft1, v16
    flt.s t3, ft1, ft0
    bnez t3, skip



    # TODO: locate position of maximum element; compute new index
    
    vmfge.vf v8, v0, ft1
    vfirst.m t1, v8

    # TODO: update index as necessary
    add t1, t1, t2
    sub t1, t1, a0
    # TODO: update maximum as necessary
    vfmv.f.s ft0, v16

skip:
    sub a0, a0, t0              # decrement n
    slli t0, t0, 2              # scale VL to byte offset
    add a1, a1, t0              # bump pointer x
    bnez a0, imax_loop          # loop

    # TODO: set return value
    mv a0, t1

    ret

    .section .rodata
input_inf:
    .float -inf
