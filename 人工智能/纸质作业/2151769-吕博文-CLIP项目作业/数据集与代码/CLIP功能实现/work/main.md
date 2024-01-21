# **引入**
* 上回介绍了如何搭建模型并加载参数进行模型测试
* 本次就详细介绍一下 CLIP 模型的各种使用

# **CLIP 模型的用途**
* 可通过模型将文本和图像进行编码
* 然后通过计算相似度得出文本与图像之间的关联程度
* 模型大致的架构图如下：

	![](https://ai-studio-static-online.cdn.bcebos.com/6065cb5bb22143fb84d4b59d29fb54035346716671fb45b1950c2fd0cc7f4225)


# **项目说明**
* 项目 GitHub：[【Paddle-CLIP】](https://github.com/AgentMaker/Paddle-CLIP)
* 有关模型的相关细节，请看上一个项目：[【Paddle2.0：复现 OpenAI CLIP 模型】](https://aistudio.baidu.com/aistudio/projectdetail/1619333)

# **安装 Paddle-CLIP**


```python
!pip install paddleclip
```

    Looking in indexes: https://pypi.tuna.tsinghua.edu.cn/simple
    Collecting paddleclip
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/04/c2/54e9cae4fb53fce9f038ba6ad8827525a749c47e74258e21f0e3451b3b85/paddleclip-1.0.0-py3-none-any.whl (1.4 MB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m1.4/1.4 MB[0m [31m3.7 MB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m
    [?25hCollecting regex
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/5e/15/4ac85a6ce5c46223e312de2a38137f7ff1e6c5b4b233054cd7e72466345b/regex-2023.5.5-cp37-cp37m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (756 kB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m756.6/756.6 kB[0m [31m3.1 MB/s[0m eta [36m0:00:00[0ma [36m0:00:01[0m
    [?25hCollecting wget
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/47/6a/62e288da7bcda82b935ff0c6cfe542970f04e29c756b0e147251b2fb251f/wget-3.2.zip (10 kB)
      Preparing metadata (setup.py) ... [?25ldone
    [?25hCollecting ftfy
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/e1/1e/bf736f9576a8979752b826b75cbd83663ff86634ea3055a766e2d8ad3ee5/ftfy-6.1.1-py3-none-any.whl (53 kB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m53.1/53.1 kB[0m [31m188.2 kB/s[0m eta [36m0:00:00[0ma [36m0:00:01[0m
    [?25hCollecting wcwidth>=0.2.5
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/20/f4/c0584a25144ce20bfcf1aecd041768b8c762c1eb0aa77502a3f0baa83f11/wcwidth-0.2.6-py2.py3-none-any.whl (29 kB)
    Building wheels for collected packages: wget
      Building wheel for wget (setup.py) ... [?25ldone
    [?25h  Created wheel for wget: filename=wget-3.2-py3-none-any.whl size=9680 sha256=d8f47d475eeab1e4a4f1779e1788d941219bd03d619d8be4de6afd5bfdf4bd31
      Stored in directory: /home/aistudio/.cache/pip/wheels/dc/31/7f/a4a4cbe7ae34f1a38f54f2a9fc77c06d20b10d1dc8557eb191
    Successfully built wget
    Installing collected packages: wget, wcwidth, regex, ftfy, paddleclip
      Attempting uninstall: wcwidth
        Found existing installation: wcwidth 0.1.7
        Uninstalling wcwidth-0.1.7:
          Successfully uninstalled wcwidth-0.1.7
    Successfully installed ftfy-6.1.1 paddleclip-1.0.0 regex-2023.5.5 wcwidth-0.2.6 wget-3.2
    
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip available: [0m[31;49m22.1.2[0m[39;49m -> [0m[32;49m23.1.2[0m
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m


# **加载模型**
* 首次加载会自动下载预训练模型，请耐心等待


```python
import paddle
from PIL import Image
from clip import tokenize, load_model

model, transforms = load_model('ViT_B_32', pretrained=True)
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/layers/utils.py:26: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      def convert_to_list(value, n, name, dtype=np.int):


# **图像识别**
* 使用预训练模型输出各种候选标签的概率


```python
from paddle.vision.transforms import functional as F
from PIL import Image, ImageFilter
img_path = "apple.jpeg"
image = Image.open(img_path)
resized_image = F.resize(image, size=(200, 400)) 
rotated_image = F.rotate(image, 45)
radius = 5
blurred_image = image.filter(ImageFilter.GaussianBlur(radius))
grayscale_image = F.to_grayscale(image)
```


```python

```


```python
# 设置图片路径和标签
img_path = "apple.jpeg"
labels = ['apple', 'fruit', 'pear', 'peach']

# 准备输入数据
img = Image.open(img_path)
display(grayscale_image)
image = transforms(grayscale_image).unsqueeze(0)
text = tokenize(labels)

# 计算特征
with paddle.no_grad():
    logits_per_image, logits_per_text = model(image, text)
    probs = paddle.nn.functional.softmax(logits_per_image, axis=-1)

# 打印结果
for label, prob in zip(labels, probs.squeeze()):
    print('该图片为 %s 的概率是：%.02f%%' % (label, prob*100.))
```


![png](output_10_0.png)


    该图片为 apple 的概率是：61.27%
    该图片为 fruit 的概率是：19.45%
    该图片为 pear 的概率是：16.32%
    该图片为 peach 的概率是：2.96%



```python

```




    Tensor(shape=[1, 3, 224, 224], dtype=float32, place=CPUPlace, stop_gradient=True,
           [[[[1.36099780, 1.08362770, 0.89384794, ..., 1.56537569, 1.52158046, 1.56537569],
              [1.55077732, 1.21501350, 0.92304480, ..., 1.50698209, 1.47778523, 1.52158046],
              [1.68216312, 1.43398988, 1.14202142, ..., 1.50698209, 1.47778523, 1.52158046],
              ...,
              [1.57997417, 1.63836789, 1.65296626, ..., 0.95224166, 0.98143852, 1.15661979],
              [1.69676161, 1.55077732, 1.62376940, ..., 0.99603695, 0.99603695, 1.14202142],
              [1.68216312, 1.68216312, 1.65296626, ..., 1.14202142, 1.14202142, 1.22961199]],
    
             [[1.45956552, 1.21944118, 1.08437109, ..., 1.68468201, 1.68468201, 1.72970533],
              [1.65466642, 1.36951888, 1.11438668, ..., 1.63965869, 1.63965869, 1.68468201],
              [1.81975186, 1.57962763, 1.30948782, ..., 1.68468201, 1.63965869, 1.68468201],
              ...,
              [1.66967428, 1.72970533, 1.75972080, ..., 1.06936336, 1.11438668, 1.27947235],
              [1.80474412, 1.65466642, 1.74471307, ..., 1.14440238, 1.15941012, 1.30948782],
              [1.77472866, 1.78973639, 1.75972080, ..., 1.27947235, 1.29448009, 1.36951888]],
    
             [[1.33535361, 0.96563166, 0.75233066, ..., 2.03213692, 1.98947644, 2.03213692],
              [1.57709467, 1.15049255, 0.76655072, ..., 1.96103632, 1.94681644, 1.98947644],
              [1.77617562, 1.42067397, 1.00829184, ..., 1.97525656, 1.94681644, 1.98947644],
              ...,
              [1.59131479, 1.64819503, 1.66241503, ..., 0.96563166, 1.02251196, 1.19315267],
              [1.76195550, 1.57709467, 1.64819503, ..., 1.07939219, 1.10783231, 1.25003314],
              [1.73351538, 1.71929538, 1.66241503, ..., 1.25003314, 1.25003314, 1.33535361]]]])




```python
# 设置图片路径和标签
img_path = "fruit.jpg"
labels = ['apple', 'fruit', 'pear', 'peach']

# 准备输入数据
img = Image.open(img_path)
display(img)
image = transforms(Image.open(img_path)).unsqueeze(0)
text = tokenize(labels)

# 计算特征
with paddle.no_grad():
    logits_per_image, logits_per_text = model(image, text)
    probs = paddle.nn.functional.softmax(logits_per_image, axis=-1)

# 打印结果
for label, prob in zip(labels, probs.squeeze()):
    print('该图片为 %s 的概率是：%.02f%%' % (label, prob*100.))
```


![png](output_12_0.png)


    该图片为 apple 的概率是：8.52%
    该图片为 fruit 的概率是：90.30%
    该图片为 pear 的概率是：0.98%
    该图片为 peach 的概率是：0.21%


# **Zero-Shot**
* 使用 Cifar100 的测试集测试零次学习


```python
import paddle
from clip import tokenize, load_model
from paddle.vision.datasets import Cifar100

# 加载模型
model, transforms = load_model('ViT_B_32', pretrained=True)

# 加载 Cifar100 数据集
cifar100 = Cifar100(mode='test', backend='pil')
classes = [
    'apple', 'aquarium_fish', 'baby', 'bear', 'beaver', 'bed', 'bee', 'beetle', 'bicycle', 'bottle', 
    'bowl', 'boy', 'bridge', 'bus', 'butterfly', 'camel', 'can', 'castle', 'caterpillar', 'cattle', 
    'chair', 'chimpanzee', 'clock', 'cloud', 'cockroach', 'couch', 'crab', 'crocodile', 'cup', 'dinosaur', 
    'dolphin', 'elephant', 'flatfish', 'forest', 'fox', 'girl', 'hamster', 'house', 'kangaroo', 'keyboard', 
    'lamp', 'lawn_mower', 'leopard', 'lion', 'lizard', 'lobster', 'man', 'maple_tree', 'motorcycle', 'mountain', 
    'mouse', 'mushroom', 'oak_tree', 'orange', 'orchid', 'otter', 'palm_tree', 'pear', 'pickup_truck', 'pine_tree', 
    'plain', 'plate', 'poppy', 'porcupine', 'possum', 'rabbit', 'raccoon', 'ray', 'road', 'rocket', 
    'rose', 'sea', 'seal', 'shark', 'shrew', 'skunk', 'skyscraper', 'snail', 'snake', 'spider', 
    'squirrel', 'streetcar', 'sunflower', 'sweet_pepper', 'table', 'tank', 'telephone', 'television', 'tiger', 'tractor', 
    'train', 'trout', 'tulip', 'turtle', 'wardrobe', 'whale', 'willow_tree', 'wolf', 'woman', 'worm'
]

# 准备输入数据
image, class_id = cifar100[3637]
display(image)
image_input = transforms(image).unsqueeze(0)
text_inputs = tokenize(["a photo of a %s" % c for c in classes])

# 计算特征
with paddle.no_grad():
    image_features = model.encode_image(image_input)
    text_features = model.encode_text(text_inputs)

# 筛选 Top_5
image_features /= image_features.norm(axis=-1, keepdim=True)
text_features /= text_features.norm(axis=-1, keepdim=True)
similarity = (100.0 * image_features @ text_features.t())
similarity = paddle.nn.functional.softmax(similarity, axis=-1)
values, indices = similarity[0].topk(5)

# 打印结果
for value, index in zip(values, indices):
    print('该图片为 %s 的概率是：%.02f%%' % (classes[index], value*100.))
```

    Cache file /home/aistudio/.cache/paddle/dataset/cifar/cifar-100-python.tar.gz not found, downloading https://dataset.bj.bcebos.com/cifar/cifar-100-python.tar.gz 
    Begin to download
    
    Download finished



![png](output_14_1.png)


    该图片为 snake 的概率是：65.31%
    该图片为 turtle 的概率是：12.29%
    该图片为 sweet_pepper 的概率是：3.83%
    该图片为 lizard 的概率是：1.88%
    该图片为 crocodile 的概率是：1.75%


# **逻辑回归**
* 使用模型的图像编码和标签进行逻辑回归训练
* 使用的数据集依然是 Cifar100


```python
import os
import paddle
import numpy as np
from tqdm import tqdm
from paddle.io import DataLoader
from clip import tokenize, load_model
from paddle.vision.datasets import Cifar100
from sklearn.linear_model import LogisticRegression

# 加载模型
model, transforms = load_model('ViT_B_32', pretrained=True)

# 加载数据集
train = Cifar100(mode='train', transform=transforms, backend='pil')
test = Cifar100(mode='test', transform=transforms, backend='pil')

# 获取特征
def get_features(dataset):
    all_features = []
    all_labels = []
    
    with paddle.no_grad():
        for images, labels in tqdm(DataLoader(dataset, batch_size=100)):
            features = model.encode_image(images)
            all_features.append(features)
            all_labels.append(labels)

    return paddle.concat(all_features).numpy(), paddle.concat(all_labels).numpy()

# 计算并获取特征
train_features, train_labels = get_features(train)
test_features, test_labels = get_features(test)

# 逻辑回归
classifier = LogisticRegression(random_state=0, C=0.316, max_iter=1000, verbose=1, n_jobs=-1)
classifier.fit(train_features, train_labels)

# 模型评估
predictions = classifier.predict(test_features)
accuracy = np.mean((test_labels == predictions).astype(np.float)) * 100.

# 打印结果
print(f"Accuracy = {accuracy:.3f}")
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/scipy/sparse/sputils.py:16: DeprecationWarning: `np.typeDict` is a deprecated alias for `np.sctypeDict`.
      supported_dtypes = [np.typeDict[x] for x in supported_dtypes]
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/scipy/special/orthogonal.py:81: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      from numpy import (exp, inf, pi, sqrt, floor, sin, cos, around, int,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/scipy/linalg/__init__.py:217: DeprecationWarning: The module numpy.dual is deprecated.  Instead of using dual, use the functions directly from numpy or scipy.
      from numpy.dual import register_func
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:30: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      method='lar', copy_X=True, eps=np.finfo(np.float).eps,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:169: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      method='lar', copy_X=True, eps=np.finfo(np.float).eps,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:286: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      eps=np.finfo(np.float).eps, copy_Gram=True, verbose=0,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:858: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      eps=np.finfo(np.float).eps, copy_X=True, fit_path=True):
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:1094: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:1120: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      eps=np.finfo(np.float).eps, positive=False):
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:1349: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      max_n_alphas=1000, n_jobs=None, eps=np.finfo(np.float).eps,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:1590: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      max_n_alphas=1000, n_jobs=None, eps=np.finfo(np.float).eps,
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/sklearn/linear_model/_least_angle.py:1723: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      eps=np.finfo(np.float).eps, copy_X=True, positive=False):
      0%|          | 0/500 [00:00<?, ?it/s]/opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/tensor/creation.py:143: DeprecationWarning: `np.object` is a deprecated alias for the builtin `object`. To silence this warning, use `object` by itself. Doing this will not modify any behavior and is safe. 
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      if data.dtype == np.object:
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dataloader/dataloader_iter.py:89: DeprecationWarning: `np.bool` is a deprecated alias for the builtin `bool`. To silence this warning, use `bool` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.bool_` here.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      if isinstance(slot[0], (np.ndarray, np.bool, numbers.Number)):
      6%|▌         | 31/500 [05:14<1:18:48, 10.08s/it]


    ---------------------------------------------------------------------------

    KeyboardInterrupt                         Traceback (most recent call last)

    /tmp/ipykernel_94/534313325.py in <module>
         29 
         30 # 计算并获取特征
    ---> 31 train_features, train_labels = get_features(train)
         32 test_features, test_labels = get_features(test)
         33 


    /tmp/ipykernel_94/534313325.py in get_features(dataset)
         22     with paddle.no_grad():
         23         for images, labels in tqdm(DataLoader(dataset, batch_size=100)):
    ---> 24             features = model.encode_image(images)
         25             all_features.append(features)
         26             all_labels.append(labels)


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/clip/model.py in encode_image(self, image)
        366 
        367     def encode_image(self, image):
    --> 368         return self.visual(image)
        369 
        370     def encode_text(self, text):


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/clip/model.py in forward(self, x)
        239         x = x + self.positional_embedding
        240         x = self.ln_pre(x)
    --> 241         x = self.transformer(x)
        242         x = self.ln_post(x[:, 0, :])
        243 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/clip/model.py in forward(self, x)
        186 
        187     def forward(self, x):
    --> 188         return self.resblocks(x)
        189 
        190 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/container.py in forward(self, input)
         93     def forward(self, input):
         94         for layer in self._sub_layers.values():
    ---> 95             input = layer(input)
         96         return input
         97 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/clip/model.py in forward(self, x)
        173     def forward(self, x):
        174         x = x + self.attention(self.ln_1(x))
    --> 175         x = x + self.mlp(self.ln_2(x))
        176         return x
        177 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/container.py in forward(self, input)
         93     def forward(self, input):
         94         for layer in self._sub_layers.values():
    ---> 95             input = layer(input)
         96         return input
         97 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/dygraph/layers.py in __call__(self, *inputs, **kwargs)
        900                 self._built = True
        901 
    --> 902             outputs = self.forward(*inputs, **kwargs)
        903 
        904             for forward_post_hook in self._forward_post_hooks.values():


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/nn/layer/common.py in forward(self, input)
        135     def forward(self, input):
        136         out = F.linear(
    --> 137             x=input, weight=self.weight, bias=self.bias, name=self.name)
        138         return out
        139 


    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/nn/functional/common.py in linear(x, weight, bias, name)
       1471         pre_bias = _varbase_creator(dtype=x.dtype)
       1472         core.ops.matmul(x, weight, pre_bias, 'transpose_X', False,
    -> 1473                         'transpose_Y', False, "alpha", 1)
       1474         return dygraph_utils._append_bias_in_dygraph(
       1475             pre_bias, bias, axis=len(x.shape) - 1)


    KeyboardInterrupt: 


# **总结**
* 以上就是 CLIP 模型的一些使用方法
* 当然你也可以利用图像和文本的编码探索一些其他有趣的应用
