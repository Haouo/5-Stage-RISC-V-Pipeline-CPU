.data
test_data: .word 3

.text
.globl main

main:

# ######################################
# ### Load address of _answer to s0 
# ######################################

  addi sp, sp, -4
  sw s0, 0(sp)
  la s0, _answer

# ######################################


# ######################################
# ### Main Program
# ######################################

Data_Harzard:
  la t5, test_data
  li t0, 1
  li t1, 1
  add t2, t0, t1 # t2 = 2
  addi t2, t2, 3
  add t3, t1, t2 # t3 = 4
  sw t2, 0(s0)
  sw t3, 4(s0)
  nop
  nop
  nop
  nop
  nop
  lw t4, 0(t5)
  addi t5, t4, 1 # t5 = 4
  sw t5, 8(s0)
  j main_exit

# ######################################


main_exit:

# ######################################
# ### Return to end the simulation
# ######################################

  lw s0, 0(sp)
  addi sp, sp, 4
  ret

# ######################################
