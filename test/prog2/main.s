.data
# ...

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

Control_Harzard:
  li t0, 1
  li t1, 1
  li s1, 3
  beq t0, t1, equal
  li s1, 4
  j exit
equal:
  li t2, 2
  li t3, 3
  beq t2, t3, end
  li s2, 5
  j exit
end:
  li s1, 6
  li s2, 1
exit:
  sw s1, 0(s0) # 3
  sw s2, 4(s0) # 5
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
