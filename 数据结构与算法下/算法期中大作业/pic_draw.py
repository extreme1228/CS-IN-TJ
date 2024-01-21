import matplotlib.pyplot as plt
import numpy as np

# 假设已经获取到了n和时间数据
n_values = [50, 500, 5000, 50000]
time_values = [0.06606, 1.8101, 10.329, 137.58]

# 绘制折线图
plt.figure()
plt.plot(n_values, time_values)
plt.title('Sorting Time vs. n')
plt.xlabel('n')
plt.ylabel('Time')
plt.show()
