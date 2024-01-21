
# **模型简介**
* CLIP 的全称是 Contrastive Language–Image Pre-training
* CLIP 就像是图像届的 GPT-2，输入图片，输出文本描述。正因为是描述，所以可以在各种图像分类任务上进行 zero-shot
* 模型效果样例如下：

	![](https://img-blog.csdnimg.cn/img_convert/db4bbc9fbdb77e4402c43c70918133d2.png)
* 对于图像领域，CLIP的贡献不可忽视，它可以缓解三个问题：
  * Costly datasets：之前大部分模型用的数据集都是人标的，而 CLIP 的训练数据都是从网上找的，用纯文本作为 label ，减少了人力成本
  * Narrow：根据有标注数据集训练的话输出是有限的，比如数据集只教模型预测猫和狗，那就没法再让模型去预测鸭子，而 CLIP 在常见图像上就不受限制
  * Poor real-world performance：benchmark 和真实情况都是有 gap 的，在 benchmark 上表现好不意味着真实情景也好。而 CLIP 不是从某个特定数据集学出来的，可以缓解这个问题。作者也通过实验证实，如果面向 ImageNet 学习的话，虽然评估效果会提高，但其他7个数据集上都不太好
* 更多详情请参考 [【CLIP 官网】](https://openai.com/blog/clip/)

# **优化内容**
* 将所有参数进行正确注册
* 修复一些前向计算的小问题
* 简化代码并优化代码格式
* 转换官方预训练模型参数并对齐精度

# **模型搭建**

## **导入必要的模块**


```python
import paddle
import paddle.nn as nn
from paddle.nn.initializer import Assign, Normal, Constant
```

    /opt/conda/envs/python35-paddle120-env/lib/python3.7/site-packages/paddle/fluid/layers/utils.py:26: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
    Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
      def convert_to_list(value, n, name, dtype=np.int):


## **一些简单的网络模块**


```python
class Identity(nn.Layer):
class QuickGELU(nn.Layer):
class MultiHeadAttention(nn.MultiHeadAttention):
```


```python
class Identity(nn.Layer):
    def __init__(self):
        super(Identity, self).__init__()

    def forward(self, inputs):
        return inputs


class QuickGELU(nn.Layer):
    def forward(self, x):
        return x * nn.functional.sigmoid(1.702 * x)


class MultiHeadAttention(nn.MultiHeadAttention):
    def __init__(self,
                 embed_dim,
                 num_heads,
                 output_dim=None):
        super(MultiHeadAttention, self).__init__(embed_dim, num_heads)
        self.out_proj = nn.Linear(embed_dim, output_dim or embed_dim)
```

## **Bottleneck**


```python
class Bottleneck(nn.Layer):
    expansion = 4

    def __init__(self, inplanes, planes, stride=1):
        super().__init__()
        self.conv1 = nn.Conv2D(inplanes, planes, 1, bias_attr=False)
        self.bn1 = nn.BatchNorm2D(planes)

        self.conv2 = nn.Conv2D(planes, planes, 3, padding=1, bias_attr=False)
        self.bn2 = nn.BatchNorm2D(planes)

        self.avgpool = nn.AvgPool2D(stride) if stride > 1 else Identity()

        self.conv3 = nn.Conv2D(
            planes, planes * self.expansion, 1, bias_attr=False)
        self.bn3 = nn.BatchNorm2D(planes * self.expansion)

        self.relu = nn.ReLU()
        self.downsample = None
        self.stride = stride

        if stride > 1 or inplanes != planes * Bottleneck.expansion:
            self.downsample = nn.Sequential(
                ("-1", nn.AvgPool2D(stride)),
                ("0", nn.Conv2D(inplanes, planes *
                                self.expansion, 1, stride=1, bias_attr=False)),
                ("1", nn.BatchNorm2D(planes * self.expansion))
            )

    def forward(self, x):
        identity = x

        out = self.relu(self.bn1(self.conv1(x)))
        out = self.relu(self.bn2(self.conv2(out)))
        out = self.avgpool(out)
        out = self.bn3(self.conv3(out))

        if self.downsample is not None:
            identity = self.downsample(x)

        out += identity
        out = self.relu(out)
        return out
```

## **AttentionPool2D**


```python
class AttentionPool2D(nn.Layer):
    def __init__(self, spacial_dim, embed_dim, num_heads, output_dim=None):
        super().__init__()
        positional_embedding = self.create_parameter(
            shape=(spacial_dim ** 2 + 1, embed_dim),
            default_initializer=Assign(
                paddle.randn((spacial_dim ** 2 + 1, embed_dim)) /
                embed_dim ** 0.5
            )
        )
        self.add_parameter("positional_embedding", positional_embedding)

        self.attn = MultiHeadAttention(embed_dim, num_heads, output_dim)

    def forward(self, x):
        x = x.reshape((x.shape[0], x.shape[1], x.shape[2] *
                       x.shape[3])).transpose((2, 0, 1))
        x = paddle.concat([x.mean(axis=0, keepdim=True), x], axis=0)
        x = x + self.positional_embedding.unsqueeze(1)
        x = x.transpose((1, 0, 2))
        x = self.attn(query=x, key=x, value=x)
        x = x.transpose((1, 0, 2))
        return x[0]
```

## **ModifiedResNet**


```python
class ModifiedResNet(nn.Layer):
    def __init__(self, layers, output_dim, heads, input_resolution=224, width=64):
        super().__init__()
        self.output_dim = output_dim
        self.input_resolution = input_resolution

        self.conv1 = nn.Conv2D(3, width // 2, kernel_size=3,
                               stride=2, padding=1, bias_attr=False)
        self.bn1 = nn.BatchNorm2D(width // 2)

        self.conv2 = nn.Conv2D(width // 2, width // 2,
                               kernel_size=3, padding=1, bias_attr=False)
        self.bn2 = nn.BatchNorm2D(width // 2)

        self.conv3 = nn.Conv2D(
            width // 2, width, kernel_size=3, padding=1, bias_attr=False)
        self.bn3 = nn.BatchNorm2D(width)

        self.avgpool = nn.AvgPool2D(2)
        self.relu = nn.ReLU()

        # residual layers
        self._inplanes = width
        self.layer1 = self._make_layer(width, layers[0])
        self.layer2 = self._make_layer(width * 2, layers[1], stride=2)
        self.layer3 = self._make_layer(width * 4, layers[2], stride=2)
        self.layer4 = self._make_layer(width * 8, layers[3], stride=2)

        embed_dim = width * 32
        self.attnpool = AttentionPool2D(
            input_resolution // 32, embed_dim, heads, output_dim)

    def _make_layer(self, planes, blocks, stride=1):
        layers = [Bottleneck(self._inplanes, planes, stride)]

        self._inplanes = planes * Bottleneck.expansion
        for _ in range(1, blocks):
            layers.append(Bottleneck(self._inplanes, planes))

        return nn.Sequential(*layers)

    def stem(self, x):
        for conv, bn in [(self.conv1, self.bn1), (self.conv2, self.bn2), (self.conv3, self.bn3)]:
            x = self.relu(bn(conv(x)))

        x = self.avgpool(x)
        return x

    def forward(self, x):
        x = self.stem(x)
        x = self.layer1(x)
        x = self.layer2(x)
        x = self.layer3(x)
        x = self.layer4(x)
        x = self.attnpool(x)
        return x
```

## **ResidualAttentionBlock**


```python
class ResidualAttentionBlock(nn.Layer):
    def __init__(self, d_model, n_head, attn_mask=None):
        super().__init__()
        self.attn = MultiHeadAttention(d_model, n_head)
        self.ln_1 = nn.LayerNorm(d_model)
        self.mlp = nn.Sequential(
            ("c_fc", nn.Linear(d_model, d_model * 4)),
            ("gelu", QuickGELU()),
            ("c_proj", nn.Linear(d_model * 4, d_model))
        )
        self.ln_2 = nn.LayerNorm(d_model)
        self.attn_mask = attn_mask

    def attention(self, x):
        self.attn_mask = self.attn_mask if self.attn_mask is not None else None
        return self.attn(x, x, x, attn_mask=self.attn_mask)

    def forward(self, x):
        x = x + self.attention(self.ln_1(x))
        x = x + self.mlp(self.ln_2(x))
        return x
```

## **Transformer**


```python
class Transformer(nn.Layer):
    def __init__(self, width, layers, heads, attn_mask=None):
        super().__init__()
        self.width = width
        self.layers = layers
        self.resblocks = nn.Sequential(
            *[ResidualAttentionBlock(width, heads, attn_mask) for _ in range(layers)])

    def forward(self, x):
        return self.resblocks(x)
```

## **VisualTransformer**


```python
class VisualTransformer(nn.Layer):
    def __init__(self, input_resolution, patch_size, width, layers, heads, output_dim):
        super().__init__()
        self.input_resolution = input_resolution
        self.output_dim = output_dim
        self.conv1 = nn.Conv2D(in_channels=3, out_channels=width,
                               kernel_size=patch_size, stride=patch_size, bias_attr=False)

        scale = width ** -0.5

        class_embedding = self.create_parameter(
            shape=(width,),
            default_initializer=Assign(
                scale * paddle.randn((width,))
            )
        )
        self.add_parameter("class_embedding", class_embedding)

        positional_embedding = self.create_parameter(
            shape=(width,),
            default_initializer=Assign(
                scale *
                paddle.randn(
                    ((input_resolution // patch_size) ** 2 + 1, width))
            )
        )
        self.add_parameter("positional_embedding", positional_embedding)

        self.ln_pre = nn.LayerNorm(width)

        self.transformer = Transformer(width, layers, heads)

        self.ln_post = nn.LayerNorm(width)

        proj = self.create_parameter(
            shape=(width,),
            default_initializer=Assign(
                scale * paddle.randn(((width, output_dim)))
            )
        )
        self.add_parameter("proj", proj)

    def forward(self, x):
        x = self.conv1(x)
        x = x.reshape((x.shape[0], x.shape[1], -1))
        x = x.transpose((0, 2, 1))
        zeros = paddle.zeros((x.shape[0], 1, x.shape[-1]), dtype='float32')
        x = paddle.concat([self.class_embedding + zeros, x], axis=1)
        x = x + self.positional_embedding
        x = self.ln_pre(x)
        x = self.transformer(x)
        x = self.ln_post(x[:, 0, :])

        if self.proj is not None:
            x = x @ self.proj

        return x
```

## **CLIP**


```python
class CLIP(nn.Layer):
    def __init__(self,
                 embed_dim,
                 # vision
                 image_resolution,
                 vision_layers,
                 vision_width,
                 vision_patch_size,
                 # text
                 context_length,
                 vocab_size,
                 transformer_width,
                 transformer_heads,
                 transformer_layers
                 ):
        super().__init__()
        self.context_length = context_length
        self.embed_dim = embed_dim

        if isinstance(vision_layers, (tuple, list)):
            vision_heads = vision_width * 32 // 64
            self.visual = ModifiedResNet(
                layers=vision_layers,
                output_dim=embed_dim,
                heads=vision_heads,
                input_resolution=image_resolution,
                width=vision_width
            )
        else:
            vision_heads = vision_width // 64
            self.visual = VisualTransformer(
                input_resolution=image_resolution,
                patch_size=vision_patch_size,
                width=vision_width,
                layers=vision_layers,
                heads=vision_heads,
                output_dim=embed_dim
            )

        self.transformer = Transformer(
            width=transformer_width,
            layers=transformer_layers,
            heads=transformer_heads,
            attn_mask=self.build_attention_mask()
        )

        self.vocab_size = vocab_size
        self.token_embedding = nn.Embedding(vocab_size, transformer_width)

        positional_embedding = self.create_parameter(
            shape=(self.context_length, transformer_width),
            default_initializer=Assign(
                paddle.empty((self.context_length, transformer_width))
            )
        )
        self.add_parameter("positional_embedding", positional_embedding)

        self.ln_final = nn.LayerNorm(transformer_width)

        text_projection = self.create_parameter(
            shape=(transformer_width, embed_dim),
            default_initializer=Assign(
                paddle.empty((transformer_width, embed_dim))
            )
        )
        self.add_parameter("text_projection", text_projection)

        logit_scale = self.create_parameter(
            shape=(1,),
            default_initializer=Assign(paddle.ones([1]))
        )
        self.add_parameter("logit_scale", logit_scale)

        self.initialize_parameters()

    def initialize_parameters(self):
        Normal(std=0.02)(self.token_embedding.weight)
        Normal(std=0.01)(self.positional_embedding)

        if isinstance(self.visual, ModifiedResNet):
            if self.visual.attnpool is not None:
                std = self.embed_dim ** -0.5
                normal_ = Normal(std=std)
                normal_(self.visual.attnpool.attn.q_proj.weight)
                normal_(self.visual.attnpool.attn.k_proj.weight)
                normal_(self.visual.attnpool.attn.v_proj.weight)
                normal_(self.visual.attnpool.attn.out_proj.weight)

            for resnet_block in [self.visual.layer1, self.visual.layer2, self.visual.layer3, self.visual.layer4]:
                for name, param in resnet_block.named_parameters():
                    if name.endswith("bn3.weight"):
                        Constant(value=0.0)(param)

        proj_std = (self.transformer.width ** -0.5) * \
            ((2 * self.transformer.layers) ** -0.5)
        attn_std = self.transformer.width ** -0.5
        fc_std = (2 * self.transformer.width) ** -0.5

        for resblock in self.transformer.resblocks:
            normal_ = Normal(std=attn_std)
            normal_(resblock.attn.q_proj.weight)
            normal_(resblock.attn.k_proj.weight)
            normal_(resblock.attn.v_proj.weight)
            Normal(std=proj_std)(resblock.attn.out_proj.weight)
            Normal(std=fc_std)(resblock.mlp.c_fc.weight)
            Normal(std=proj_std)(resblock.mlp.c_proj.weight)

        if self.text_projection is not None:
            Normal(std=self.transformer.width ** -0.5)(self.text_projection)

    def build_attention_mask(self):
        mask = paddle.full(
            (self.context_length, self.context_length), float("-inf")
        )
        mask = paddle.triu(mask, diagonal=1)
        return mask

    def encode_image(self, image):
        return self.visual(image)

    def encode_text(self, text):
        x = self.token_embedding(text)
        x = x + self.positional_embedding
        x = self.transformer(x)
        x = self.ln_final(x)

        select = []
        index = zip(
            paddle.arange(x.shape[0]).numpy(),
            text.argmax(axis=-1).numpy()
        )
        for i, j in index:
            select.append(x[int(i), int(j)])

        x = paddle.stack(select) @ self.text_projection

        return x

    def forward(self, image, text):
        image_features = self.encode_image(image)
        text_features = self.encode_text(text)

        # normalized features
        image_features = image_features / \
            image_features.norm(axis=-1, keepdim=True)
        text_features = text_features / \
            text_features.norm(axis=-1, keepdim=True)

        # cosine similarity as logits
        logit_scale = self.logit_scale.exp()
        logits_per_image = logit_scale * image_features @ text_features.t()
        logits_per_text = logit_scale * text_features @ image_features.t()

        # shape = [global_batch_size, global_batch_size]
        return logits_per_image, logits_per_text
```

## **预设模型**


```python
def clip_rn50():
    return CLIP(
        embed_dim=1024,
        image_resolution=224,
        vision_layers=(3, 4, 6, 3),
        vision_width=64,
        vision_patch_size=None,
        context_length=77,
        vocab_size=49408,
        transformer_width=512,
        transformer_heads=8,
        transformer_layers=12
    )


def clip_rn101():
    return CLIP(
        embed_dim=512,
        image_resolution=224,
        vision_layers=(3, 4, 23, 3),
        vision_width=64,
        vision_patch_size=None,
        context_length=77,
        vocab_size=49408,
        transformer_width=512,
        transformer_heads=8,
        transformer_layers=12
    )


def clip_rn50x4():
    return CLIP(
        embed_dim=640,
        image_resolution=288,
        vision_layers=(4, 6, 10, 6),
        vision_width=80,
        vision_patch_size=None,
        context_length=77,
        vocab_size=49408,
        transformer_width=640,
        transformer_heads=10,
        transformer_layers=12
    )


def clip_vit_b_32():
    return CLIP(
        embed_dim=512,
        image_resolution=224,
        vision_layers=12,
        vision_width=768,
        vision_patch_size=32,
        context_length=77,
        vocab_size=49408,
        transformer_width=512,
        transformer_heads=8,
        transformer_layers=12
    )
```

# **网络测试**
* 使用相同输入测试模型前向计算是否正常
* 并与官方 Pytorch 实现对比输出是否一致
* 结果如下：


| Model | Paddle | Pytorch |
| -------- | -------- | -------- |
| RN50     | 18.1140 | 18.1140 |
| RN50\*4   | 29.5482 | 29.5482 |
| RN101    | 33.5211 | 33.5211  |
| VIT-B-32  | 27.5936 | 27.5936 |



## **RN50**


```python
model = clip_rn50()
params = paddle.load('data/data73499/RN50.pdparams')
model.set_dict(params)
model.eval()
image = paddle.ones((1, 3, 224, 224), dtype='float32') / 2.
text = paddle.ones((1, 77), dtype='int64')
print(model(image, text))
```

    W0521 14:51:07.542747    99 device_context.cc:362] Please NOTE: device: 0, GPU Compute Capability: 7.0, Driver API Version: 11.2, Runtime API Version: 10.1
    W0521 14:51:07.546696    99 device_context.cc:372] device: 0, cuDNN Version: 7.6.


    (Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[18.11398506]]), Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[18.11398315]]))


## **RN101**


```python
model = clip_rn101()
params = paddle.load('data/data73499/RN101.pdparams')
model.set_dict(params)
model.eval()
image = paddle.ones((1, 3, 224, 224), dtype='float32') / 2.
text = paddle.ones((1, 77), dtype='int64')
print(model(image, text))
```

    (Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[33.52115631]]), Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[33.52115631]]))


## **RN50*4**


```python
model = clip_rn50x4()
params = paddle.load('data/data73499/RN50x4.pdparams')
model.set_dict(params)
model.eval()
image = paddle.ones((1, 3, 288, 288), dtype='float32') / 2.
text = paddle.ones((1, 77), dtype='int64')
print(model(image, text))
```

    (Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[29.54818726]]), Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[29.54818535]]))



```python

```

## **VIT-B-32**


```python
model = clip_vit_b_32()
params = paddle.load('data/data73499/ViT-B-32.pdparams')
model.set_dict(params)
model.eval()
image = paddle.ones((1, 3, 224, 224), dtype='float32') / 2.
text = paddle.ones((1, 77), dtype='int64')
print(model(image, text))
```

    (Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[27.59356308]]), Tensor(shape=[1, 1], dtype=float32, place=CUDAPlace(0), stop_gradient=False,
           [[27.59356308]]))


# **总结**
* 这样一个模型就大致复现完成了
* 有关于这个模型的使用和 zero-shot 将在之后更新
