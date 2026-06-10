.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    li t5, 1
    blt a1, t5, argmax_error

    mv t0, x0       #index
    mv t1, a0       #pointer
    lw t6, 0(a0)    #max

loop_start:
    beq t0, a1, loop_end
    slli t3, t0, 2
    add t4, t1, t3
    lw t2, 0(t4)
    blt t2, t6, loop_continue
    mv t6, t2
    mv a0, t0

loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    ret

argmax_error:
    li a0, 77
    jal exit2
    ret
