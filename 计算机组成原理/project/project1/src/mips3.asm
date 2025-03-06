# ��ʼ��
addi $t0, $zero, 0  # �� $t0 ����
addi $t1, $zero, 0  # �� $t1 ����
add $s2, $zero, $s1 # �� $s1 ���Ƶ� $s2 ��
addi $s3, $zero, 32 # ��ʼ��ѭ��������

# ѭ��
.data

.text
main:
booth_loop:
  sll $t2, $s0, 1   # ���� $s0 ��ֵ���൱�ڳ��� 2
  sra $s0, $s0, 1   # �������� $s0 ��ֵ���൱�ڳ��� 2
  bgez $s2, booth_add # ��� $s2 >= 0����ת�� booth_add
  add $t3, $s0, $s1 # $t3 = $s0 + $s1
  j booth_shift      # ��ת�� booth_shift

booth_add:
  sub $t3, $s0, $s1 # $t3 = $s0 - $s1
  booth_shift:
    sra $s1, $s1, 1 # �������� $s1 ��ֵ���൱�ڳ��� 2
    add $t4, $t3, $t2 # $t4 = $t3 + $t2
    bgez $t4, booth_set_t0 # ��� $t4 >= 0����ת�� booth_set_t0
    addi $t1, $t1, -1 # $t1 -= 1
    j booth_shift_end   # ��ת�� booth_shift_end

booth_set_t0:
  addi $t0, $t0, 1 # $t0 += 1

booth_shift_end:
  addi $s3, $s3, -1 # $s3 -= 1
  bgtz $s3, booth_loop # ��� $s3 > 0����ת�� booth_loop