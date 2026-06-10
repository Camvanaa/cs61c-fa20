.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    li t5, 1
    blt a1, t5, relu_error

    mv t0, x0       #index
    mv t1, a0       #pointer

loop_start:
    beq t0, a1, loop_end
    slli t3, t0, 2
    add t4, t1, t3
    lw t2, 0(t4)
    bge t2, x0, loop_continue
    mv t2, x0
    sw t2, 0(t4)

loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    ret

relu_error:
    li a0, 78
    jal exit2
	ret
