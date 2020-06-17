// See LICENSE for license details.

//**************************************************************************
// Vectorized conditional SAXPY
//--------------------------------------------------------------------------

    .text
    .align 2

    .global csaxpy
    .type csaxpy,@function
/*
 * void csaxpy(size_t n, const bool cond[], float a, const float x[], float y[])
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: bool *cond
 *     a2: float *x
 *     a3: float *y
 *     fa0: float a
 */
csaxpy:
    vsetvli t0, a0, e8, m2          # configure SEW=8 LMUL=2
    sub a0, a0, t0                  # decrement n

    vle.v v8, (a1)                  # load cond[i]

    add a1, a1, t0                  # bump pointer cond
    slli t0, t0, 2                  # scale VL to byte offset
    vmsne.vi v0, v8, 0              # set vector mask

    vsetvli zero, zero, e32, m8     # configure SEW=8 LMUL=8; retain VL
    vle.v v8, (a2)                  # load x[i]
    add a2, a2, t0                  # bump pointer x

    vle.v v16, (a3)                 # load y[i]
    vfmacc.vf v16, fa0, v8, v0.t    # y[i] = (a * x[i]) + y[i]
    vsw.v v16, (a3)                 # store y[i]
    add a3, a3, t0                  # bump pointer y

    bnez a0, csaxpy                 # loop
    ret
