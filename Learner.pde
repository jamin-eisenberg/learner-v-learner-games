import java.util.Random;

public class Learner {
  private double[][] payoffs;
  private double[][] allWeights;
  private double[] currWeights;
  private double recencyIndex;
  private double errorRate;
  private int allWeightsCount;
  private boolean isPlayer2;
  private Random rand;

  private double[][] allWeightsTotal;

  //used for reset only:
  private double[] initWeights;
  private int gamesPerLearner;

  public Learner(double[][] payoffs, double[] initWeights, double recencyIndex, double errorRate, int gamesPerLearner, boolean isPlayer2) {
    this.payoffs = payoffs;
    this.currWeights = new double[initWeights.length];
    for (int i = 0; i < initWeights.length; i++) {
      currWeights[i] = initWeights[i];
    }
    this.recencyIndex = recencyIndex;
    this.errorRate = errorRate;
    allWeights = new double[gamesPerLearner][initWeights.length];
    for (int i = 0; i < initWeights.length; i++) allWeights[0][i] = initWeights[i];
    allWeightsCount = 1;
    this.isPlayer2 = isPlayer2;
    rand = new Random();

    this.allWeightsTotal = new double[allWeights.length][allWeights[0].length];
    for (int i = 0; i < allWeightsTotal.length; i++) {
      for (int j = 0; j < allWeightsTotal[0].length; j++) {
        allWeightsTotal[i][j] = 0;
      }
    }

    this.initWeights = initWeights;
    this.gamesPerLearner = gamesPerLearner;
  }

  public double[] getCurrWeights() { 
    return currWeights;
  }

  public int getGamesPerLearner() { 
    return gamesPerLearner;
  }

  public double[][] getPayoffs() { 
    return payoffs;
  }

  public double[][] getAllWeights() { 
    return allWeights;
  }

  public boolean isPlayer2() { 
    return isPlayer2;
  }

  public double[][] getAllWeightsTotal() {
    return allWeightsTotal;
  }

  private void printWeights() {
    for (double i : currWeights) print(i + " ");
    println();
  }

  public int pick() {
    double randNum = rand.nextInt(102);

    sumWeights();

    if (randNum < errorRate * 100 + 1) {
      return rand.nextInt(currWeights.length);
    }

    double total = 0;
    for (int i = 0; i < currWeights.length; i++) {
      total += currWeights[i];
    }

    randNum = rand.nextDouble() * total;
    for (int i = 0; i < currWeights.length; i++) {
      randNum -= currWeights[i];
      if (randNum < 0) {
        return i;
      }
    }

    return -1;
  }

  public void resolvePayoff(int pick, int opponentPick) {
    double payoff;
    if (isPlayer2) payoff = payoffs[opponentPick][pick];
    else           payoff = payoffs[pick][opponentPick];

    for (int i = 0; i < currWeights.length; i++) {
      allWeights[allWeightsCount - 1][i] = 0;
    }

    allWeights[allWeightsCount - 1][pick] = payoff;
    allWeightsCount++;
  }

  private void sumWeights() {
    for (int i = 0; i < currWeights.length; i++) {
      for (int j = 0; j < allWeights.length; j++) {
        allWeights[j][i] *= recencyIndex;
        currWeights[i] += allWeights[j][i];
      }
    }
  }

  public void reset() {
    //add allWeights to allWeightsTotal
    for (int i = 0; i < allWeightsTotal.length; i++) {
      for (int j = 0; j < allWeightsTotal[0].length; j++) {
        allWeightsTotal[i][j] += allWeights[i][j];
      }
    }

    this.currWeights = new double[initWeights.length];
    for (int i = 0; i < initWeights.length; i++) {
      currWeights[i] = initWeights[i];
    }
    allWeights = new double[gamesPerLearner][initWeights.length];
    for (int i = 0; i < initWeights.length; i++) allWeights[0][i] = initWeights[i];
    allWeightsCount = 1;
    rand = new Random();
  }
}
