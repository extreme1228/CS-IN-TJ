# search.py
# ---------
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


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).
"""

import util

class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()


def tinyMazeSearch(problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    from game import Directions
    s = Directions.SOUTH
    w = Directions.WEST
    return  [s, s, w, s, w, w, s, w]

def depthFirstSearch(problem: SearchProblem):
    """
    Search the deepest nodes in the search tree first.

    Your search algorithm needs to return a list of actions that reaches the
    goal. Make sure to implement a graph search algorithm.

    To get started, you might want to try some of these simple commands to
    understand the search problem that is being passed in:

    print("Start:", problem.getStartState())
    print("Is the start a goal?", problem.isGoalState(problem.getStartState()))
    print("Start's successors:", problem.getSuccessors(problem.getStartState()))
    """
    "*** YOUR CODE HERE ***"
    st=util.Stack() #定义栈
    start_pos=[problem.getStartState(),[]] #栈内元素为坐标和起始点到该点的路径
    st.push(start_pos)
    visited=set()#记录当前坐标是否访问过，防止重复访问
    while not st.isEmpty():
        [now_pos,path]=st.pop()#取出栈顶元素
        if(problem.isGoalState(now_pos)):
            return path #如果已经到达目标地点，直接返回path路径
        if not now_pos in visited:
            visited.add(now_pos)#将该节点标记为已读
            for new_state,new_action,new_cost in problem.getSuccessors(now_pos):
                #遍历新节点
                new_path=path+[new_action]
                st.push([new_state,new_path])
    util.raiseNotDefined()

def breadthFirstSearch(problem: SearchProblem):
    """Search the shallowest nodes in the search tree first."""
    "*** YOUR CODE HERE ***"
    #bfs代码和dfs代码逻辑相似，主要是把栈换成了队列
    q=util.Queue()#定义队列
    start_pos=[problem.getStartState(),[]] #栈内元素为坐标和起始点到该点的路径
    q.push(start_pos)
    visited=set()
    while not q.isEmpty():
        [now_pos,path]=q.pop()
        if(problem.isGoalState(now_pos)):
            return path
        if not now_pos in visited:
            visited.add(now_pos)
            for new_state,new_action,new_cost in problem.getSuccessors(now_pos):
                new_path=path+[new_action]
                q.push([new_state,new_path])
    util.raiseNotDefined()

def uniformCostSearch(problem: SearchProblem):
    """Search the node of least total cost first."""
    "*** YOUR CODE HERE ***"
    #UCS是一致代价搜索，在算法领域实质上等价与Dijstra算法，我们在实现该算法时采用优先队列的
    #数据结构，并按照距离起始点的距离作为优先比较的键值，值越小，优先级越高
    pq=util.PriorityQueue()#定义优先队列
    start_pos=problem.getStartState()
    distance={start_pos:0}#distance字典刻画了图中的每个点距离起始点的最短路径长度，没有加入字典时默认为无限大
    visited=set()#标记该位置是否访问过
    pq.push([start_pos,[]],distance[start_pos])
    while not pq.isEmpty():
        [now_pos,now_path]=pq.pop()
        if now_pos in visited:
            continue
        visited.add(now_pos)
        if problem.isGoalState(now_pos):
            return now_path
        for new_pos,new_action,step_cost in problem.getSuccessors(now_pos):
            new_cost=step_cost+distance[now_pos]
            if not new_pos in distance or new_cost < distance[new_pos]:
                distance[new_pos]=new_cost
                new_path=now_path+[new_action]
                pq.push([new_pos,new_path],distance[new_pos])
    util.raiseNotDefined()

def nullHeuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0

def aStarSearch(problem: SearchProblem, heuristic=nullHeuristic):
    """Search the node that has the lowest combined cost and heuristic first."""
    "*** YOUR CODE HERE ***"
    #A*搜索是对UCS搜索和贪婪代价搜索的合理结合，其主要思想和UCS算法相似，关键在于
    #启发式函数的构造
    visited=set()
    pq=util.PriorityQueue()
    start_pos=problem.getStartState()
    start_state=[start_pos,[]]
    f_score={start_pos:heuristic(start_pos,problem)}
    g_score={start_pos:0}
    pq.push(start_state,f_score[start_pos])
    while not pq.isEmpty():
        [now_pos,now_path]=pq.pop()
        if now_pos in visited:
            continue
        visited.add(now_pos)
        if problem.isGoalState(now_pos):
            return now_path
        for new_pos,new_action,step_cost in problem.getSuccessors(now_pos):
            new_cost=step_cost+g_score[now_pos]
            if not new_pos in g_score or new_cost<g_score[new_pos]:
                g_score[new_pos]=new_cost
                f_score[new_pos]=g_score[new_pos]+heuristic(new_pos,problem)
                new_path=now_path+[new_action]
                pq.push([new_pos,new_path],f_score[new_pos])

    util.raiseNotDefined()


# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
