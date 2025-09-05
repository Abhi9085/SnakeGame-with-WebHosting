import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snakegame/blank_pixel.dart';
import 'package:snakegame/food_pixel.dart';
import 'package:snakegame/snake_pixel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'highscore_tile.dart';

// ignore: camel_case_types, constant_identifier_names
enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  int currentScore = 0;
  List<int> snakePos = [0, 1, 2];
  var currDirection = snake_Direction.RIGHT;
  int foodPos = 55;

  // Highscore IDs
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    super.initState();
    letsGetDocIds = getDocId();
  }

  Future getDocId() async {
    highscore_DocIds.clear();
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5) // top 5 players
        .get()
        .then((value) {
      for (var element in value.docs) {
        highscore_DocIds.add(element.reference.id);
      }
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
        if (gameOver()) {
          timer.cancel();
          showDialog(
            barrierDismissible: false,
              context: context,
                builder: (context) => Dialog(
                backgroundColor: Colors.black.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
                child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💀 GAME OVER!',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                      Text('Score: $currentScore',
                      style: const TextStyle(
                      color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 10),
                    TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                    hintText: 'Enter Name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    submitScore(); // save score only if name entered
                  }
                  Navigator.pop(context);
                  newGame();
                  },
                  child: const Text('Submit'),
                  ),
                  const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                      Navigator.pop(context); // just close dialog
                      newGame(); // reset game without saving
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      });
    });
  }

  void submitScore() {
    FirebaseFirestore.instance.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  bool gameOver() {
    List<int> snakeBody = snakePos.sublist(0, snakePos.length - 1);
    return snakeBody.contains(snakePos.last);
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void moveSnake() {
    switch (currDirection) {
      case snake_Direction.RIGHT:
        snakePos.add(
          snakePos.last % rowSize == rowSize - 1
              ? snakePos.last + 1 - rowSize
              : snakePos.last + 1,
        );
        break;
      case snake_Direction.LEFT:
        snakePos.add(
          snakePos.last % rowSize == 0
              ? snakePos.last - 1 + rowSize
              : snakePos.last - 1,
        );
        break;
      case snake_Direction.UP:
        snakePos.add(
          snakePos.last < rowSize
              ? snakePos.last - rowSize + totalNumberOfSquares
              : snakePos.last - rowSize,
        );
        break;
      case snake_Direction.DOWN:
        snakePos.add(
          snakePos.last + rowSize >= totalNumberOfSquares
              ? snakePos.last + rowSize - totalNumberOfSquares
              : snakePos.last + rowSize,
        );
        break;
    }

    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Focus(
          autofocus: true,
          onKey: (FocusNode node, RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                  currDirection != snake_Direction.UP) {
                currDirection = snake_Direction.DOWN;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
                  currDirection != snake_Direction.DOWN) {
                currDirection = snake_Direction.UP;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                  currDirection != snake_Direction.RIGHT) {
                currDirection = snake_Direction.LEFT;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                  currDirection != snake_Direction.LEFT) {
                currDirection = snake_Direction.RIGHT;
              }
            }
            return KeyEventResult.handled;
          },
          child: SizedBox(
            width: screenWidth > 428 ? 428 : screenWidth,
            child: Column(
              children: [
                // Score + highscores
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Current score
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Current Score',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Top 5 Highscores
                      Expanded(
                        child: Card(
                          color: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(8),
                          child: FutureBuilder(
                            future: letsGetDocIds,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                itemCount: highscore_DocIds.length,
                                itemBuilder: (context, index) {
                                  return HighscoreTile(
                                      documentId: highscore_DocIds[index]);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Game grid
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy > 0 &&
                            currDirection != snake_Direction.UP) {
                          currDirection = snake_Direction.DOWN;
                        } else if (details.delta.dy < 0 &&
                            currDirection != snake_Direction.DOWN) {
                          currDirection = snake_Direction.UP;
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 0 &&
                            currDirection != snake_Direction.LEFT) {
                          currDirection = snake_Direction.RIGHT;
                        } else if (details.delta.dx < 0 &&
                            currDirection != snake_Direction.RIGHT) {
                          currDirection = snake_Direction.LEFT;
                        }
                      },
                      child: GridView.builder(
                        itemCount: totalNumberOfSquares,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowSize,
                        ),
                          itemBuilder: (context, index) {
                          // HEAD must be checked first
                          if (snakePos.isNotEmpty && snakePos.last == index) {
                          // DO NOT use const here because isHead is runtime
                            return SnakePixel(isHead: true);
                          } else if (snakePos.contains(index)) {
                            return SnakePixel(isHead: false);
                          } else if (foodPos == index) {
                            return const FoodPixel();
                          } else {
                            return const BlankPixel();
                          }
                    },

                      ),
                    ),
                  ),
                ),

                // Play button
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: gameHasStarted ? Colors.grey : Colors.pink,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: gameHasStarted
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                      ),
                      child: MaterialButton(
                        onPressed: gameHasStarted ? null : startGame,
                        child: const Text("PLAY",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/*import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snakegame/blank_pixel.dart';
import 'package:snakegame/food_pixel.dart';
import 'package:snakegame/snake_pixel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'highscore_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  int currentScore = 0;
  List<int> snakePos = [0, 1, 2];
  var currDirection = snake_Direction.RIGHT;
  int foodPos = 55;

  // Highscore IDs
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    super.initState();
    letsGetDocIds = getDocId();
  }

  Future getDocId() async {
    highscore_DocIds.clear();
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then((value) {
      for (var element in value.docs) {
        highscore_DocIds.add(element.reference.id);
      }
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
        if (gameOver()) {
          timer.cancel();
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Game Over!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Score: $currentScore'),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Enter Name'),
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    submitScore();
                    Navigator.pop(context);
                    newGame();
                  },
                  color: Colors.pink,
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  void submitScore() {
    FirebaseFirestore.instance.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((_) => getDocId().then((_) => setState(() {}))); // refresh top scores
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  bool gameOver() {
    List<int> snakeBody = snakePos.sublist(0, snakePos.length - 1);
    return snakeBody.contains(snakePos.last);
  }

  Future newGame() async {
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void moveSnake() {
    switch (currDirection) {
      case snake_Direction.RIGHT:
        snakePos.add(
          snakePos.last % rowSize == rowSize - 1
              ? snakePos.last + 1 - rowSize
              : snakePos.last + 1,
        );
        break;
      case snake_Direction.LEFT:
        snakePos.add(
          snakePos.last % rowSize == 0
              ? snakePos.last - 1 + rowSize
              : snakePos.last - 1,
        );
        break;
      case snake_Direction.UP:
        snakePos.add(
          snakePos.last < rowSize
              ? snakePos.last - rowSize + totalNumberOfSquares
              : snakePos.last - rowSize,
        );
        break;
      case snake_Direction.DOWN:
        snakePos.add(
          snakePos.last + rowSize >= totalNumberOfSquares
              ? snakePos.last + rowSize - totalNumberOfSquares
              : snakePos.last + rowSize,
        );
        break;
    }

    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                currDirection != snake_Direction.UP) {
              currDirection = snake_Direction.DOWN;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
                currDirection != snake_Direction.DOWN) {
              currDirection = snake_Direction.UP;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                currDirection != snake_Direction.RIGHT) {
              currDirection = snake_Direction.LEFT;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                currDirection != snake_Direction.LEFT) {
              currDirection = snake_Direction.RIGHT;
            }
          }
          return KeyEventResult.handled;
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              // Score row + Top 5
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Current score
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Current Score:',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          currentScore.toString(),
                          style: const TextStyle(
                              fontSize: 36, color: Colors.white),
                        ),
                      ],
                    ),

                    // Top 5 Highscores
                    Expanded(
                      child: FutureBuilder(
                        future: letsGetDocIds,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (highscore_DocIds.isEmpty) {
                            return const Center(
                              child: Text(
                                "No Highscores",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: highscore_DocIds.length,
                            itemBuilder: (context, index) {
                              return HighscoreTile(
                                documentId: highscore_DocIds[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Game grid
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0 &&
                          currDirection != snake_Direction.UP) {
                        currDirection = snake_Direction.DOWN;
                      } else if (details.delta.dy < 0 &&
                          currDirection != snake_Direction.DOWN) {
                        currDirection = snake_Direction.UP;
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 0 &&
                          currDirection != snake_Direction.LEFT) {
                        currDirection = snake_Direction.RIGHT;
                      } else if (details.delta.dx < 0 &&
                          currDirection != snake_Direction.RIGHT) {
                        currDirection = snake_Direction.LEFT;
                      }
                    },
                    child: GridView.builder(
                      itemCount: totalNumberOfSquares,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowSize),
                      itemBuilder: (context, index) {
                        if (snakePos.contains(index)) {
                          return const SnakePixel();
                        } else if (foodPos == index) {
                          return const FoodPixel();
                        } else {
                          return const BlankPixel();
                        }
                      },
                    ),
                  ),
                ),
              ),

              // Play button
              Expanded(
                child: Center(
                  child: MaterialButton(
                    color: gameHasStarted ? Colors.grey : Colors.pink,
                    child: const Text("PLAY"),
                    onPressed: gameHasStarted ? () {} : startGame,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
//above is working fine

/*import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snakegame/blank_pixel.dart';
import 'package:snakegame/food_pixel.dart';
import 'package:snakegame/snake_pixel.dart';
import 'package:snakegame/highscore_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // grid size
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // game state
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  // score
  int currentScore = 0;

  // snake
  List<int> snakePos = [0, 1, 2];
  var currDirection = snake_Direction.RIGHT;

  // food
  int foodPos = 55;

  // --- Firestore handling ---
  Future<List<String>> getDocIds() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  void submitScore() async {
    var database = FirebaseFirestore.instance;
    await database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });

    // refresh UI so that highscores update
    setState(() {});
  }

  // --- game mechanics ---
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();

        if (gameOver()) {
          timer.cancel();

          // show dialog
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game Over!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Score: $currentScore'),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Name:',
                      ),
                    ),
                  ],
                ),
                actions: [
                  MaterialButton(
                    color: Colors.pink,
                    onPressed: () {
                      submitScore();
                      Navigator.pop(context);
                      newGame();
                    },
                    child: const Text("Submit"),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  bool gameOver() {
    List<int> snakeBody = snakePos.sublist(0, snakePos.length - 1);
    return snakeBody.contains(snakePos.last);
  }

  void newGame() {
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void moveSnake() {
    switch (currDirection) {
      case snake_Direction.RIGHT:
        if (snakePos.last % rowSize == rowSize - 1) {
          snakePos.add(snakePos.last + 1 - rowSize);
        } else {
          snakePos.add(snakePos.last + 1);
        }
        break;
      case snake_Direction.LEFT:
        if (snakePos.last % rowSize == 0) {
          snakePos.add(snakePos.last - 1 + rowSize);
        } else {
          snakePos.add(snakePos.last - 1);
        }
        break;
      case snake_Direction.UP:
        if (snakePos.last < rowSize) {
          snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
        } else {
          snakePos.add(snakePos.last - rowSize);
        }
        break;
      case snake_Direction.DOWN:
        if (snakePos.last + rowSize > totalNumberOfSquares) {
          snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
        } else {
          snakePos.add(snakePos.last + rowSize);
        }
        break;
    }

    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(
          children: [
            // Score + Highscores
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Current Score
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Current Score:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        currentScore.toString(),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Highscores list
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: getDocIds(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docIds = snapshot.data!;
                        return ListView.builder(
                          itemCount: docIds.length,
                          itemBuilder: (context, index) {
                            return HighscoreTile(documentId: docIds[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Snake Grid
            Expanded(
              flex: 3,
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currDirection != snake_Direction.UP) {
                      currDirection = snake_Direction.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currDirection != snake_Direction.DOWN) {
                      currDirection = snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currDirection != snake_Direction.LEFT) {
                      currDirection = snake_Direction.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currDirection != snake_Direction.RIGHT) {
                      currDirection = snake_Direction.LEFT;
                    }
                  },
                  child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize,
                    ),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    },
                  ),
                ),
              ),
            ),

            // Play Button
            Expanded(
              child: Center(
                child: MaterialButton(
                  color: gameHasStarted ? Colors.grey : Colors.pink,
                  onPressed: gameHasStarted ? () {} : startGame,
                  child: const Text("PLAY"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
