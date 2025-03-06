.data
prompt: .asciiz "Please enter five integers : "
prompt2:.asciiz "This is the array in order: "
my_array:.align 2
.word 0,0,0,0,0 	#定义一个长度为5的数组

.text
main:
    # 输出提示信息
    li $v0, 4
    la $a0, prompt
    syscall
    
    la $t0,my_array
    # 读取整数输入并将其分别存储在$2到$6当中,然后在存入my_array中
    li $v0, 5
    syscall
    move $2, $v0
    sw $2,($t0)
    
    li $v0, 5
    syscall
    move $3, $v0
    sw $3,4($t0)
    
    li $v0, 5
    syscall
    move $4, $v0
    sw $4,8($t0)
    
    li $v0, 5
    syscall
    move $5, $v0
    sw $5,12($t0)
    
    li $v0, 5
    syscall
    move $6, $v0
    sw $6,16($t0)
    
    li $t3,5
    li $t1,0
    outer_loop:
    	beq $t1,$t3,exit
    	addi $t1,$t1,1
    	li $t2,0
    	inner_loop:
    		addi $t4,$t2,1
    		beq $t4,$t3,outer_loop
    		lw $t5,my_array($t2)
    		lw $t6,my_array($t4)
    		ble $t5,$t6,continue
    		sw $t6,my_array($t2)
    		sw $t5,my_array($t4)
    		continue:
    		addi $t2,$t2,1
    exit:
    	li $v0, 4
    	la $a0, prompt2
    	syscall
    	
    	li $v0,1
    	li $t0,0
    	lw $a0,my_array($t0)
    	syscall
    	
    	li $v0,1
    	li $t0,1
    	lw $a0,my_array($t0)
    	syscall
    	
    	li $v0,1
    	li $t0,2
    	lw $a0,my_array($t0)
    	syscall
    	
    	li $v0,1
    	li $t0,3
    	lw $a0,my_array($t0)
    	syscall
    	
    	li $v0,1
    	li $t0,4
    	lw $a0,my_array($t0)
    	syscall
    	
