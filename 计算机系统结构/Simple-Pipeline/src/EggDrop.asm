.global min
min:
    bge a0, a1, min_exit
    mv a0, a1
min_exit:
    ret

.global eggDrop
eggDrop:
    # Arguments: a0 = floors, a1 = eggs
    # Return: a0 = result

    # Initialize dp array
    li t0, 1
    li t1, MAX_FLOORS
init_floors_loop:
    beq t0, t1, init_eggs
    li t2, 1
init_eggs_loop:
    beq t2, MAX_EGGS, init_floors_next
    mul t3, t0, (MAX_EGGS + 1)
    add t4, t3, t2
    beqz t2, init_eggs_zero
    li t5, 0
    sw t5, 0(t4)
    j init_eggs_next
init_eggs_zero:
    sw t0, 0(t4)
init_eggs_next:
    addi t2, t2, 1
    j init_eggs_loop
init_floors_next:
    addi t0, t0, 1
    j init_floors_loop

    # Main calculation
    li t0, 2
    li t1, 2
calc_floors_loop:
    bge t0, MAX_FLOORS, calc_exit
    li t2, 2
calc_eggs_loop:
    bge t2, MAX_EGGS, calc_floors_next
    li t3, INT_MAX
    li t4, 1
calc_x_loop:
    bge t4, t0, calc_x_next
    lw t5, 0(t4)
    sub t6, t4, t2
    lw t7, 0(t6)
    add t8, t7, 1
    blt t5, t8, calc_x_next
    bge t3, t8, calc_x_next
    li t3, t8
calc_x_next:
    addi t4, t4, 1
    j calc_x_loop
calc_floors_next:
    addi t0, t0, 1
    j calc_floors_loop
calc_exit:
    mv a0, t3
    ret

.global main
main:
    # Main function
    # Initialize floors and eggs
    li a0, 10
    li a1, 2

    # Call eggDrop function
    call eggDrop

    # Print result
    mv a1, a0
    li a0, 1
    ecall

    # Exit program
    li a0, 10
    ecall
