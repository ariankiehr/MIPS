.data 0
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8 
num3: .word 8 # posic 12 
num4: .word 16 # posic 16
num5: .word 32 # posic 20
.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero) # lw $r9, 0($r0)
  lw $t2, 20($zero) # lw $r10, 20($r0)
  sub $t4, $t4, $t4 # $r12 = 0
  sub $t3, $t3, $t3 # $r11 = 0
loop:
  sub $t2, $t2, $t1
  add $t3, $t3, $t2
  beq $t2, $t4, end_pr
  nop
  nop
  nop # lo pone detrás
  j loop
  nop
  nop
  nop
end_pr:
  sw $t3, 24($zero)

