// See LICENSE for license details.

//**************************************************************************
// Vectorized sparse matrix-vector multiply
//--------------------------------------------------------------------------

    .text
    .align 2

    .global vec_spmv
    .type vec_spmv,@function
/*
 * void vec_spmv(size_t r, const double* val, const int* idx, const double* x,
 *               const int* ptr, double* y, double* tmp)
 *
 * Calling convention:
 *     a0: size_t r
 *     a1: double *val
 *     a2: int *idx
 *     a3: double *x
 *     a4: int *ptr
 *     a5: double *y
 *     a6: double *tmp
 */



# Scala implementation
# mcycle = 97709
# minstret = 97714
# D$ Bytes Read:            241023
# D$ Bytes Written:         8926
# D$ Read Accesses:         35696
# D$ Write Accesses:        1217
# D$ Read Misses:           2924
# D$ Write Misses:          145
# D$ Writebacks:            128
# D$ Miss Rate:             8.314%






# Loop unrolling - 2
# mcycle = 29534
# minstret = 29539
# D$ Bytes Read:            245619
# D$ Bytes Written:         8934
# D$ Read Accesses:         36770
# D$ Write Accesses:        1225
# D$ Read Misses:           3017
# D$ Write Misses:          22
# D$ Writebacks:            127
# D$ Miss Rate:             7.998%


# Loop unrolling - 4
# mcycle = 28784
# minstret = 28789
# D$ Bytes Read:            248715
# D$ Bytes Written:         8926
# D$ Read Accesses:         37157
# D$ Write Accesses:        1217
# D$ Read Misses:           3012
# D$ Write Misses:          16
# D$ Writebacks:            117
# D$ Miss Rate:             7.891%


# Loop unrolling - 8
# mcycle = 28409
# minstret = 28414
# D$ Bytes Read:            249739
# D$ Bytes Written:         8966
# D$ Read Accesses:         37285
# D$ Write Accesses:        1257
# D$ Read Misses:           3027
# D$ Write Misses:          20
# D$ Writebacks:            122
# D$ Miss Rate:             7.906%



 vec_spmv:
    # TODO: prologue
    # TODO: initialize loop-invariant values
    mv t6, a0
    andi t6, t6, ~0x3
    slli a7, t6, 3 
    add a7, a5, a7              # initialize pointer to end of y
    slli s0, a0, 3
    add s0, a5, s0
    fmv.d.x ft0, zero           # initialize 0.0 constant
	
vec_spmv_loop_i:

    # TODO: stripmine
	# k = ptr[i]
    lw t1, 0(a4)
    # max_k = ptr[i+1]
    lw t2, 4(a4)
    sub t3, t2, t1
    mv t4, t3
    vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=8
    vfmv.v.f v24, ft0            # initialize v0 to 0.0
    # load y[i]
    fld ft1, (a5)
    
vec_spmv_loop_k_1:
    # TODO: compute SpMV
    # load A[k]
    vle.v v0, (a1)
    # SEW=64,LMUL=4 => SEW=32,LMUL=4
    vsetvli t0, t4, e32, m4
    # load idx[k]
    vle.v v8, (a2)
    # scale index to 64-bit
    vwcvt.x.x.v v16, v8
	vsetvli t0, t4, e64, m8
	# scale v12 to byte offset
	li t5, 3
	vsll.vx v16, v16, t5
    # load x[idx[k]]
    vlxe.v v16, (a3), v16
    # accumulate A[k] * x[idx[k]] into v24
    vfmacc.vv v24, v0, v16
    # max_k--
    sub t4, t4, t0
    # offset
    slli t0, t0, 2
    # bump idx
    add a2, a2, t0
    slli t0, t0, 1
    # bump A
    add a1, a1, t0
    vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
    bnez t4, vec_spmv_loop_k_1
    # TODO: loop arithmetic
    vsetvli zero, t3, e64, m8   # restore original VL
    # reduction
    vfmv.s.f v0, ft1
    vfredosum.vs v0, v24, v0
    vfmv.f.s ft1, v0
    # store y[i]
    fsd ft1, (a5)



    # k = ptr[i]
    lw t1, 4(a4)
    # max_k = ptr[i+1]
    lw t2, 8(a4)
    sub t3, t2, t1
    mv t4, t3
    vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=8
    vfmv.v.f v24, ft0            # initialize v0 to 0.0
    # load y[i]
    fld ft1, 8(a5)
vec_spmv_loop_k_2:
    # TODO: compute SpMV
    # load A[k]
    vle.v v0, (a1)
    # SEW=64,LMUL=4 => SEW=32,LMUL=4
    vsetvli t0, t4, e32, m4
    # load idx[k]
    vle.v v8, (a2)
    # scale index to 64-bit
    vwcvt.x.x.v v16, v8
	vsetvli t0, t4, e64, m8
	# scale v12 to byte offset
	li t5, 3
	vsll.vx v16, v16, t5
    # load x[idx[k]]
    vlxe.v v16, (a3), v16
    # accumulate A[k] * x[idx[k]] into v24
    vfmacc.vv v24, v0, v16
    # max_k--
    sub t4, t4, t0
    # offset
    slli t0, t0, 2
    # bump idx
    add a2, a2, t0
    slli t0, t0, 1
    # bump A
    add a1, a1, t0
    vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
    bnez t4, vec_spmv_loop_k_1
    # TODO: loop arithmetic
    vsetvli zero, t3, e64, m8   # restore original VL
    # reduction
    vfmv.s.f v0, ft1
    vfredosum.vs v0, v24, v0
    vfmv.f.s ft1, v0
    # store y[i]
    fsd ft1, 8(a5)



    # k = ptr[i]
    lw t1, 8(a4)
    # max_k = ptr[i+1]
    lw t2, 12(a4)
    sub t3, t2, t1
    mv t4, t3
    vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=8
    vfmv.v.f v24, ft0            # initialize v0 to 0.0
    # load y[i]
    fld ft1, 16(a5)
vec_spmv_loop_k_3:
    # TODO: compute SpMV
    # load A[k]
    vle.v v0, (a1)
    # SEW=64,LMUL=4 => SEW=32,LMUL=4
    vsetvli t0, t4, e32, m4
    # load idx[k]
    vle.v v8, (a2)
    # scale index to 64-bit
    vwcvt.x.x.v v16, v8
	vsetvli t0, t4, e64, m8
	# scale v12 to byte offset
	li t5, 3
	vsll.vx v16, v16, t5
    # load x[idx[k]]
    vlxe.v v16, (a3), v16
    # accumulate A[k] * x[idx[k]] into v24
    vfmacc.vv v24, v0, v16
    # max_k--
    sub t4, t4, t0
    # offset
    slli t0, t0, 2
    # bump idx
    add a2, a2, t0
    slli t0, t0, 1
    # bump A
    add a1, a1, t0
    vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
    bnez t4, vec_spmv_loop_k_1
    # TODO: loop arithmetic
    vsetvli zero, t3, e64, m8   # restore original VL
    # reduction
    vfmv.s.f v0, ft1
    vfredosum.vs v0, v24, v0
    vfmv.f.s ft1, v0
    # store y[i]
    fsd ft1, 16(a5)


    # k = ptr[i]
    lw t1, 12(a4)
    # max_k = ptr[i+1]
    lw t2, 16(a4)
    sub t3, t2, t1
    mv t4, t3
    vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=8
    vfmv.v.f v24, ft0            # initialize v0 to 0.0
    # load y[i]
    fld ft1, 24(a5)
vec_spmv_loop_k_4:
    # TODO: compute SpMV
    # load A[k]
    vle.v v0, (a1)
    # SEW=64,LMUL=4 => SEW=32,LMUL=4
    vsetvli t0, t4, e32, m4
    # load idx[k]
    vle.v v8, (a2)
    # scale index to 64-bit
    vwcvt.x.x.v v16, v8
	vsetvli t0, t4, e64, m8
	# scale v12 to byte offset
	li t5, 3
	vsll.vx v16, v16, t5
    # load x[idx[k]]
    vlxe.v v16, (a3), v16
    # accumulate A[k] * x[idx[k]] into v24
    vfmacc.vv v24, v0, v16
    # max_k--
    sub t4, t4, t0
    # offset
    slli t0, t0, 2
    # bump idx
    add a2, a2, t0
    slli t0, t0, 1
    # bump A
    add a1, a1, t0
    vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
    bnez t4, vec_spmv_loop_k_1
    # TODO: loop arithmetic
    vsetvli zero, t3, e64, m8   # restore original VL
    # reduction
    vfmv.s.f v0, ft1
    vfredosum.vs v0, v24, v0
    vfmv.f.s ft1, v0
    # store y[i]
    fsd ft1, 24(a5)



#     # TODO: stripmine
# 	# k = ptr[i]
#     lw t1, 16(a4)
#     # max_k = ptr[i+1]
#     lw t2, 20(a4)
#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=4
#     vfmv.v.f v24, ft0            # initialize v0 to 0.0
#     # load y[i]
#     fld ft1, 32(a5)
    
# vec_spmv_loop_k_5:
#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m4
#     # load idx[k]
#     vle.v v8, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v16, v8
# 	vsetvli t0, t4, e64, m8
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v16, v16, t5
#     # load x[idx[k]]
#     vlxe.v v16, (a3), v16
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v24, v0, v16
#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0
#     vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k_1
#     # TODO: loop arithmetic
#     vsetvli zero, t3, e64, m8   # restore original VL
#     # reduction
#     vfmv.s.f v0, ft1
#     vfredosum.vs v0, v24, v0
#     vfmv.f.s ft1, v0
#     # store y[i]
#     fsd ft1, 32(a5)



#     # k = ptr[i]
#     lw t1, 20(a4)
#     # max_k = ptr[i+1]
#     lw t2, 24(a4)
#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=4
#     vfmv.v.f v24, ft0            # initialize v0 to 0.0
#     # load y[i]
#     fld ft1, 40(a5)
# vec_spmv_loop_k_6:
#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m4
#     # load idx[k]
#     vle.v v8, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v16, v8
# 	vsetvli t0, t4, e64, m8
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v16, v16, t5
#     # load x[idx[k]]
#     vlxe.v v16, (a3), v16
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v24, v0, v16
#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0
#     vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k_1
#     # TODO: loop arithmetic
#     vsetvli zero, t3, e64, m8   # restore original VL
#     # reduction
#     vfmv.s.f v0, ft1
#     vfredosum.vs v0, v24, v0
#     vfmv.f.s ft1, v0
#     # store y[i]
#     fsd ft1, 40(a5)



#     # k = ptr[i]
#     lw t1, 24(a4)
#     # max_k = ptr[i+1]
#     lw t2, 28(a4)
#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=4
#     vfmv.v.f v24, ft0            # initialize v0 to 0.0
#     # load y[i]
#     fld ft1, 48(a5)
# vec_spmv_loop_k_7:
#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m4
#     # load idx[k]
#     vle.v v8, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v16, v8
# 	vsetvli t0, t4, e64, m8
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v16, v16, t5
#     # load x[idx[k]]
#     vlxe.v v16, (a3), v16
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v24, v0, v16
#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0
#     vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k_1
#     # TODO: loop arithmetic
#     vsetvli zero, t3, e64, m8   # restore original VL
#     # reduction
#     vfmv.s.f v0, ft1
#     vfredosum.vs v0, v24, v0
#     vfmv.f.s ft1, v0
#     # store y[i]
#     fsd ft1, 48(a5)


#     # k = ptr[i]
#     lw t1, 28(a4)
#     # max_k = ptr[i+1]
#     lw t2, 32(a4)
#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=4
#     vfmv.v.f v24, ft0            # initialize v0 to 0.0
#     # load y[i]
#     fld ft1, 56(a5)
# vec_spmv_loop_k_8:
#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m4
#     # load idx[k]
#     vle.v v8, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v16, v8
# 	vsetvli t0, t4, e64, m8
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v16, v16, t5
#     # load x[idx[k]]
#     vlxe.v v16, (a3), v16
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v24, v0, v16
#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0
#     vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k_1
#     # TODO: loop arithmetic
#     vsetvli zero, t3, e64, m8   # restore original VL
#     # reduction
#     vfmv.s.f v0, ft1
#     vfredosum.vs v0, v24, v0
#     vfmv.f.s ft1, v0
#     # store y[i]
#     fsd ft1, 56(a5)



    # bump
    addi a5, a5, 32
    addi a4, a4, 16
    bltu a5, a7, vec_spmv_loop_i
    
    # TODO: epilogue
    beq a5, s0, done

vec_spmv_loop_i_tail:
    # TODO: stripmine
	# k = ptr[i]
    lw t1, 0(a4)
    # max_k = ptr[i+1]
    lw t2, 4(a4)
    sub t3, t2, t1
    mv t4, t3
    vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=8
    vfmv.v.f v24, ft0            # initialize v0 to 0.0
    # load y[i]
    fld ft1, (a5)
    
vec_spmv_loop_k_tail:
    # TODO: compute SpMV
    # load A[k]
    vle.v v0, (a1)
    # SEW=64,LMUL=4 => SEW=32,LMUL=4
    vsetvli t0, t4, e32, m4
    # load idx[k]
    vle.v v8, (a2)
    # scale index to 64-bit
    vwcvt.x.x.v v16, v8
	vsetvli t0, t4, e64, m8
	# scale v12 to byte offset
	li t5, 3
	vsll.vx v16, v16, t5
    # load x[idx[k]]
    vlxe.v v16, (a3), v16
    # accumulate A[k] * x[idx[k]] into v24
    vfmacc.vv v24, v0, v16
    # max_k--
    sub t4, t4, t0
    # offset
    slli t0, t0, 2
    # bump idx
    add a2, a2, t0
    slli t0, t0, 1
    # bump A
    add a1, a1, t0
    vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
    bnez t4, vec_spmv_loop_k_1
    # TODO: loop arithmetic
    vsetvli zero, t3, e64, m8   # restore original VL
    # reduction
    vfmv.s.f v0, ft1
    vfredosum.vs v0, v24, v0
    vfmv.f.s ft1, v0
    # store y[i]
    fsd ft1, (a5)
    addi a5, a5, 8
    addi a4, a4, 4
    bltu a5, s0, vec_spmv_loop_i_tail


done:
    ret





# No optimization

# LMUL = 8
# mcycle = 31029
# minstret = 31034
# D$ Bytes Read:            239259
# D$ Bytes Written:         8966
# D$ Read Accesses:         35975
# D$ Write Accesses:        1257
# D$ Read Misses:           3027
# D$ Write Misses:          20
# D$ Writebacks:            122
# D$ Miss Rate:             8.184%

# LMUL = 4
# mcycle = 31445
# minstret = 31450
# D$ Bytes Read:            237595
# D$ Bytes Written:         8966
# D$ Read Accesses:         35767
# D$ Write Accesses:        1257
# D$ Read Misses:           3020
# D$ Write Misses:          16
# D$ Writebacks:            119
# D$ Miss Rate:             8.200%

# LMUL = 2
# mcycle = 42213
# minstret = 42218
# D$ Bytes Read:            234523
# D$ Bytes Written:         8966
# D$ Read Accesses:         35383
# D$ Write Accesses:        1257
# D$ Read Misses:           3001
# D$ Write Misses:          17
# D$ Writebacks:            116
# D$ Miss Rate:             8.237%


# vec_spmv:
#     # TODO: prologue
#     # TODO: initialize loop-invariant values
#     slli a7, a0, 3              # scale n to byte offset
#     add a7, a5, a7              # initialize pointer to end of y
#     fmv.d.x ft0, zero           # initialize 0.0 constant
	
# vec_spmv_loop_i:

#     # TODO: stripmine
# 	# k = ptr[i]
#     lw t1, 0(a4)
#     # max_k = ptr[i+1]
#     lw t2, 4(a4)
#     # load y[i]
#     fld ft1, (a5)

#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m8     # configure SEW=64 LMUL=4
#     vfmv.v.f v24, ft0            # initialize v0 to 0.0

    
    
# vec_spmv_loop_k:

#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m4
#     # load idx[k]
#     vle.v v8, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v16, v8
# 	vsetvli t0, t4, e64, m8
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v16, v16, t5
#     # load x[idx[k]]
#     vlxe.v v16, (a3), v16
	
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v24, v0, v16

#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0

#     vsetvli t0, t4, e64, m8     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k

#     vsetvli zero, t3, e64, m8   # restore original VL

#     # TODO: loop arithmetic
#     # reduction
#     vfmv.s.f v0, ft1
#     vfredosum.vs v0, v24, v0
#     vfmv.f.s ft1, v0
#     # store y[i]
#     fsd ft1, (a5)
#     # bump
#     addi a5, a5, 8
#     addi a4, a4, 4
#     bltu a5, a7, vec_spmv_loop_i
    
#     # TODO: epilogue
#     ret



# lift loads out of inner loop
# mcycle = 31446
# minstret = 31451
# D$ Bytes Read:            233591
# D$ Bytes Written:         8966
# D$ Read Accesses:         34767
# D$ Write Accesses:        1257
# D$ Read Misses:           3020
# D$ Write Misses:          16
# D$ Writebacks:            119
# D$ Miss Rate:             8.428%

# vec_spmv:
#     # TODO: prologue
#     # TODO: initialize loop-invariant values
#     slli a7, a0, 3              # scale n to byte offset
#     add a7, a5, a7              # initialize pointer to end of y
#     fmv.d.x ft0, zero           # initialize 0.0 constant
	
# 	lw t1, 0(a4)

# vec_spmv_loop_i:

#     # TODO: stripmine
# 	# k = ptr[i]
#     # lw t1, 0(a4)
#     # max_k = ptr[i+1]
#     lw t2, 4(a4)

#     sub t3, t2, t1
#     mv t4, t3
#     vsetvli t0, t3, e64, m4     # configure SEW=64 LMUL=4
#     vfmv.v.f v12, ft0            # initialize v0 to 0.0

#     # load y[i]
#     fld ft1, (a5)
    
# vec_spmv_loop_k:

#     # TODO: compute SpMV
#     # load A[k]
#     vle.v v0, (a1)
#     # SEW=64,LMUL=4 => SEW=32,LMUL=2
#     vsetvli t0, t4, e32, m2
#     # load idx[k]
#     vle.v v4, (a2)
#     # scale index to 64-bit
#     vwcvt.x.x.v v8, v4
# 	vsetvli t0, t4, e64, m4
# 	# scale v12 to byte offset
# 	li t5, 3
# 	vsll.vx v8, v8, t5
#     # load x[idx[k]]
#     vlxe.v v8, (a3), v8
	
#     # accumulate A[k] * x[idx[k]] into v24
#     vfmacc.vv v12, v0, v8

#     # max_k--
#     sub t4, t4, t0
#     # offset
#     slli t0, t0, 2
#     # bump idx
#     add a2, a2, t0
#     slli t0, t0, 1
#     # bump A
#     add a1, a1, t0

#     vsetvli t0, t4, e64, m4     # update VL; maintain SEW and LMUL
#     bnez t4, vec_spmv_loop_k

#     vsetvli zero, t3, e64, m4   # restore original VL

#     # TODO: loop arithmetic
#     # reduction
#     vfmv.s.f v16, ft1
#     vfredosum.vs v16, v12, v16
#     vfmv.f.s ft1, v16
#     # store y[i]
#     fsd ft1, (a5)
#     # bump
#     mv t1, t2
#     addi a5, a5, 8
#     addi a4, a4, 4
#     bltu a5, a7, vec_spmv_loop_i
    
#     # TODO: epilogue
#     ret