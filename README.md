# Controlling the level of a system with four reservoirs interconnected using Reinforcment Learning - Q-Learning

#### The System (plant)

The plant is composed of 4 interconnected tanks, 1 is connected to 2, 2 connected to 3 and so on. tanks 2 and 4 have holes in the botton, so water can flow both direction, wich makes the system somewhat complex to model and control properly

![123](https://user-images.githubusercontent.com/23335136/54704935-77a44d00-4b1a-11e9-9eaf-d6c7c22756d3.png)

#### Q-Learning

Q-learning is a reinforcement learning technique used in machine learning. The purpose of Q-Learning is to learn a policy, which tells an agent what action to take under certain circumstances. It does not require an environment model and can handle problems with transitions and stochastic rewards without requiring adaptations.

For any finite Markov decision process (FMDP), Q-learning finds a policy that is optimal in that it maximizes the expected value of the total reward over all successive steps from the current state. Q-learning can identify an optimal policy of action selection for any FMDP, given infinite time of exploration and a partly random policy. "Q" names the function that returns the reward used to provide reinforcement and can be considered the "quality" of an action taken in a given state. The function Q will be aproximated by an matrix table in this code.

Used for the update of the table Q, is the optimality principle of Bellman. A definition of recursion for an optimal Q function. Q(S(t), A(t)) equals the sum of the immediate reward after performing an action at some time and an expected future reward after a transition to a next state.
The equation applied in the algorithm Q-Learning has a bonus for this work it will speed up the convergence.

Q(S(t),A(t) )←Q(S(t),A(t) )+ α[R(t+1)+γQ(S(t+1),A(t+1) )-Q(S(t),A(t) )+Bonus]

Algorithm flow

for each iteration:
1. Initialize table Q: Construct a table Q. There are n columns, where indicates the number of shares. There are lines, where m = number of states. Initialize the values to 0.
2. Choose action to take: The action is chosen according to the Q-Table
3. Take the action
4. Observe the environment and measure reward
5. Update Q-Table
end

#### Results

Using 0.05 for Learning-Rate (somewhat low) and linear error as the loss function, we get the result bellow, in yellow you see the action taken by the Q-Learning, in blue is the reference and in red the reservoir height.

![123](https://user-images.githubusercontent.com/23335136/54705489-b2f34b80-4b1b-11e9-9cc4-54ce7fd98559.png)

For more details, you can read the text in TG2.pdf
