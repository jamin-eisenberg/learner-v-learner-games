# LearnerVLearnerGames project

Created by Jamin Eisenberg for PHIL 2001

Professor Rory Smead

11/4/2019


## Roth-Erev Reinforcement Learning Explanation
This type of learning is computationally very simple. You can imagine a bag filled with marbles that represent different strategies. The initial weights you give determine how many marbles of that type are in the bag.

A random marble is drawn out of the bag, and that learner plays the marble's strategy against the other player. The payoff found at the intersection of player 1's pick and player 2's pick determines how many additional marbles are put into the bag.

Therefore, strategies that give higher payoffs generally get more of their marbles into the bag, which gives them a higher probability of being chosen.

### Additional parameters
The two additions to this are the recency index and error rate. Recency represents memory. In practice, the constant you choose is multiplied by all past weights as the rounds go on.

The error rate just means that the learner picks a random strategy from an even distribution a certain percent of the time, rather than making an informed decision with the skewed distribution in the bag.


## Use Instructions
To run this project you will need Java, unless you are running 64-bit Windows.
Navigate to the folder that corresponds to your operating system and run the executable file. A window should open.

Restrictions to input are listed clearly in the paragraphs above input.

The text area in the upper left is where you can input a [payoff matrix](https://en.wikipedia.org/wiki/Game_theory#Symmetric_/_asymmetric) of your choice. If it's symmetric simply list space-separated values for a single player's payoff. If it's asymmetric, put commas in between two payoffs, one for each player.

The initial weights given to each strategy should be input into the two text boxes in the center. This dictates how likely it is, at the start, for the learner to play a certain strategy.

Recency index and error rate sliders can also be set: for their meaning, look at the learning explanation above.

You should also input an integer into each of the boxes label games per simulation and # of simulations. # of simulations dictates how many times the learners are reset to their initial weights and start over. All of the outputs show an average across how many simulations you choose to use.

When you have input all that you need, click the big red run game button. Results should be displayed as long as you did not make any errors.


## Output Interpretation
The graph represents the probability of the learners playing a certain strategy, given at the top right corner of the graph. You can view different strategies by clicking the blue buttons above the graph. The probability is averaged among all of the players across simulations, as stated above. With the right parameters, hopefully you will see that players converge on a certain strategy.

The two results on the right might not add to 100, even though they're theoretically supposed to, because of rounding errors.

The final results, in the top right, simply tell you precisely the last point of the graph for each strategy.

The matrix representation, in the bottom right, shows where play happened the most between the two players. These values are calculated by multiplying the final results above together for each location of the matrix.
