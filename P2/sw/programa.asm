.data 0
num0:  .word 1  # posic 0
num1:  .word 2  # posic 4
num2:  .word 4  # posic 8 
num3:  .word 8  # posic 12 
num4:  .word 16 # posic 16 
num5:  .word 32 # posic 20
num6:  .word 0  # posic 24
num7:  .word 0  # posic 28
num8:  .word 0  # posic 32
num9:  .word 0  # posic 36
num10: .word 0  # posic 40
num11: .word 0  # posic 44

.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero)  # lw $r9,  0($r0)  -> r9  = 1
  lw $t2, 4($zero)  # lw $r10, 4($r0)  -> r10 = 2
  lw $t3, 8($zero)  # lw $r11, 8($r0)  -> r11 = 4 
  lw $t4, 12($zero) # lw $r12, 12($r0) -> r12 = 8 
  lw $t5, 16($zero) # lw $r13, 16($r0) -> r13 = 16
  lw $t6, 20($zero) # lw $r14, 20($r0) -> r14 = 32
  # copia num0 a num5 sobre num6 a num11
  sw $t1, 24($zero) # sw $r9,  24($r0) -> data[24] =  1
  sw $t2, 28($zero) # sw $r10, 28($r0) -> data[28] =  2
  sw $t3, 32($zero) # sw $r11, 32($r0) -> data[32] =  4 
  sw $t4, 36($zero) # sw $r12, 36($r0) -> data[36] =  8 
  sw $t5, 40($zero) # sw $r13, 40($r0) -> data[40] =  16
  sw $t6, 44($zero) # sw $r14, 44($r0) -> data[44] =  32
  # carga num6 a num11 en los registros 9 a 14, deberia ser lo mismo
  lw $t1, 24($zero) # lw $r9, 24($r0)  -> r9  no cambia
  lw $t2, 28($zero) # lw $r10, 28($r0) -> r10 no cambia
  lw $t3, 32($zero) # lw $r11, 32($r0) -> r11 no cambia
  lw $t4, 36($zero) # lw $r12, 36($r0) -> r12 no cambia
  lw $t5, 40($zero) # lw $r13, 40($r0) -> r13 no cambia
  lw $t6, 44($zero) # lw $r14, 44($r0) -> r14 no cambia
  
  addi $t1, $t2, 3    # $t1 = 5
  addi $t4, $t1, 1    # $t4 = r12 = 6
  
  add $t1, $t2, $t3   # $t1 = r9 = 6
  sub $t4, $t1, $t2   # $t4 = r12 = 6 - 2 = 4     NO ES 1 - 2 = -2

  add $t5, $t6, $t2   # $t5 = r13 = 32 + 2 = 34 = 0X22
  sub $t1, $t3, $t5   # $t1 = r9 = 4 - 34 = -30   NO ES 4 - 16 = -12

  add $t2, $t3, $t4   # $t1 = r9 = 4 + 4 = 8
  add $t6, $t2, $t2   # $t6 = r14 = 8 + 8 = 16    NO ES 2 + 2 = 4