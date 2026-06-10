.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)

    mv s0, a0       # filename
    mv s1, a1       # row
    mv s2, a2       # col

    mv a1, s0
    li a2, 0
    jal fopen
    blt a0, x0, fopen_error
    mv s3, a0       # s3 = file descriptor

    mv a1, s3
    addi a2, sp, 28
    li a3, 8
    jal fread
    li t0, 8
    bne a0, t0, fread_error

    lw t0, 28(sp)    # t0 = rows
    lw t1, 32(sp)    # t1 = cols
    
    sw t0, 0(s1)     # *rows = t0
    sw t1, 0(s2)     # *cols = t1

    mul t0, t0, t1
    slli s4, t0, 2

    mv a0, s4
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0

    mv a1, s3
    mv a2, s5
    mv a3, s4
    jal fread
    bne a0, s4, fread_error

    mv a1, s3
    jal fclose
    blt a0, x0, fclose_error

    mv a0, s5       

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 36

    ret

fclose_error:
    li a0, 92
    jal exit2
    ret

fopen_error:
    li a0, 90
    jal exit2
    ret

fread_error:
    li a0, 91
    jal exit2
    ret

malloc_error:
    li a0, 88
    jal exit2
    ret