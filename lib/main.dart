import 'package:flutter/material.dart';

void main() => runApp(const TicTacToe());

class TicTacToe extends StatelessWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List<List<AnimationController?>> matrix = [];
  List<List<String?>> valuesMatrix = [];
  String currentPlayer = "X";

  @override
  void initState() {
    super.initState();
    resetGame();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showInstructions();
    });
  }

  void showInstructions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Instructions"),
          content: const Text(
              "This is a simple game of Tic Tac Toe. Player One is 'X', and Player Two is 'O'. Players take turns tapping on the grid to place their mark. The first player to get three of their marks in a row (up, down, across, or diagonally) is the winner. When all squares are full, the game is over. Good luck!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controllers in matrix) {
      for (var controller in controllers) {
        controller?.dispose();
      }
    }
    super.dispose();
  }

  void resetGame() {
    setState(() {
      matrix = List.generate(
        3,
        (_) => List.generate(
          3,
          (_) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 400),
          ),
        ),
      );

      valuesMatrix = List.generate(3, (_) => List.generate(3, (_) => null));
      currentPlayer = "X";
    });
  }

  void markCell(int x, int y) {
    if (matrix[x][y]?.isCompleted ?? false) return;

    setState(() {
      matrix[x][y]
        ?..value = 1.0
        ..addListener(() {
          setState(() {});
        });
      valuesMatrix[x][y] = currentPlayer;
      checkForWin(x, y);
      currentPlayer = currentPlayer == "X" ? "O" : "X";
    });
  }

  void checkForWin(int x, int y) {
    var paths = [
      valuesMatrix[x],
      valuesMatrix.map((e) => e[y]).toList(),
      [valuesMatrix[0][0], valuesMatrix[1][1], valuesMatrix[2][2]],
      [valuesMatrix[0][2], valuesMatrix[1][1], valuesMatrix[2][0]]
    ];

    for (var path in paths) {
      if (path.every((b) => b == "X")) {
        showWinDialog("X");
        return;
      }
      if (path.every((b) => b == "O")) {
        showWinDialog("O");
        return;
      }
    }
  }

  void showWinDialog(String player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("$player is the winner!"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  int x, y = 0;
                  x = index ~/ 3;
                  y = index % 3;
                  return GestureDetector(
                    onTap: () {
                      markCell(x, y);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey[700]!),
                      ),
                      child: Center(
                        child: FadeTransition(
                          opacity: matrix[x][y]
                                  ?.drive(CurveTween(curve: Curves.easeIn)) ??
                              const AlwaysStoppedAnimation(0.0),
                          child: Text(
                            valuesMatrix[x][y] ?? "",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 32.0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: resetGame,
              child: const Text("Reset Game"),
            ),
          ],
        ),
      ),
    );
  }
}
