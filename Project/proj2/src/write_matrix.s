.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
        addi sp, sp, -40
        sw s0, 0(sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw s3, 12(sp)
        sw s4, 16(sp)
        sw s5, 20(sp)
        sw ra, 24(sp)

        mv s0, a0
        mv s1, a1
        mv s2, a2
        mv s3, a3

        mv a1, s0
        li a2, 1
        jal fopen
        blt a0, x0, fopen_error
        mv s4, a0

        sw s2, 28(sp)
        sw s3, 32(sp)

        mv a1, s4
        addi a2, sp, 28
        li a3, 2
        li a4, 4
        jal fwrite
        li t0, 2
        bne a0, t0, fwrite_error

        mul s5, s2, s3
        mv a1, s4
        mv a2, s1
        mv a3, s5
        li a4, 4
        jal fwrite
        bne a0, s5, fwrite_error

        mv a1, s4
        jal fclose
        blt a0, x0, fclose_error
    # Epilogue
        lw s0, 0(sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw s3, 12(sp)
        lw s4, 16(sp)
        lw s5, 20(sp)
        lw ra, 24(sp)
        addi sp, sp, 40

        ret

    fopen_error:
        li a0, 93
        jal exit2
        ret

    fwrite_error:
        li a0, 94
        jal exit2
        ret

    fclose_error:
        li a0, 95
        jal exit2
        ret
