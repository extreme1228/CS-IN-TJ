import timeit


m=100
# 归并排序函数
def Less_Than(a,b):
    if a[4]!=b[4]: return a[4]<b[4]
    elif a[1]!=b[1] :return a[1]<b[1]
    elif a[2]!=b[2] :return a[2]<b[2]
    return a[3]<b[3]


def quick_sort(scores, left, right, m):
    if left >= right:
        return
    pivot = scores[left]
    i = left
    j = right
    while i < j:
        while i < j and Less_Than(scores[j],pivot):
            j -= 1
        scores[i] = scores[j]

        while i < j and Less_Than(pivot,scores[i]):
            i += 1
        scores[j] = scores[i]

    scores[i] = pivot

    if i+1 == m:  # 前m个数已经有序
        return
    elif i+1 < m:
        quick_sort(scores,  i+1, right, m)
    else:
        quick_sort(scores, left, i-1, m)
# 读取成绩
stu_info=[] 
#利用一个二维列表来存储所有的学生信息，
#每个一维列表中分别有五个元素表示id,chines_score,math_score,English_score,total_score
with open('scores_big.txt', 'r') as f:
    line = f.readline()
    while line:
        info=[]
        try:
            num_list = line.strip().split()
            for num_str in num_list:
                num = int(num_str)
                info.append(num)
        except ValueError:
            print(f"Invalid input: {line}")
        stu_info.append(info)
        line = f.readline()


# 记录排序所用时间

# 排序
t = timeit.Timer(lambda: quick_sort(stu_info,0,len(stu_info)-1,m))
sorted_info = stu_info[:m]
kase=0
with open('scores_big_res.txt', 'w') as f:
    for info in sorted_info:
        kase=kase+1
        f.write('{} {} {} {} {}\n'.format(info[0],info[1], info[2], info[3],info[4]))
        if kase==m:
            break
        

times = t.repeat(repeat=1, number=1)
mean_time = sum(times) / len(times)
print("Score_big:Mean execution time:", mean_time)



