# 初始化
addi $t0, $zero, 0  # 将 $t0 置零
addi $t1, $zero, 0  # 将 $t1 置零
add $s2, $zero, $s1 # 将 $s1 复制到 $s2 中
addi $s3, $zero, 32 # 初始化循环计数器

# 循环
.data

.text
main:
booth_loop:
  sll $t2, $s0, 1   # 左移 $s0 的值，相当于乘以 2
  sra $s0, $s0, 1   # 算术右移 $s0 的值，相当于除以 2
  bgez $s2, booth_add # 如果 $s2 >= 0，跳转到 booth_add
  add $t3, $s0, $s1 # $t3 = $s0 + $s1
  j booth_shift      # 跳转到 booth_shift

booth_add:
  sub $t3, $s0, $s1 # $t3 = $s0 - $s1
  booth_shift:
    sra $s1, $s1, 1 # 算术右移 $s1 的值，相当于除以 2
    add $t4, $t3, $t2 # $t4 = $t3 + $t2
    bgez $t4, booth_set_t0 # 如果 $t4 >= 0，跳转到 booth_set_t0
    addi $t1, $t1, -1 # $t1 -= 1
    j booth_shift_end   # 跳转到 booth_shift_end

booth_set_t0:
  addi $t0, $t0, 1 # $t0 += 1

booth_shift_end:
  addi $s3, $s3, -1 # $s3 -= 1
  bgtz $s3, booth_loop # 如果 $s3 > 0，跳转到 booth_loop