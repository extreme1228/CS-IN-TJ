import nn

class PerceptronModel(object):
    def __init__(self, dimensions):
        """
        Initialize a new Perceptron instance.

        A perceptron classifies data points as either belonging to a particular
        class (+1) or not (-1). `dimensions` is the dimensionality of the data.
        For example, dimensions=2 would mean that the perceptron must classify
        2D points.
        """
        self.w = nn.Parameter(1, dimensions)

    def get_weights(self):
        """
        Return a Parameter instance with the current weights of the perceptron.
        """
        return self.w

    def run(self, x):
        """
        Calculates the score assigned by the perceptron to a data point x.

        Inputs:
            x: a node with shape (1 x dimensions)
        Returns: a node containing a single number (the score)
        """
        "*** YOUR CODE HERE ***"
        #返回对应乘积，第一个参数是Node类型，大小batch_size * dimensions
        #第二个参数是权重weights参数，大小是1 * dimensions
        return nn.DotProduct(x,self.w)

    def get_prediction(self, x):
        """
        Calculates the predicted class for a single data point `x`.

        Returns: 1 or -1
        """
        "*** YOUR CODE HERE ***"
        #按题意模拟，节点权重乘积化为浮点型后大于等于0则返回1，否则为-1
        if nn.as_scalar(nn.DotProduct(x,self.w))>=0:
            return 1
        else:
            return -1

    def train(self, dataset):
        """
        Train the perceptron until convergence.
        """
        "*** YOUR CODE HERE ***"
        OK = True
        batch_size = 1
        while True:
            OK = True
            for x,y in dataset.iterate_once(batch_size):
                #因为二分类问题中题目确定y只会是1或-1，我们就可以通过
                #x的预测值是否和标签对照来确定是否更新完全
                if self.get_prediction(x) != nn.as_scalar(y):
                    OK = False
                    self.w.update(x,nn.as_scalar(y))
            if OK:
                break

class RegressionModel(object):
    """
    A neural network model for approximating a function that maps from real
    numbers to real numbers. The network should be sufficiently large to be able
    to approximate sin(x) on the interval [-2pi, 2pi] to reasonable precision.
    """
    def __init__(self):
        # Initialize your model parameters here
        "*** YOUR CODE HERE ***"
        #测试数据取100个
        self.batch_size = 100
        #我们采用两个隐藏层，每个隐藏层中使用100个节点组成,每个层进行线性回归f1 = k1*x+b1,f2 = k2*x+b2l
        #层之间采用非线性激活函数Relu来使得整个神经网络模拟非线性函数
        self.k1 = nn.Parameter(1,100)
        self.b1 = nn.Parameter(1,100)
        self.k2 = nn.Parameter(100,1)
        self.b2 = nn.Parameter(1,1)
        #定义学习率
        self.alpha = 0.01

    def run(self, x):
        """
        Runs the model for a batch of examples.

        Inputs:
            x: a node with shape (batch_size x 1)
        Returns:
            A node with shape (batch_size x 1) containing predicted y-values
        """
        "*** YOUR CODE HERE ***"
        #第一层线性回归
        g1 = nn.Linear(x,self.k1)
        f1 = nn.AddBias(g1,self.b1)
        #层之间非线性激活
        new_f = nn.ReLU(f1)
        #第二层线性回归
        g2 = nn.Linear(new_f,self.k2)
        f2 = nn.AddBias(g2,self.b2)
        return f2


    def get_loss(self, x, y):
        """
        Computes the loss for a batch of examples.

        Inputs:
            x: a node with shape (batch_size x 1)
            y: a node with shape (batch_size x 1), containing the true y-values
                to be used for training
        Returns: a loss node
        """
        "*** YOUR CODE HERE ***"
        return nn.SquareLoss(self.run(x),y)

    def train(self, dataset):
        """
        Trains the model.
        """
        "*** YOUR CODE HERE ***"
        while True:
            for x,y in dataset.iterate_once(self.batch_size):
                loss = self.get_loss(x,y)
                grad = nn.gradients(loss,[self.k1,self.b1,self.k2,self.b2])

                self.k1.update(grad[0],-self.alpha)
                self.b1.update(grad[1],-self.alpha)
                self.k2.update(grad[2],-self.alpha)
                self.b2.update(grad[3],-self.alpha)

                if nn.as_scalar(self.get_loss(nn.Constant(dataset.x),nn.Constant(dataset.y)))<0.01:
                    return

class DigitClassificationModel(object):
    """
    A model for handwritten digit classification using the MNIST dataset.

    Each handwritten digit is a 28x28 pixel grayscale image, which is flattened
    into a 784-dimensional vector for the purposes of this model. Each entry in
    the vector is a floating point number between 0 and 1.

    The goal is to sort each digit into one of 10 classes (number 0 through 9).

    (See RegressionModel for more information about the APIs of different
    methods here. We recommend that you implement the RegressionModel before
    working on this part of the project.)
    """
    def __init__(self):
        # Initialize your model parameters here
        "*** YOUR CODE HERE ***"
        #测试数据
        self.batch_size = 100
        #设计两层网络中的参数
        self.k1 = nn.Parameter(784,200)
        self.b1 = nn.Parameter(1,200)
        self.k2 = nn.Parameter(200,100)
        self.b2 = nn.Parameter(1,100)
        self.k3 = nn.Parameter(100,10)
        self.b3 = nn.Parameter(1,10)
        #学习率
        self.alpha = 0.1

    def run(self, x):
        """
        Runs the model for a batch of examples.

        Your model should predict a node with shape (batch_size x 10),
        containing scores. Higher scores correspond to greater probability of
        the image belonging to a particular class.

        Inputs:
            x: a node with shape (batch_size x 784)
        Output:
            A node with shape (batch_size x 10) containing predicted scores
                (also called logits)
        """
        "*** YOUR CODE HERE ***"
        f1 = nn.AddBias(nn.Linear(x,self.k1),self.b1)
        new_f1 = nn.ReLU(f1)
        f2 = nn.AddBias(nn.Linear(new_f1,self.k2),self.b2)
        new_f2 = nn.ReLU(f2)
        f3 = nn.AddBias(nn.Linear(new_f2,self.k3),self.b3)
        return f3

    def get_loss(self, x, y):
        """
        Computes the loss for a batch of examples.

        The correct labels `y` are represented as a node with shape
        (batch_size x 10). Each row is a one-hot vector encoding the correct
        digit class (0-9).

        Inputs:
            x: a node with shape (batch_size x 784)
            y: a node with shape (batch_size x 10)
        Returns: a loss node
        """
        "*** YOUR CODE HERE ***"
        return nn.SoftmaxLoss(self.run(x),y)

    def train(self, dataset):
        """
        Trains the model.
        """
        "*** YOUR CODE HERE ***"
        while True:
            for x,y in dataset.iterate_once(self.batch_size):
                loss = self.get_loss(x,y)
                grad = nn.gradients(loss,[self.k1,self.b1,self.k2,self.b2,self.k3,self.b3])

                #更新
                self.k1.update(grad[0],-self.alpha)
                self.b1.update(grad[1],-self.alpha)
                self.k2.update(grad[2],-self.alpha)
                self.b2.update(grad[3],-self.alpha)
                self.k3.update(grad[4],-self.alpha)
                self.b3.update(grad[5],-self.alpha)

                if dataset.get_validation_accuracy() >0.973:
                    return

class LanguageIDModel(object):
    """
    A model for language identification at a single-word granularity.

    (See RegressionModel for more information about the APIs of different
    methods here. We recommend that you implement the RegressionModel before
    working on this part of the project.)
    """
    def __init__(self):
        # Our dataset contains words from five different languages, and the
        # combined alphabets of the five languages contain a total of 47 unique
        # characters.
        # You can refer to self.num_chars or len(self.languages) in your code
        self.num_chars = 47
        self.languages = ["English", "Spanish", "Finnish", "Dutch", "Polish"]

        # Initialize your model parameters here
        "*** YOUR CODE HERE ***"
        self.batch_size = 200
        #神经网络设计中，我们对于f_initial函数设计两层网络，实现方式基本和task2,task3一致
        #对于RNN中的hidden层，我们同样设计两层
        self.k = nn.Parameter(self.num_chars,200)
        self.k_x = nn.Parameter(200,200)
        self.k_f = nn.Parameter(200,5)

        self.alpha = 0.1

    def run(self, xs):
        """
        Runs the model for a batch of examples.

        Although words have different lengths, our data processing guarantees
        that within a single batch, all words will be of the same length (L).

        Here `xs` will be a list of length L. Each element of `xs` will be a
        node with shape (batch_size x self.num_chars), where every row in the
        array is a one-hot vector encoding of a character. For example, if we
        have a batch of 8 three-letter words where the last word is "cat", then
        xs[1] will be a node that contains a 1 at position (7, 0). Here the
        index 7 reflects the fact that "cat" is the last word in the batch, and
        the index 0 reflects the fact that the letter "a" is the inital (0th)
        letter of our combined alphabet for this task.

        Your model should use a Recurrent Neural Network to summarize the list
        `xs` into a single node of shape (batch_size x hidden_size), for your
        choice of hidden_size. It should then calculate a node of shape
        (batch_size x 5) containing scores, where higher scores correspond to
        greater probability of the word originating from a particular language.

        Inputs:
            xs: a list with L elements (one per character), where each element
                is a node with shape (batch_size x self.num_chars)
        Returns:
            A node with shape (batch_size x 5) containing predicted scores
                (also called logits)
        """
        "*** YOUR CODE HERE ***"
        for i in range(len(xs)):
            if i == 0:
                #对第一个字符做特殊处理
                h = nn.ReLU(nn.Linear(xs[i],self.k))
            else :
                h = nn.ReLU(nn.Add(nn.Linear(xs[i],self.k),nn.Linear(h,self.k_x)))
        return nn.Linear(h,self.k_f)

    def get_loss(self, xs, y):
        """
        Computes the loss for a batch of examples.

        The correct labels `y` are represented as a node with shape
        (batch_size x 5). Each row is a one-hot vector encoding the correct
        language.

        Inputs:
            xs: a list with L elements (one per character), where each element
                is a node with shape (batch_size x self.num_chars)
            y: a node with shape (batch_size x 5)
        Returns: a loss node
        """
        "*** YOUR CODE HERE ***"
        return nn.SoftmaxLoss(self.run(xs),y)

    def train(self, dataset):
        """
        Trains the model.
        """
        "*** YOUR CODE HERE ***"
        while True:
            for x,y in dataset.iterate_once(self.batch_size):
                loss = self.get_loss(x,y)
                grad = nn.gradients(loss,[self.k,self.k_x,self.k_f])

                self.k.update(grad[0],-self.alpha)
                self.k_x.update(grad[1],-self.alpha)
                self.k_f.update(grad[2],-self.alpha)

                if dataset.get_validation_accuracy() >0.85:
                    return


