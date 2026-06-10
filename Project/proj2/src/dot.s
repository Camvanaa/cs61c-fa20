.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    li t0, 1
    blt a2, t0, length_error
    blt a3, t0, stride_error
    blt a4, t0, stride_error

    #Prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)

    mv s0, a0       #pointer to v0
    mv s1, a1       #pointer to v1
    mv s2, a2       #length
    mv s3, a3       #stride of v0
    mv s4, a4       #stride of v1

    mv t0, x0       #dot product
    mv t1, x0       #index
    mv t2, x0       #offset for v0
    mv t3, x0       #offset for v1
loop_start:
    mul t4, t1, s3   #offset for v0 = index * stride of v0
    mul t5, t1, s4   #offset for v1 = index * stride of v1
    bge t1, s2, loop_end
    slli t4, t4, 2
    add t4, s0, t4
    lw t4, 0(t4)
    slli t5, t5, 2
    add t5, s1, t5
    lw t5, 0(t5)
    mul t4, t4, t5
    add t0, t0, t4
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t0
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
    
    ret
length_error:
    li a0, 75
    jal exit2
    ret
stride_error:
    li a0, 76
    jal exit2
    ret
