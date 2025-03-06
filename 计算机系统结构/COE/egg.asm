
.text
#¥Ê¥¢n m
addiu $2,$0,15
addiu $3,$0,5

#¥Ê¥¢op eggs last_egg_broken
addiu $4,$0,0
addiu $5,$0,0
addiu $6,$0,0

# l r
addiu $7,$0,0
addiu $8,$2,0

loop:
beq $7,$8,final

#1 op+1
addiu $4,$4,1

#2 mid 
add $9,$7,$8
addiu $10,$0,2
div $9,$10
mflo $9

slt $11,$3,$9
beq $11,$0,branch
addiu $5,$5,1
addiu $8,$9,0
j if1_end

branch:
addiu $7,$9,1

if1_end:

#3
slt $6,$3,$9

j loop

final:
#Ω· ¯¡À

end:
