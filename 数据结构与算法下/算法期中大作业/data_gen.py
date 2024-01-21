import numpy as np

# 生成随机数
n = 1000000  # 考生数量
mu = 75  # 期望
sigma = 25  # 标准差
data = np.random.normal(mu, sigma, size=(n, 3))

# 转换为整数
data = np.round(data).astype(int)

# 保存到文件
id = 0
with open('scores_big.txt', 'w') as f:
    for row in data:
        id = id+1
        f.write('{} {} {} {} {}\n'.format(
            id, row[0], row[1], row[2], row[0]+row[1]+row[2]))
