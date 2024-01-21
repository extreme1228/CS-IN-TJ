# PASSL文字画图——你写啥他画啥
# 一、前言
 还在为不会画画而苦恼吗？请发挥你的超强想象力，随意输入一句话，就能为你画出一张图片。本文采用的是CLIP，CLIP是一个图文多模态预训练模型，如何实现请参考[PASSL](https://github.com/PaddlePaddle/PASSL/blob/main/docs/Train_CLIP_model.md)，下面教程手把手教你如何使用，学会了，可替换自己的数据集画出你专属的图片哦。

# 二、算法介绍
CLIP（Contrastive Language-Image Pre-training）[<sup>1</sup>](#refer-anchor-1)是 openai 提出的图文对比预训练模型，该模型在 4 亿（400 million）互联网收集的图像文本数据对上完成自监督预训练，在多模态大数据、大模型以及大 batch-size 的加持下，CLIP 模型 zero-shot 性能在 30 多个视觉公开数据集上取得了足以匹敌有监督学习的效果，在部分数据集上甚至超越了监督学习的效果；
## 1）模型结构介绍
如下图所示，为了利用自然语言信息作为和图像表示学习的监督信息，CLIP 模型由 Vision Transformer 和 Bert-Encoder 双塔结构组成，图像部分由 Vision Transformer 进行编码，文本部分由 Transformer-Encoder[<sup>2</sup>](#refer-anchor-2) 进行编码；

![](https://passl.bj.bcebos.com/images/clip.png)
## 2）Contrastive Loss 计算
对比学习简介：假定一个 batch 有 N 个图像-文本对组成，该 batch 理论上可以产生 N^2 对样本，其中包括 N 对正样本和 N^2 - N 对负样本；对比学习的目标是减小正样本对之间的余弦相似度同时增大负样本对之间的余弦相似度；

CLIP 训练流程：首先将 N 对图像-文本对输入图像和文本编码器，然后产生 N^2 对样本余弦相似度得分 S，最终将 S 输入到交叉熵损失函数来计算最终的 loss 从而优化模型参数； 

![](https://passl.bj.bcebos.com/images/clip_loss.png)



# 三、安装 Paddle 自监督学习库 PASSL
 [PASSL](https://github.com/PaddlePaddle/PASSL/blob/main/docs/Train_CLIP_model.md) 是一个世界领先的自监督算法库，旨在加速研究人员使用 paddle 开发自监督算法；



```python
!pip install passl==0.0.4 -U -i https://pypi.tuna.tsinghua.edu.cn/simple
!pip install scikit-image -U -i https://pypi.tuna.tsinghua.edu.cn/simple 
```

    Looking in indexes: https://pypi.tuna.tsinghua.edu.cn/simple
    Collecting passl==0.0.4
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/c4/aa/4a01cf8c60776157bde722675e2cf74c06de560d6fb777c7a921fb4a3bb6/passl-0.0.4-py3-none-any.whl (1.5 MB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m1.5/1.5 MB[0m [31m909.6 kB/s[0m eta [36m0:00:00[0m:01[0m00:01[0m
    [?25hCollecting regex
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/5e/15/4ac85a6ce5c46223e312de2a38137f7ff1e6c5b4b233054cd7e72466345b/regex-2023.5.5-cp37-cp37m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (756 kB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m756.6/756.6 kB[0m [31m506.3 kB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m
    [?25hCollecting ftfy
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/e1/1e/bf736f9576a8979752b826b75cbd83663ff86634ea3055a766e2d8ad3ee5/ftfy-6.1.1-py3-none-any.whl (53 kB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m53.1/53.1 kB[0m [31m23.2 kB/s[0m eta [36m0:00:00[0ma [36m0:00:01[0m
    [?25hCollecting wcwidth>=0.2.5
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/20/f4/c0584a25144ce20bfcf1aecd041768b8c762c1eb0aa77502a3f0baa83f11/wcwidth-0.2.6-py2.py3-none-any.whl (29 kB)
    Installing collected packages: wcwidth, regex, ftfy, passl
      Attempting uninstall: wcwidth
        Found existing installation: wcwidth 0.1.7
        Uninstalling wcwidth-0.1.7:
          Successfully uninstalled wcwidth-0.1.7
    Successfully installed ftfy-6.1.1 passl-0.0.4 regex-2023.5.5 wcwidth-0.2.6
    
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip available: [0m[31;49m22.1.2[0m[39;49m -> [0m[32;49m23.1.2[0m
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
    Looking in indexes: https://pypi.tuna.tsinghua.edu.cn/simple
    Collecting scikit-image
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/2d/ba/63ce953b7d593bd493e80be158f2d9f82936582380aee0998315510633aa/scikit_image-0.19.3-cp37-cp37m-manylinux_2_12_x86_64.manylinux2010_x86_64.whl (13.5 MB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m13.5/13.5 MB[0m [31m2.5 MB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m
    [?25hRequirement already satisfied: packaging>=20.0 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from scikit-image) (21.3)
    Collecting tifffile>=2019.7.26
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/d8/38/85ae5ed77598ca90558c17a2f79ddaba33173b31cf8d8f545d34d9134f0d/tifffile-2021.11.2-py3-none-any.whl (178 kB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m178.9/178.9 kB[0m [31m125.1 kB/s[0m eta [36m0:00:00[0ma [36m0:00:01[0m
    [?25hRequirement already satisfied: imageio>=2.4.1 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from scikit-image) (2.6.1)
    Requirement already satisfied: pillow!=7.1.0,!=7.1.1,!=8.3.0,>=6.1.0 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from scikit-image) (8.2.0)
    Requirement already satisfied: numpy>=1.17.0 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from scikit-image) (1.21.6)
    Requirement already satisfied: networkx>=2.2 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from scikit-image) (2.4)
    Collecting PyWavelets>=1.1.1
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/ae/56/4441877073d8a5266dbf7b04c7f3dc66f1149c8efb9323e0ef987a9bb1ce/PyWavelets-1.3.0-cp37-cp37m-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_12_x86_64.manylinux2010_x86_64.whl (6.4 MB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m6.4/6.4 MB[0m [31m1.9 MB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m
    [?25hCollecting scipy>=1.4.1
      Downloading https://pypi.tuna.tsinghua.edu.cn/packages/58/4f/11f34cfc57ead25752a7992b069c36f5d18421958ebd6466ecd849aeaf86/scipy-1.7.3-cp37-cp37m-manylinux_2_12_x86_64.manylinux2010_x86_64.whl (38.1 MB)
    [2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m38.1/38.1 MB[0m [31m1.8 MB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m
    [?25hRequirement already satisfied: decorator>=4.3.0 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from networkx>=2.2->scikit-image) (4.4.2)
    Requirement already satisfied: pyparsing!=3.0.5,>=2.0.2 in /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages (from packaging>=20.0->scikit-image) (3.0.9)
    Installing collected packages: tifffile, scipy, PyWavelets, scikit-image
      Attempting uninstall: scipy
        Found existing installation: scipy 1.3.0
        Uninstalling scipy-1.3.0:
          Successfully uninstalled scipy-1.3.0
    [31mERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
    parl 1.4.1 requires pyzmq==18.1.1, but you have pyzmq 23.2.1 which is incompatible.[0m[31m
    [0mSuccessfully installed PyWavelets-1.3.0 scikit-image-0.19.3 scipy-1.7.3 tifffile-2021.11.2
    
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip available: [0m[31;49m22.1.2[0m[39;49m -> [0m[32;49m23.1.2[0m
    [1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m


# 四、加载模型和参数


```python
import os
import numpy as np
import paddle 
from passl import SimpleTokenizer

print("Paddle version:", paddle.__version__)
# Downloading the model
if not os.path.exists('ViT-B-32.pdparams'):
    os.system('wget https://passl.bj.bcebos.com/models/ViT-B-32.pdparams')

# Load Model
from passl.modeling.architectures import CLIPWrapper
arch = {'name': 'CLIP', 'embed_dim':512, 
        'image_resolution': 224, 'vision_layers': 12,
        'vision_width': 768, 'vision_patch_size': 32,
        'context_length': 77, 'vocab_size': 49408,
        'transformer_width': 512, 'transformer_heads': 8,
        'transformer_layers': 12,'qkv_bias': True}
head = {'name': 'CLIPHead'}
model = CLIPWrapper(architecture=arch, head=head)
tokenizer = SimpleTokenizer()

with paddle.no_grad():
    state_dict = paddle.load("ViT-B-32.pdparams")['state_dict']
    model.set_state_dict(state_dict)
```

    Paddle version: 2.1.2


# 五、图像预处理初始化


```python
# Image Preprocessing
'''We resize the input images and center-crop them to conform with the image resolution that the model expects. 
   Before doing so, we will normalize the pixel intensity using the dataset mean and standard deviation.'''
from paddle.vision.transforms import Compose, Resize, CenterCrop, ToTensor, Normalize
from passl.datasets.preprocess.transforms import ToRGB

preprocess = Compose([Resize(224,interpolation='bicubic'),
                     CenterCrop(224),
                     ToTensor(),
                     ])
image_mean = paddle.to_tensor([0.48145466, 0.4578275, 0.40821073])
image_std = paddle.to_tensor([0.26862954, 0.26130258, 0.27577711])
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/tensor/creation.py:125: DeprecationWarning: `np.object` is a deprecated alias for the builtin `object`. To silence this warning, use `object` by itself. Doing this will not modify any behavior and is safe. 
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      if data.dtype == np.object:


# 六、文字画图


```python
from PIL import Image as PilImage

def precompute_image_features():
    image_features = []
    dataset = []
    im_tensors = []
    unsplash = 'unsplash-25k-photos.zip'
    unsplash_dir = 'data/data108238'
    if not os.path.exists(unsplash_dir + '/' + unsplash):
        os.makedirs(unsplash_dir)
        os.system('wget -P data/data108238/ http://sbert.net/datasets/' + unsplash)
    
    os.system('unzip data/data108238/unsplash-25k-photos.zip -d data/data108238/')    
  # Downloading the features
    if not os.path.exists('feats.npy'):
        os.system('wget https://passl.bj.bcebos.com/aisutio/feats.npy')
        os.system('wget https://passl.bj.bcebos.com/aisutio/names.npy')
    feats = np.load('feats.npy')
    namelist = np.load('names.npy')
    return feats, list(namelist)

def find_image(text_query, datatset, image_features, n=1):
    from passl import SimpleTokenizer
    tokenizer = SimpleTokenizer()
    text_tokens = [tokenizer.encode(text_query)]

    text_input = paddle.zeros((len(text_tokens), 77), dtype="int64")
    sot_token = tokenizer.encoder['<|startoftext|>']
    eot_token = tokenizer.encoder['<|endoftext|>']

    for i, tokens in enumerate(text_tokens):
        tokens = [sot_token] + tokens + [eot_token]
        text_input[i, :len(tokens)] = paddle.to_tensor(tokens)
    
    zeroshot_weights = model.model.encode_text(text_input)
    zeroshot_weights /= zeroshot_weights.norm(axis=-1, keepdim=True)

    distances = np.dot(zeroshot_weights, image_features.T)
    
    file_paths = []
    for i in range(1, n+1):
        idx = np.argsort(distances, axis=1)[0, -i]
        file_paths.append('data/data108238/' + dataset[idx])
    return file_paths

import matplotlib.pyplot as plt
from IPython.display import display, Image

def show_images(image_list):
    for im_path in image_list:
        display(Image(filename=im_path))

image_features, dataset = precompute_image_features()   

def draw(text, out_num=1):
    image_paths = find_image(text, dataset, image_features, n=out_num)
    show_images(image_paths)
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/matplotlib/__init__.py:107: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated, and in 3.8 it will stop working
      from collections import MutableMapping
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/matplotlib/rcsetup.py:20: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated, and in 3.8 it will stop working
      from collections import Iterable, Mapping
    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/matplotlib/colors.py:53: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated, and in 3.8 it will stop working
      from collections import Sized


      inflating: data/data108238/otNeYuahoUA.jpg  

## 数数 Count


```python
text = "one beautiful girl"
draw(text)
```


![jpeg](output_11_0.jpeg)



```python
text = "one cute cat"
draw(text)
```


![jpeg](output_12_0.jpeg)


## 颜色 Color


```python
text = "one black dog"
draw(text)
```


![jpeg](output_14_0.jpeg)



```python
text = "a boy in the forest"
draw(text)
```


![jpeg](output_15_0.jpeg)


## 物体之间的逻辑关系


```python
text = "a person wear a headset"
draw(text, out_num=2)
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/tensor/creation.py:125: DeprecationWarning: `np.object` is a deprecated alias for the builtin `object`. To silence this warning, use `object` by itself. Doing this will not modify any behavior and is safe. 
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      if data.dtype == np.object:



![jpeg](output_17_1.jpeg)



![jpeg](output_17_2.jpeg)


# 参考
 - [1] [Learning Transferable Visual Models From Natural Language Supervision
](https://arxiv.org/abs/2103.00020)
 - [2] Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., Kaiser, Ł., and Polosukhin, I. [Attention is all you need](https://arxiv.org/abs/1706.03762). In Advances in neural information processing systems, pp. 5998–6008, 2017.

如果想了解更多 CLIP 或 DALLE 原理，请点亮你的小星星 <https://github.com/PaddlePaddle/PASSL> 或者在 [github issue](https://github.com/PaddlePaddle/PASSL/issues) 区留言
