.data
num_test: .word 3 
TEST1_SIZE: .word 34
TEST2_SIZE: .word 19
TEST3_SIZE: .word 29
test1: .word 3,41,18,8,40,6,45,1,18,10,24,46,37,23,43,12,3,37,0,15,11,49,47,27,23,30,16,10,45,39,1,23,40,38
test2: .word -3,-23,-22,-6,-21,-19,-1,0,-2,-47,-17,-46,-6,-30,-50,-13,-47,-9,-50
test3: .word -46,0,-29,-2,23,-46,46,9,-18,-23,35,-37,3,-24,-18,22,0,15,-43,-16,-17,-42,-49,-29,19,-44,0,-18,23

.text
.globl main

main:

# ######################################
# ### Load address of _answer to s0 
# ######################################

  addi sp, sp, -4
  sw s5, 0(sp)
  la s5, _answer # s5 -> start addr of answer

# ######################################


# ######################################
# ### Main Program
# ######################################

main_start:
    # initialize variables
    la s0, num_test
    lw s0, 0(s0) # s0 -> num_test
    la s1, TEST1_SIZE # s1 -> start addr of TEST_SIZE
    la s2, test1 #s2 -> start addr of arrays
    mv s3, s5 # s3 -> start addr of result
    li s4, 0 # s4 as idx_counter
main_loop:
    beq s4, s0, main_end
    # main part of loop
    mv t0, s1
    lw t0, 0(t0) #* t0 -> TEST_SIZE
    addi s1, s1, 4 # for next loop
    addi t1, t0, -1 # TEST_SIZE - 1
    # prologue (caller, call merge_sort)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    # call merge_sort
    mv a0, s2
    li a1, 0
    mv a2, t1
    jal merge_sort
    # epilogue (caller, call merge_sort)
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    addi sp, sp, 16
    # write result of sort into answer
write_ans_loop:
    beq t0, x0, main_loop_end 
    lw t1, 0(s2)
    sw t1, 0(s3)
    addi s2, s2, 4
    addi s3, s3, 4
    addi t0, t0, -1
    j write_ans_loop
    # end of loop
main_loop_end:
    addi s4, s4, 1
    j main_loop
main_end:
    j main_exit

merge_sort:
    #! calling convension
    #! parameters
    #! a0 -> pointer_to_arr
    #! a1 -> start
    #! a2 -> end
    #! no return value

    # prologue (callee)
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    # main part
    mv s0, a0 # s0 -> ptr to array
    mv s1, a1 # s1 -> start
    mv s2, a2 # s2 -> end
    # check start < end
    bge s1, s2, merge_sort_end
    add t0, s1, s2
    srai t0, t0, 1 # to -> (start + end) / 2
    #* call merge_sort(arr, start, mid)
    # prologue (caller)
    addi sp, sp, -20
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw a0, 8(sp)
    sw a1, 12(sp)
    sw a2, 16(sp)
    # set argument and call function
    mv a0, s0
    mv a1, s1
    mv a2, t0
    jal merge_sort
    # epilogue (caller)
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)
    lw a2, 16(sp)
    addi sp, sp, 20
    #* call merge_sort(arr, mid, + 1, end)
    # prologue (caller)
    addi sp, sp, -20
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw a0, 8(sp)
    sw a1, 12(sp)
    sw a2, 16(sp)
    # set argument and call function
    mv a0, s0
    addi t0, t0, 1 # mid + 1
    mv a1, t0
    mv a2, s2
    jal merge_sort
    # epilogue (caller)
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)
    lw a2, 16(sp)
    addi sp, sp, 20
    #* call merge(arr, start, mid, end)
    # prologue (caller)
    addi sp, sp, -20
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw a0, 8(sp)
    sw a1, 12(sp)
    sw a2, 16(sp)
    # set argument and call function
    mv a0, s0
    mv a1, s1
    mv a2, t0
    mv a3, s2
    jal merge
    # epilogue (caller)
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw a0, 8(sp)
    lw s1, 12(sp)
    lw s2, 16(sp)
    addi sp, sp, 20
merge_sort_end:
    # epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
    ret
 
merge:
    #! calling convension
    #! parameters
    #! a0 -> pointer_to_arr
    #! a1 -> start
    #! a2 -> mid
    #! a3 -> end
    #! no return value

    # prologue (callee)
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    # main part
    sub t0, a3, a1
    addi t0, t0, 1 # t0 -> temp_size
    slli t1, t0, 2 # t1 -> temp_size * 4
    sub sp, sp, t1 # allocate temp array in stack
    mv s0, sp # s0 -> addr of temp (array)
    sub s1, a2, a1 # s1 -> left_max
    sub s2, a3, a1 # s2 -> right_max
    # initialize temp array
    li t1, 0 # t1 -> index
temp_init_loop:
    beq t1, t0, merge_continue
    slli t2, t1, 2
    add t2, s0, t2 # t2 -> addr of temp[i]
    add t3, t1, a1
    slli t3, t3, 2
    add t3, a0, t3 # t3 -> addr of arr[i + start]
    lw t3, 0(t3)
    sw t3, 0(t2)
    addi t1, t1, 1
    j temp_init_loop
merge_continue:
    mv t0, a1 # t0 -> arr_index
    li t1, 0 # t1 -> left_index
    sub t2, a2, a1
    addi t2, t2, 1 # t2 -> right_index
    # first while loop
merge_first_loop:
    bgt t1, s1, merge_second_loop
    bgt t2, s2, merge_second_loop
    # main part
    # compare temp[left_index] and temp[right_index]
    slli t3, t1, 2
    add t3, s0, t3
    lw t3, 0(t3) # t3 -> temp[left_index]
    slli t4, t2, 2
    add t4, s0, t4
    lw t4, 0(t4) # t4 -> temp[right_index]
    bgt t3, t4, merge_first_loop_else
    # less equal
    slli t4, t0, 2
    add t4, a0, t4 # t4 -> addr of arr[arr_index]
    sw t3, 0(t4) # arr[arr_index] = temp[left_index]
    addi t0, t0, 1 # arr_index++
    addi t1, t1, 1 # left_index++
    j merge_first_loop
merge_first_loop_else:
    slli t3, t0, 2
    add t3, a0, t3 # addr of arr[arr_index]
    sw t4, 0(t3) # arr[arr_index] = temp[right_index]
    addi t0, t0, 1 # arr_index++
    addi t2, t2, 1 # right_index++
    j merge_first_loop
merge_second_loop:
    bgt t1, s1, merge_third_loop
    # main part
    slli t3, t1, 2
    add t3, s0, t3
    lw t3, 0(t3) # temp[left_index]
    slli t4, t0, 2
    add t4, a0, t4 # addr of arr[arr_index]
    sw t3, 0(t4) # arr[arr_index] = temp[left_index]
    addi t0, t0, 1 # arr_index++
    addi t1, t1, 1 # left_index++
    j merge_second_loop
merge_third_loop:
    bgt t2, s2, merge_end
    # main part
    slli t3, t2, 2
    add t3, s0, t3
    lw t3, 0(t3) # t3 -> temp[right_index]
    slli t4, t0, 2
    add t4, a0, t4 # addr of arr[arr_index]
    sw t3, 0(t4) # arr[arr_index] = temp[right_index]
    addi t0, t0, 1 # arr_index++
    addi t2, t2, 1 # right_index++
    j merge_third_loop
merge_end:
    # free allocation of temp array
    sub t0, a3, a1
    addi t0, t0, 1
    slli t0, t0, 2 # temp_size * 4
    add sp, sp, t0
    # epilogue (callee)
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
    ret

# ######################################


main_exit:

# ######################################
# ### Return to end the simulation
# ######################################

  lw s5, 0(sp)
  addi sp, sp, 4
  ret

# ######################################
