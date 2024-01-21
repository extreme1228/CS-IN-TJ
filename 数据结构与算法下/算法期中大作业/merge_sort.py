import timeit

# 归并排序函数
def Less_Than(a,b):
    if a[4]!=b[4]: return a[4]<b[4]
    elif a[1]!=b[1] :return a[1]<b[1]
    elif a[2]!=b[2] :return a[2]<b[2]
    return a[3]<b[3]

def merge_sort(arr):
    # 归并函数，用于合并两个有序数组
    def merge(left, right):
        result = []
        i, j = 0, 0
        while i < len(left) and j < len(right):
            if Less_Than(right[j],left[i]):
                result.append(left[i])
                i += 1
            else:
                result.append(right[j])
                j += 1
        result += left[i:]
        result += right[j:]
        return result
    
    # 递归函数
    def merge_sort_recursion(arr):
        if len(arr) <= 1:
            return arr
        mid = len(arr) // 2
        left = arr[:mid]
        right = arr[mid:]
        left = merge_sort_recursion(left)
        right = merge_sort_recursion(right)
        return merge(left, right)
    
    return merge_sort_recursion(arr)


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
sorted_info = merge_sort(stu_info)

with open('scores_big_res.txt', 'w') as f:
    for info in sorted_info:
        f.write('{} {} {} {} {}\n'.format(info[0],info[1], info[2], info[3],info[4]))
        
t = timeit.Timer(lambda: merge_sort(stu_info))
times = t.repeat(repeat=1, number=1)
mean_time = sum(times) / len(times)
print("Score_Big:Mean execution time:", mean_time)



