.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne a0, t0, argc_error

    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)

    mv s0, a1       # argv
    mv s1, a2       # print_classification

	# =====================================
    # LOAD MATRICES
    # =====================================

    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s9, a0       # 8-byte buffer for matrix dimensions

    lw a0, 4(s0)
    mv a1, s9
    addi a2, s9, 4
    jal read_matrix
    mv s2, a0       # m0 pointer
    lw s3, 0(s9)    # m0 rows
    lw s4, 4(s9)    # m0 cols

    lw a0, 8(s0)
    mv a1, s9
    addi a2, s9, 4
    jal read_matrix
    mv s5, a0       # m1 pointer
    lw s6, 0(s9)    # m1 rows
    lw s7, 4(s9)    # m1 cols

    lw a0, 12(s0)
    mv a1, s9
    addi a2, s9, 4
    jal read_matrix
    mv s8, a0       # input pointer
    lw t1, 0(s9)    # input rows
    lw t2, 4(s9)    # input cols

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    mul t3, s3, t2
    slli t3, t3, 2

    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw s9, 16(sp)

    mv a0, t3
    jal malloc
    beq a0, x0, malloc_error
    mv s9, a0       # temp1 pointer

    mv a0, s2
    mv a1, s3
    mv a2, s4
    mv a3, s8
    lw a4, 4(sp)
    lw a5, 8(sp)
    mv a6, s9
    jal matmul

    mv a0, s9
    lw a1, 12(sp)
    srli a1, a1, 2
    jal relu

    lw t2, 8(sp)
    mul t3, s6, t2
    slli t3, t3, 2

    mv a0, t3
    jal malloc
    beq a0, x0, malloc_error
    mv s4, s3      # rows of temp1
    mv s3, a0      # temp2 / output pointer

    mv a0, s5
    mv a1, s6
    mv a2, s7
    mv a3, s9
    mv a4, s4
    lw a5, 8(sp)
    mv a6, s3
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================

    lw a0, 16(s0)
    mv a1, s3
    mv a2, s6
    lw t2, 8(sp)
    mv a3, t2
    jal write_matrix

    lw t2, 8(sp)

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================

    mv a0, s3
    mul a1, s6, t2
    jal argmax

    bnez s1, print_classification
    mv a1, a0
    jal print_int
    li a1, 10
    jal print_char

print_classification:
    mv a0, s2
    jal free
    mv a0, s5
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s3
    jal free
    lw a0, 16(sp)
    jal free

    addi sp, sp, 20

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    addi sp, sp, 44

    ret

argc_error:
    li a0, 89
    jal exit2
    ret

malloc_error:
    li a0, 88
    jal exit2
    ret