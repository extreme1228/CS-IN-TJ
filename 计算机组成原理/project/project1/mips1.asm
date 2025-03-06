.data
fib0: .word 0
fib1: .word 1

.text
.global main
main:
	lw $2,fib0
	lw $3,fib1
	li $4,10	#这里假设需要求解的是数列的第10项
	add $1,$0,$0
	loop:
	     beq $4,$0,end_loop
	     add $1,$2,$3
	     add $2,$3,$0
	     add $3,$1,$0
	     subi $4,$4,1
	     j loop
	end_loop:
	add $1,$3,$0
	li $v0, 1
    	move $a0, $1
   	syscall