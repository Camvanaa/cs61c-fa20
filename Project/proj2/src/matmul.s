.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:
    li t0, 1
    blt a1, t0, m0_dimension_error
    blt a2, t0, m0_dimension_error
    blt a4, t0, m1_dimension_error
    blt a5, t0, m1_dimension_error
    bne a2, a4, dimension_mismatch_error
    # Error checks
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    # Prologue
    mv s0, a0       #pointer to m0
    mv s1, a1       #height of m0
    mv s2, a2       #width of m0
    mv s3, a3       #pointer to m1
    mv s4, a4       #height of m1
    mv s5, a5       #width of m1
    mv s6, a6       #pointer to d

    mv t0, x0       #i = 0, row index for m0
    mv t1, x0       #j = 0, column index for m1
    mv t2, x0       #k = 0, index for columns of m0 and rows of m1
    mv t3, x0       #sum = 0, accumulator for the dot product

outer_loop_start:
    bge t0, s1, outer_loop_end
    mv t1, x0       #reset j = 0 for each new row of m0

inner_loop_start:
    bge t1, s5, inner_loop_end

    mul t4, t0, s2
    slli t4, t4, 2
    add a0, s0, t4
    
    slli t4, t1, 2
    add a1, s3, t4

    mv a2, s2
    li a3, 1
    mv a4, s5

    addi sp, sp, -28
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    sw t5, 20(sp)
    sw ra, 24(sp)

    jal dot

    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    lw t5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

    mv t3, a0       #store the dot product in t3

    mul t4, t0, s5
    add t4, t4, t1
    slli t4, t4, 2
    add t4, s6, t4
    sw t3, 0(t4)    #store the dot product in d[i][j]

    addi t1, t1, 1
    j inner_loop_start

inner_loop_end:
    addi t0, t0, 1
    j outer_loop_start

outer_loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28
    # Epilogue
    ret

m0_dimension_error:
    li a0, 72
    jal exit2
    ret

m1_dimension_error:
    li a0, 73
    jal exit2
    ret

dimension_mismatch_error:
    li a0, 74
    jal exit2
    ret
