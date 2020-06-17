// See LICENSE for license details.

//**************************************************************************
// Vectorized complex multiply
//--------------------------------------------------------------------------

    .text
    .align 2

    .global cmplxmult
    .type cmplxmult,@function
/*
 * void cmplxmult(size_t n, const struct Complex a[], const struct Complex b[], struct Complex c[]);
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: struct Complex *a
 *     a2: struct Complex *b
 *     a3: struct Complex *c
 */
cmplxmult:

    vsetvli t0, a0, e32, m4     # configure SEW=32 LMUL=4
    # TODO: load a[i].real and a[i].imag
    vlseg2e.v v0, (a1)

    # TODO: load b[i].real and b[i].imag
    vlseg2e.v v8, (a2)

    # TODO: compute c[i].real = (a[i].real * b[i].real) - (a[i].imag * b[i].imag)
    # HINT: 2 instructions needed
    vfmul.vv v16, v0, v8
    vfnmsac.vv v16, v4, v12


    # TODO: compute c[i].imag = (a[i].real * b[i].imag) + (a[i].imag * b[i].real)
    # HINT: 2 instructions needed
    vfmul.vv v20, v0, v12
    vfmacc.vv v20, v4, v8

    # TODO: store c[i].real and c[i].real
    vsseg2e.v v16, (a3)

    # TODO: decrement n (a0)
    sub a0, a0, t0

    # TODO: bump pointers
    slli t0, t0, 3
    add a1, a1, t0
    add a2, a2, t0
    add a3, a3, t0

    # TODO: loop
    bnez a0, cmplxmult

    ret
