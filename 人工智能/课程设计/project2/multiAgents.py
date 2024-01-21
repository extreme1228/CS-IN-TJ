# multiAgents.py
# --------------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from util import manhattanDistance
from game import Directions
import random, util

from game import Agent
from pacman import GameState

class ReflexAgent(Agent):
    """
    A reflex agent chooses an action at each choice point by examining
    its alternatives via a state evaluation function.

    The code below is provided as a guide.  You are welcome to change
    it in any way you see fit, so long as you don't touch our method
    headers.
    """


    def getAction(self, gameState: GameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {NORTH, SOUTH, WEST, EAST, STOP}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()

        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores)
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState: GameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successorGameState = currentGameState.generatePacmanSuccessor(action)
        newPos = successorGameState.getPacmanPosition()
        newFood = successorGameState.getFood()
        newGhostStates = successorGameState.getGhostStates()
        newScaredTimes = [ghostState.scaredTimer for ghostState in newGhostStates]

        "*** YOUR CODE HERE ***"
        foodpos=newFood.asList()
        # 得到所有食物的位置，便于求出最近距离的食物位置
        food_dis=[]
        for pos in foodpos:
            food_dis.append(util.manhattanDistance(pos,newPos))
        ghost_dis=[]
        #求出距离最近的ghost的位置
        for ghost in newGhostStates:
            ghost_dis.append(util.manhattanDistance(ghost.getPosition(),newPos))
        if len(food_dis)==0 and min(ghost_dis)!=0:
            #如果只剩最后一个食物且ghost下一时刻不会出现在这个位置，我们就直接前往这个位置
            return float('inf')
        else:
            if len(food_dis)==0:
                #如果只剩最后一个食物但是ghost下一时刻会出现在该位置，我们一定不能前往该位置，否则会先被ghost杀死而不是吃完所有食物
                return (-float('inf'))
        #求出距离该位置最近的food的距离作为food_score
        food_score=min(food_dis) 
        #求出距离该位置最近的ghost作为ghost_score
        ghost_score=min(ghost_dis)
        if ghost_score==0:
            ghost_score=-float('inf')
        #调参，使得最优化
        #按照常理，最终的得分score应该和food距离负相关，与ghost距离正相关，所以我们采用ghost_score/food_score
        #作为初始函数，之后再调参
        return 2*successorGameState.getScore()+ghost_score/food_score**1.5

def scoreEvaluationFunction(currentGameState: GameState):
    """
    This default evaluation function just returns the score of the state.
    The score is the same one displayed in the Pacman GUI.

    This evaluation function is meant for use with adversarial search agents
    (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
    This class provides some common elements to all of your
    multi-agent searchers.  Any methods defined here will be available
    to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

    You *do not* need to make any changes here, but you can if you want to
    add functionality to all your adversarial search agents.  Please do not
    remove anything, however.

    Note: this is an abstract class: one that should not be instantiated.  It's
    only partially specified, and designed to be extended.  Agent (game.py)
    is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
    Your minimax agent (question 2)
    """

    def getAction(self, gameState: GameState):
        """
        Returns the minimax action from the current gameState using self.depth
        and self.evaluationFunction.

        Here are some method calls that might be useful when implementing minimax.

        gameState.getLegalActions(agentIndex):
        Returns a list of legal actions for an agent
        agentIndex=0 means Pacman, ghosts are >= 1

        gameState.generateSuccessor(agentIndex, action):
        Returns the successor game state after an agent takes an action

        gameState.getNumAgents():
        Returns the total number of agents in the game

        gameState.isWin():
        Returns whether or not the game state is a winning state

        gameState.isLose():
        Returns whether or not the game state is a losing state
        """
        "*** YOUR CODE HERE ***"
        def MaxValue(state,depth):
            depth+=1    #每次进入max函数depth加1表示扩展的搜索树深度加一
            if state.isWin() or state.isLose() or depth==self.depth:
                return self.evaluationFunction(state)
            pacan_score=-float('inf')
            for action in state.getLegalActions(self.index):
                next_state=state.generateSuccessor(self.index,action)
                pacan_score=max(pacan_score,MinValue(next_state,depth,1))
            return pacan_score
        def MinValue(state,depth,ghostid):
            #因为涉及到多个ghost，所以我们采用递归的方法，求出任意ghost走任意action所产生的排列组合中的最小值
            if state.isWin() or state.isLose():
                return self.evaluationFunction(state)
            ghost_score=float('inf')
            #遍历每一个ghost         
                    #对于每个ghost，遍历其所有可能的action
            for action in state.getLegalActions(ghostid):
                next_state=state.generateSuccessor(ghostid,action)
                if ghostid ==state.getNumAgents()-1:
                    #如果这已经是最后一个ghost，说明所有的ghost都走了一步，我们可以调用max
                    ghost_score=min(ghost_score,MaxValue(next_state,depth))
                else:
                    #否则的话，我们仍要递归调用min函数保证所有ghost都走了一步
                    ghost_score=min(ghost_score,MinValue(next_state,depth,ghostid+1))
            return ghost_score

        #初始score定义为负无穷
        score=-float('inf')
        res_action=''
        for action in gameState.getLegalActions(self.index):
            #以pacman为第一agent，求得任一下一个状态下的最优得分
            next_state=gameState.generateSuccessor(self.index,action)
            tmp_score=MinValue(next_state,0,1)
            if tmp_score>score:
                score=tmp_score
                res_action=action
        return res_action
        util.raiseNotDefined()

class AlphaBetaAgent(MultiAgentSearchAgent):
    """
    Your minimax agent with alpha-beta pruning (question 3)
    """

    def getAction(self, gameState: GameState):
        """
        Returns the minimax action using self.depth and self.evaluationFunction
        """
        "*** YOUR CODE HERE ***"
        def MaxValue(state,depth,alpha,beta):
            depth+=1    #每次进入max函数depth加1表示扩展的搜索树深度加一
            if state.isWin() or state.isLose() or depth==self.depth:
                return self.evaluationFunction(state)
            pacan_score=-float('inf')
            for action in state.getLegalActions(self.index):
                next_state=state.generateSuccessor(self.index,action)
                pacan_score=max(pacan_score,MinValue(next_state,depth,1,alpha,beta))
                #β剪枝
                if pacan_score>beta:
                    return pacan_score
                alpha=max(alpha,pacan_score)
            return pacan_score
        def MinValue(state,depth,ghostid,alpha,beta):
            #因为涉及到多个ghost，所以我们采用递归的方法，求出任意ghost走任意action所产生的排列组合中的最小值
            if state.isWin() or state.isLose():
                return self.evaluationFunction(state)
            ghost_score=float('inf')
            #遍历每一个ghost         
                    #对于每个ghost，遍历其所有可能的action
            for action in state.getLegalActions(ghostid):
                next_state=state.generateSuccessor(ghostid,action)
                if ghostid ==state.getNumAgents()-1:
                    #如果这已经是最后一个ghost，说明所有的ghost都走了一步，我们可以调用max
                    ghost_score=min(ghost_score,MaxValue(next_state,depth,alpha,beta))
                else:
                    #否则的话，我们仍要递归调用min函数保证所有ghost都走了一步
                    ghost_score=min(ghost_score,MinValue(next_state,depth,ghostid+1,alpha,beta))
                #α剪枝
                if ghost_score<alpha:
                    return ghost_score
                beta=min(beta,ghost_score)
            return ghost_score
        

        alpha=-float('inf')
        beta=float('inf')
        score=-float('inf')
        res_action=''
        for action in gameState.getLegalActions(self.index):
            next_state=gameState.generateSuccessor(self.index,action)
            tmp_score=MinValue(next_state,0,1,alpha,beta)
            if tmp_score>score:
                score=tmp_score
                res_action=action
                #注意这里要在外部函数实时更新α的值，否则不更新顶层α的值会导致接下来的剪枝出现问题
                alpha=score
        return res_action
        util.raiseNotDefined()

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def getAction(self, gameState: GameState):
        """
        Returns the expectimax action using self.depth and self.evaluationFunction

        All ghosts should be modeled as choosing uniformly at random from their
        legal moves.
        """
        "*** YOUR CODE HERE ***"
        def MaxValue(state,depth):
            depth+=1    #每次进入max函数depth加1表示扩展的搜索树深度加一
            if state.isWin() or state.isLose() or depth==self.depth:
                return self.evaluationFunction(state)
            pacan_score=-float('inf')
            for action in state.getLegalActions(self.index):
                next_state=state.generateSuccessor(self.index,action)
                pacan_score=max(pacan_score,ExpValue(next_state,depth,1))
            return pacan_score
        def ExpValue(state,depth,ghostid):
            #因为涉及到多个ghost，所以我们采用递归的方法，求出任意ghost走任意action所产生的排列组合中的最小值
            if state.isWin() or state.isLose():
                return self.evaluationFunction(state)
            ghost_score=0.0
            #遍历每一个ghost         
                    #对于每个ghost，遍历其所有可能的action
            for action in state.getLegalActions(ghostid):
                next_state=state.generateSuccessor(ghostid,action)
                if ghostid ==state.getNumAgents()-1:
                    #如果这已经是最后一个ghost，说明所有的ghost都走了一步，我们可以调用max
                    ghost_score+=MaxValue(next_state,depth)
                else:
                    #否则的话，我们仍要递归调用min函数保证所有ghost都走了一步
                    ghost_score+=ExpValue(next_state,depth,ghostid+1)
            #在考虑期望情况的情况下，我们改动min函数中返回的值，将最小值变为平均值
            return ghost_score

        score=-float('inf')
        res_action=''
        for action in gameState.getLegalActions(self.index):
            next_state=gameState.generateSuccessor(self.index,action)
            tmp_score=ExpValue(next_state,0,1)
            if tmp_score>score:
                score=tmp_score
                res_action=action
        return res_action
        util.raiseNotDefined()

def betterEvaluationFunction(currentGameState: GameState):
    """
    Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
    evaluation function (question 5).

    DESCRIPTION: <write something here so we know what you did>
    """
    "*** YOUR CODE HERE ***"

    newPos = currentGameState.getPacmanPosition()
    newFood = currentGameState.getFood()
    newGhostStates = currentGameState.getGhostStates()

    res_score=currentGameState.getScore()

    foodpos=newFood.asList()
    # 得到所有食物的位置，便于求出最近距离的食物位置
    food_dis=[]
    for pos in foodpos:
        food_dis.append(util.manhattanDistance(pos,newPos))
    if len(food_dis)>0:
        res_score+=10.0/min(food_dis)
    else:
        res_score+=10.0
    #求出距离最近的ghost的位置
    for ghost in newGhostStates:
       ghost_dis=util.manhattanDistance(ghost.getPosition(),newPos)
       if ghost_dis>0:
           if ghost.scaredTimer>0:
               res_score+=100.0/ghost_dis
           else:
               res_score-=10.0/ghost_dis
       else:
           return -float('inf')
    return res_score
    util.raiseNotDefined()

# Abbreviation
better = betterEvaluationFunction
