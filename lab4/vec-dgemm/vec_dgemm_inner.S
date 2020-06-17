// See LICENSE for license details.

//**************************************************************************
// Vectorized DGEMM
//--------------------------------------------------------------------------

    .text
    .align 2

    .global dgemm_inner
    .type dgemv_inner,@function
/*
 * void dgemm_inner(size_t n, const double A[], const double B[], const double C[])
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: double *A
 *     a2: double *B
 *     a3: double *C
 *
 * Pseudocode:
 *     for (j = 0; j < n; j++) {
 *         for (k = 0; k < (n/4)*4; k++) {
 *             C[i][j]   += A[i][k]   * B[k][j];
 *             C[i+1][j] += A[i+1][k] * B[k][j];
 *             C[i+2][j] += A[i+2][k] * B[k][j];
 *             C[i+3][j] += A[i+3][k] * B[k][j];
 *
 *             C[i][j]   += A[i][k+1]   * B[k+1][j];
 *             C[i+1][j] += A[i+1][k+1] * B[k+1][j];
 *             C[i+2][j] += A[i+2][k+1] * B[k+1][j];
 *             C[i+3][j] += A[i+3][k+1] * B[k+1][j];
 *
 *             C[i][j]   += A[i][k+2]   * B[k+2][j];
 *             C[i+1][j] += A[i+1][k+2] * B[k+2][j];
 *             C[i+2][j] += A[i+2][k+2] * B[k+2][j];
 *             C[i+3][j] += A[i+3][k+2] * B[k+2][j];
 *
 *             C[i][j]   += A[i][k+3]   * B[k+3][j];
 *             C[i+1][j] += A[i+1][k+3] * B[k+3][j];
 *             C[i+2][j] += A[i+2][k+3] * B[k+3][j];
 *             C[i+3][j] += A[i+3][k+3] * B[k+3][j];
 *         }
 *         for (; k < n; k++) {
 *             C[i][j]   += A[i][k]   * B[k][j];
 *             C[i+1][j] += A[i+1][k] * B[k][j];
 *             C[i+2][j] += A[i+2][k] * B[k][j];
 *             C[i+3][j] += A[i+3][k] * B[k][j];
 *         }
 *     }
 */
dgemm_inner:
    slli t1, a0, 3                  # scale n to bytes
    add t2, a1, t1                  # compute pointer to A[i][n]

    andi t3, a0, ~0x3               # (n / 4) * 4
    slli t3, t3, 3                  # convert offset to bytes
    add t3, a1, t3                  # compute pointer to A[i][(n/4)*4]

dgemm_inner_loop_j:
    vsetvli t0, a0, e64, m4         # configure SEW=64 LMUL=4
    sub a0, a0, t0                  # decrement n
    slli t0, t0, 3                  # scale VL to byte offset

    add a4, a3, t1                  # compute pointer to C[i+1][j]
    add a5, a4, t1                  # compute pointer to C[i+2][j]
    add a6, a5, t1                  # compute pointer to C[i+3][j]

    # HINT: treat C[][] as vectors
    # TODO: load C[i][j]
    vle.v v0, (a3)
    # TODO: load C[i+1][j]
    vle.v v4, (a4)
    # TODO: load C[i+2][j]
    vle.v v8, (a5)
    # TODO: load C[i+3][j]
    vle.v v12, (a6)

    mv t4, a1                       # copy temporary pointer to A
    mv t5, a2                       # copy temporary pointer to B

    bgeu a1, t3, 1f                 # skip if (n / 4) == 0

dgemm_inner_loop_k:
    # HINT: treat B[][] as vectors
    # TODO: load B[k][j]
    vle.v v16, (t5)
    add t5, t5, t1                  # bump pointer B by row stride
    # TODO: load B[k+1][j]
    vle.v v20, (t5)
    add t5, t5, t1                  # bump pointer B by row stride
    # TODO: load B[k+2][j]
    vle.v v24, (t5)
    add t5, t5, t1                  # bump pointer B by row stride
    # TODO: load B[k+3][j]
    vle.v v28, (t5)

    # HINT: treat A[][] as scalars
    fld ft0, (t4)                   # load A[i][k]
    fld ft1, 8(t4)                  # load A[i][k+1]
    fld ft2, 16(t4)                 # load A[i][k+2]
    fld ft3, 24(t4)                 # load A[i][k+3]
    add t6, t4, t1                  # bump pointer A by row stride

    # TODO: load A[i+1][k]
    fld ft4, (t6) 
    # TODO: load A[i+1][k+1]
    fld ft5, 8(t6) 
    # TODO: load A[i+1][k+2]
    fld ft6, 16(t6) 
    # TODO: load A[i+1][k+3]
    fld ft7, 24(t6) 
    add t6, t6, t1

    # TODO: load A[i+2][k]
    fld ft8, (t6) 
    # TODO: load A[i+2][k+1]
    fld ft9, 8(t6) 
    # TODO: load A[i+2][k+2]
    fld ft10, 16(t6) 
    # TODO: load A[i+2][k+3]
    fld ft11, 24(t6) 
    add t6, t6, t1

    # TODO: load A[i+3][k]
    fld fa0, (t6) 
    # TODO: load A[i+3][k+1]
    fld fa1, 8(t6) 
    # TODO: load A[i+3][k+2]
    fld fa2, 16(t6) 
    # TODO: load A[i+3][k+3]
    fld fa3, 24(t6) 

    # TODO: compute partial C[i][j] unrolled 4 times
    vfmacc.vf v0, ft0, v16
    vfmacc.vf v0, ft1, v20
    vfmacc.vf v0, ft2, v24
    vfmacc.vf v0, ft3, v28
    # TODO: compute partial C[i+1][j] unrolled 4 times
    vfmacc.vf v4, ft4, v16
    vfmacc.vf v4, ft5, v20
    vfmacc.vf v4, ft6, v24
    vfmacc.vf v4, ft7, v28
    # TODO: compute partial C[i+2][j] unrolled 4 times
    vfmacc.vf v8, ft8, v16
    vfmacc.vf v8, ft9, v20
    vfmacc.vf v8, ft10, v24
    vfmacc.vf v8, ft11, v28
    # TODO: compute partial C[i+3][j] unrolled 4 times
    vfmacc.vf v12, fa0, v16
    vfmacc.vf v12, fa1, v20
    vfmacc.vf v12, fa2, v24
    vfmacc.vf v12, fa3, v28

    addi t4, t4, 8*4                # bump pointer A by 4*sizeof(double)
    add t5, t5, t1                  # bump pointer B by row stride
    bltu t4, t3, dgemm_inner_loop_k

1:
    beq t3, t2, 2f                  # skip if (n % 4) == 0

dgemm_inner_loop_k_tail:
    # TODO: load B[k][j]
    vle.v v16, (t5)

    # TODO: load A[i][k]
    fld ft0, (t4)
    add t6, t4, t1
    # TODO: load A[i+1][k]
    fld ft1, (t6)
    add t6, t6, t1
    # TODO: load A[i+2][k]
    fld ft2, (t6)
    add t6, t6, t1
    # TODO: load A[i+3][k]
    fld ft3, (t6)

    # TODO: compute partial C[i][j] for remainder
    vfmacc.vf v0, ft0, v16
    # TODO: compute partial C[i+1][j] for remainder
    vfmacc.vf v4, ft1, v16
    # TODO: compute partial C[i+2][j] for remainder
    vfmacc.vf v8, ft2, v16
    # TODO: compute partial C[i+3][j] for remainder
    vfmacc.vf v12, ft3, v16

    addi t4, t4, 8                  # bump pointer A by sizeof(double)
    add t5, t5, t1                  # bump pointer B by row stride
    bltu t4, t2, dgemm_inner_loop_k_tail

2:
    # TODO: store C[i][j]
    vse.v v0, (a3)
    # TODO: store C[i+1][j]
    vse.v v4, (a4)
    # TODO: store C[i+1][j]
    vse.v v8, (a5)
    # TODO: store C[i+1][j]
    vse.v v12, (a6)

    add a2, a2, t0                  # bump pointer B by VL
    add a3, a3, t0                  # bump pointer C by VL
    bnez a0, dgemm_inner_loop_j

    ret
