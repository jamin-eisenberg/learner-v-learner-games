import g4p_controls.*;
import java.util.Scanner;
import java.awt.Font;

Learner l1, l2;

boolean graphing;
int currStrat = 0;
//polish: auto-upgrade to integers > 0?, better graph display manipulation?, more precise error messages?, one weights box?, COMMENTS?
final int xMin = 25;
final int xMax = 620;
final int yMin = 785;
final int yMax = 440;

public void setup() {
  size(930, 810, JAVA2D);
  createGUI();
  customGUI();

  graphing = false;
}

public void draw() {
  background(230);

  stroke(0);

  line(10, 370, width - 10, 370);
  line(660, 10, 660, height - 10);
  line(xMin, yMax, xMin, yMin);
  line(xMin, yMin, xMax, yMin);

  if (graphing) {
    int p1Strats = l1.getCurrWeights().length;
    int player, playerStrat;

    if (currStrat < p1Strats) player = 1;
    else player = 2;

    if (currStrat < p1Strats) {
      playerStrat = currStrat + 1;
    } else {
      playerStrat = currStrat - p1Strats + 1;
    }

    strategyLabel.setText("Player " + player + "\nStrategy " + playerStrat);
    if (player == 1) graph(getPoints(playerStrat - 1, l1.getAllWeightsTotal()));
    else             graph(getPoints(playerStrat - 1, l2.getAllWeightsTotal()));
  }
}

public void graph(int[] points) { //x always increases by one, so 1 dimension
  stroke(0, 0, 255);
  int gamesPerLearner = l1.getGamesPerLearner();
  int x = 0, y;
  int prevX = 0, prevY = 0;
  int mappedX, mappedY;

  for (int i = 0; i < points.length; i++) {
    x++;
    y = points[i];
    mappedX = (int)map(x, 1, gamesPerLearner, xMin, xMax);
    mappedY = (int)map(y, 0, 100, yMin, yMax);
    if (i == 1)     line(xMin, mappedY, mappedX, mappedY);
    else if (i > 1) line(prevX, prevY, mappedX, mappedY);
    prevX = mappedX;
    prevY = mappedY;
  }
}

public void run() {
  int gamesPerLearner = Integer.valueOf(gamesPerSimText.getText());
  int learnersPerBatch = Integer.valueOf(numSimsText.getText());

  for (int i = 0; i < learnersPerBatch; i++) {
    for (int j = 0; j < gamesPerLearner; j++) {
      int l1Pick = l1.pick();
      int l2Pick = l2.pick();

      l1.resolvePayoff(l1Pick, l2Pick);
      l2.resolvePayoff(l2Pick, l1Pick);
    }

    l1.reset();
    l2.reset();
  }
}

public void setFinalResultsText() {
  String str = "Final results:\n(may not add to 100 because of rounding errors)\n(Player Strategy Result)\n";

  int[] points1, points2;

  for (int currStrat = 0; currStrat < l1.currWeights.length; currStrat++) {
    points1 = getPoints(currStrat, l1.allWeightsTotal);
    str += "1, " + (currStrat + 1) + ", " + points1[points1.length-1] + "%\n";
  }
  for (int currStrat = 0; currStrat < l2.currWeights.length; currStrat++) {
    points2 = getPoints(currStrat, l2.allWeightsTotal);
    str += "2, " + (currStrat + 1) + ", " + points2[points2.length-1] + "%\n";
  }

  finalResultLabel.setText(str);
}

public void makeLearners() {
  int gamesPerLearner = Integer.valueOf(gamesPerSimText.getText()) + 1;
  String gameStr = gameText.getText(); //get strings from textboxes in GUI
  String p1WeightsStr = p1WeightsText.getText();  
  String p2WeightsStr = p2WeightsText.getText();
  boolean asymmetric = gameStr.contains(",");
  double recencyIndex = recencySlider.getValueF();
  double errorRate = errorSlider.getValueF();
  double[] p1Weights = strToWeights(p1WeightsStr);
  double[] p2Weights = strToWeights(p2WeightsStr);

  if (p2WeightsStr.equals("") || p2WeightsStr.equals(" ")) {
    p2Weights = new double[p1Weights.length];
    for (int i = 0; i < p2Weights.length; i++) {
      p2Weights[i] = p1Weights[i];
    }
  }

  if (asymmetric) {
    String[] matrices = splitMatrix(gameStr);
    l1 = new Learner(strToMatrix(matrices[0]), p1Weights, recencyIndex, errorRate, gamesPerLearner, false);
    l2 = new Learner(strToMatrix(matrices[1]), p2Weights, recencyIndex, errorRate, gamesPerLearner, true);
  } else {
    double[][] gameMat = strToMatrix(gameStr);
    l1 = new Learner(gameMat, p1Weights, recencyIndex, errorRate, gamesPerLearner, false);
    l2 = new Learner(flipDiag(gameMat), p2Weights, recencyIndex, errorRate, gamesPerLearner, true);
  }
}

public double[][] flipDiag(double[][] mat) {
  double[][] newMat = new double[mat.length][mat[0].length];
  for (int i = 0; i < newMat.length; i++) {
    for (int j = 0; j < newMat[0].length; j++) {
      newMat[i][j] = mat[j][i];
    }
  }

  return newMat;
}

public double[] strToWeights(String weightsStr) {
  Scanner scanner = new Scanner(weightsStr);
  int weightsLength = 0;
  while (scanner.hasNext()) {
    scanner.next();
    weightsLength++;
  }

  double[] weights = new double[weightsLength];
  scanner = new Scanner(weightsStr);
  int pos = 0;
  while (scanner.hasNextDouble()) {
    weights[pos] = scanner.nextDouble();
    pos++;
  }

  return weights;
}

public String[] splitMatrix(String gameStr) {
  gameStr = gameStr.replace("\n", " \n ");
  Scanner scanner = new Scanner(gameStr).useDelimiter(" ");
  String[] result = {"", ""};

  while (scanner.hasNext()) {
    String token = scanner.next();
    if (token.contains("\n")) {
      result[0] += "\n";
      result[1] += "\n";
      continue;
    }
    try {
      String[] curr = token.split(",");
      result[0] += curr[0] + " ";
      result[1] += curr[1] + " ";
    }
    catch(ArrayIndexOutOfBoundsException e) {
    } //somehow spaces make their way in and it tries to split them by commas
  }

  return result;
}

public double[][] strToMatrix(String str) {
  int width = 0, height = 0;

  Scanner lineScanner = new Scanner(str);
  while (lineScanner.hasNextLine()) {
    String line = lineScanner.nextLine();
    width = line.split(" ").length;
    height++;
  }

  double[][] mat = new double[height][width];

  Scanner numScanner = new Scanner(str);

  int pos = 0;
  while (numScanner.hasNextInt()) {
    mat[pos / width][pos % width] = numScanner.nextInt();
    pos++;
  }

  return mat;
}

public void printMatrix(int[][] mat) {
  for (int i = 0; i < mat.length; i++) {
    for (int j = 0; j < mat[0].length; j++) {
      print(mat[i][j] + " ");
    }
    println();
  }
}

public int[] getPoints(int playerStrat, double[][] allWeightsTotal) {
  int[] points = new int[allWeightsTotal.length];
  double[] currWeights = new double[allWeightsTotal[0].length];

  for (int k = 0; k < points.length; k++) {
    for (double e : currWeights) e = 0;

    for (int i = 0; i < currWeights.length; i++) {
      for (int j = 0; j < k; j++) {
        currWeights[i] += allWeightsTotal[j][i];
      }
    }
    points[k] = (int)(100 * currWeights[playerStrat] / total(currWeights));
  }

  return points;
}

public double total(double[] arr) {
  double total = 0;
  for (int i = 0; i < arr.length; i++) {
    total += arr[i];
  }
  return total;
}

public void setMatrixRepText() {
  int[][] matrix = new int[l1.payoffs.length][l1.payoffs[0].length];
  String str = "Matrix Play Representation:\n\n\n";

  int[] p1Percents = new int[l1.currWeights.length];
  int[] p2Percents = new int[l2.currWeights.length];
  int[] points1, points2;

  for (int currStrat = 0; currStrat < p1Percents.length; currStrat++) {
    points1 = getPoints(currStrat, l1.allWeightsTotal);
    p1Percents[currStrat] = points1[points1.length-1];
  }
  for (int currStrat = 0; currStrat < p2Percents.length; currStrat++) {
    points2 = getPoints(currStrat, l2.allWeightsTotal);
    p2Percents[currStrat] = points2[points2.length-1];
  }

  for (int i = 0; i < matrix.length; i++) {
    for (int j = 0; j < matrix[0].length; j++) {
      matrix[i][j] = p1Percents[i] * p2Percents[j] / 100;
      str += String.format("%-4d", matrix[i][j]);
    }
    str += "\n";
  }

  matrixRepLabel.setText(str);
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI() {
  Font font = new Font("SanSerif", Font.PLAIN, 18);

  gameLabel.setFont(font);
  gameText.setFont(font);
  errorLabel.setFont(font);
  weightLabel.setFont(font);
  p1WeightsText.setFont(font);
  runGameButton.setFont(font);
  p2WeightsText.setFont(font);
  gamesPerLearnerLabel.setFont(font);
  learnersPerBatchLabel.setFont(font);
  yMaxLabel.setFont(font);
  yMinLabel.setFont(font);
  xMinLabel.setFont(font);
  xMaxLabel.setFont(font);
  nextLineButton.setFont(font);
  inputErrorLabel.setFont(font);
  strategyLabel.setFont(font);
  prevLineButton.setFont(font);
  //yLabel.setFont(font);
  //xLabel.setFont(font);
  recencyLabel.setFont(font);
  finalResultLabel.setFont(font);
  numSimsText.setFont(font);
  gamesPerSimText.setFont(font);
  matrixRepLabel.setFont(new Font("mono", Font.PLAIN, 18));
}
