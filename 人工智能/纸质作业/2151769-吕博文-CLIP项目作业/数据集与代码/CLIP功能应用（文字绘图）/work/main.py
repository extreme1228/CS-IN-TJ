#!/usr/bin/env python
# coding: utf-8

# # PASSL文字画图——你写啥他画啥
# # 一、前言
#  还在为不会画画而苦恼吗？请发挥你的超强想象力，随意输入一句话，就能为你画出一张图片。本文采用的是CLIP，CLIP是一个图文多模态预训练模型，如何实现请参考[PASSL](https://github.com/PaddlePaddle/PASSL/blob/main/docs/Train_CLIP_model.md)，下面教程手把手教你如何使用，学会了，可替换自己的数据集画出你专属的图片哦。

# # 二、算法介绍
# CLIP（Contrastive Language-Image Pre-training）[<sup>1</sup>](#refer-anchor-1)是 openai 提出的图文对比预训练模型，该模型在 4 亿（400 million）互联网收集的图像文本数据对上完成自监督预训练，在多模态大数据、大模型以及大 batch-size 的加持下，CLIP 模型 zero-shot 性能在 30 多个视觉公开数据集上取得了足以匹敌有监督学习的效果，在部分数据集上甚至超越了监督学习的效果；
# ## 1）模型结构介绍
# 如下图所示，为了利用自然语言信息作为和图像表示学习的监督信息，CLIP 模型由 Vision Transformer 和 Bert-Encoder 双塔结构组成，图像部分由 Vision Transformer 进行编码，文本部分由 Transformer-Encoder[<sup>2</sup>](#refer-anchor-2) 进行编码；
# 
# ![](https://passl.bj.bcebos.com/images/clip.png)
# ## 2）Contrastive Loss 计算
# 对比学习简介：假定一个 batch 有 N 个图像-文本对组成，该 batch 理论上可以产生 N^2 对样本，其中包括 N 对正样本和 N^2 - N 对负样本；对比学习的目标是减小正样本对之间的余弦相似度同时增大负样本对之间的余弦相似度；
# 
# CLIP 训练流程：首先将 N 对图像-文本对输入图像和文本编码器，然后产生 N^2 对样本余弦相似度得分 S，最终将 S 输入到交叉熵损失函数来计算最终的 loss 从而优化模型参数； 
# 
# ![](https://passl.bj.bcebos.com/images/clip_loss.png)
# 
# 

# # 三、安装 Paddle 自监督学习库 PASSL
#  [PASSL](https://github.com/PaddlePaddle/PASSL/blob/main/docs/Train_CLIP_model.md) 是一个世界领先的自监督算法库，旨在加速研究人员使用 paddle 开发自监督算法；
# 

# In[1]:


get_ipython().system('pip install passl==0.0.4 -U -i https://pypi.tuna.tsinghua.edu.cn/simple')
get_ipython().system('pip install scikit-image -U -i https://pypi.tuna.tsinghua.edu.cn/simple ')


# # 四、加载模型和参数

# In[3]:


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


# # 五、图像预处理初始化

# In[4]:


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


# # 六、文字画图

# In[5]:


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


# ## 数数 Count

# In[19]:


text = "one beautiful girl"
draw(text)


# In[18]:


text = "one cute cat"
draw(text)


# ## 颜色 Color

# In[13]:


text = "one black dog"
draw(text)


# In[24]:


text = "a boy in the forest"
draw(text)


# ## 物体之间的逻辑关系

# In[20]:


text = "a person wear a headset"
draw(text, out_num=2)


# # 参考
#  - [1] [Learning Transferable Visual Models From Natural Language Supervision
# ](https://arxiv.org/abs/2103.00020)
#  - [2] Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., Kaiser, Ł., and Polosukhin, I. [Attention is all you need](https://arxiv.org/abs/1706.03762). In Advances in neural information processing systems, pp. 5998–6008, 2017.
# 
# 如果想了解更多 CLIP 或 DALLE 原理，请点亮你的小星星 <https://github.com/PaddlePaddle/PASSL> 或者在 [github issue](https://github.com/PaddlePaddle/PASSL/issues) 区留言
