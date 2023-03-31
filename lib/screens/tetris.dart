import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../custom/custom_button.dart';

class TetrisScreen extends StatefulWidget {
  const TetrisScreen({super.key});

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen> {
  static List<List<int>> pieces = [
    [4, 5, 14, 15], // O
    [4, 14, 24, 25], // L
    [5, 15, 24, 25], // J
    [4, 14, 24, 34], // I
    [4, 14, 15, 25], // S
    [5, 15, 14, 24], // Z
    [4, 5, 6, 15] // T
  ];

  static List<List<int>> lPieces = [
    [4, 14, 24, 25],
    [13, 14, 15, 23],
    [3, 4, 14, 24],
    [5, 13, 14, 15]
  ];

  static List<List<int>> jPieces = [
    [5, 15, 24, 25],
    [4, 14, 15, 16],
    [5, 6, 15, 25],
    [14, 15, 16, 26]
  ];

  static List<List<int>> iPieces = [
    [4, 14, 24, 34],
    [23, 24, 25, 26]
  ];

  static List<List<int>> sPieces = [
    [4, 14, 15, 25],
    [5, 6, 14, 15]
  ];

  static List<List<int>> zPieces = [
    [5, 15, 14, 24],
    [14, 15, 25, 26]
  ];

  static List<List<int>> tPieces = [
    [4, 5, 6, 15],
    [-5, 4, 5, 15],
    [-5, 4, 5, 6],
    [-5, 5, 6, 15]
  ];

  var backgroundColor = const Color.fromRGBO(17, 17, 27, 1);
  var borderColor = const Color.fromRGBO(49, 50, 68, 1);
  List<Color> pieceColors = [
    Colors.red.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.yellow.shade300,
    Colors.orange.shade300,
    Colors.indigo.shade300,
    Colors.brown.shade300,
  ];
  // Keep track of landed pieces original colors
  List<Color> landedPieceColors = [];
  // Hold a list of landed pieces
  List<int> landed = [];
  // The current chosen piece
  List<int> chosenPiece = [];
  // Hold the original piece shape
  List<int> initialChosenPiece = [];
  int moveYDistance = 0;
  int moveXDistance = 0;

  final numberOfSquare = 150;
  final random = Random();
  static const baseSpeed = 250;
  int speedModifier = 4;
  int initialSwitchIndex = 1;
  late Timer timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    landedPieceColors = [
      for (var i = 0; i <= numberOfSquare; i++) backgroundColor
    ];
    startGame();
  }

  void startGame() {
    choosePiece();
    movePieceToUpper();
    timer = launchTimer();
  }

  Timer launchTimer() {
    var ref = Timer.periodic(Duration(milliseconds: baseSpeed * speedModifier),
        (Timer timer) {
      clearRow();

      if (hitFloor()) {
        for (var i = 0; i < chosenPiece.length; i++) {
          landed.add(chosenPiece[i]);
          var landedColor = pieceColors[pieces.indexWhere((item) =>
              item.every((element) => initialChosenPiece.contains(element)))];
          landedPieceColors[chosenPiece[i]] = lighten(landedColor);
        }
        startGame();
        timer.cancel();
      } else {
        moveDown();
      }
    });
    return ref;
  }

  // Choose a random piece from the `pieces` list
  void choosePiece() {
    chosenPiece = List.from(pieces[random.nextInt(pieces.length)]);
    initialChosenPiece = List.from(chosenPiece);
    moveYDistance = 0;
    moveXDistance = 0;
  }

  // Move the chosen piece to upper of the screen
  void movePieceToUpper() {
    chosenPiece.sort();
    while (chosenPiece.last >= 0) {
      for (var i = 0; i < chosenPiece.length; i++) {
        if (mounted) {
          setState(() {
            chosenPiece[i] -= 10;
          });
        }
      }
      moveYDistance -= 10;
    }
  }

  // Continiously update the chosen piece position down
  void moveDown() {
    for (var i = 0; i < chosenPiece.length; i++) {
      if (mounted) {
        setState(() {
          chosenPiece[i] += 10;
        });
      }
    }
    moveYDistance += 10;
  }

  // Check if the current piece hit bottom boundary or another piece
  bool hitFloor() {
    bool hitFloor = false;
    chosenPiece.sort();

    if (chosenPiece.last + 10 >= numberOfSquare) {
      hitFloor = true;
    }

    for (int i = 0; i < chosenPiece.length; i++) {
      if (landed.contains(chosenPiece[i] + 10)) {
        hitFloor = true;
      }
    }

    return hitFloor;
  }

  // Move left for 1 square, check if that square has a landed piece
  void moveLeft() {
    if (chosenPiece
        .any((elem) => (elem) % 10 == 0 || landed.contains(elem - 1))) {
    } else {
      if (mounted) {
        setState(() {
          for (int i = 0; i < chosenPiece.length; i++) {
            chosenPiece[i] -= 1;
          }
        });
      }
    }
    moveXDistance -= 1;
  }

  // Move right for 1 square, check if that square has a landed piece
  void moveRight() {
    if (chosenPiece
        .any((elem) => (elem + 1) % 10 == 0 || landed.contains(elem + 1))) {
    } else {
      if (mounted) {
        setState(() {
          for (int i = 0; i < chosenPiece.length; i++) {
            chosenPiece[i] += 1;
          }
        });
      }
    }
    moveXDistance += 1;
  }

  // Rotating the current chosen piece base on its original shape
  void rotate() {
    var oldPos = List.from(chosenPiece);

    for (var i = 0; i < chosenPiece.length; i++) {
      chosenPiece[i] -= moveYDistance;
    }

    if (lPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(lPieces);
    } else if (jPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(jPieces);
    } else if (iPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(iPieces);
    } else if (sPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(sPieces);
    } else if (zPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(zPieces);
    } else if (tPieces.any((item) =>
        item.every((element) => initialChosenPiece.contains(element)))) {
      transform(tPieces);
    }

    for (int i = 0; i < chosenPiece.length; i++) {
      chosenPiece[i] += moveYDistance;
      chosenPiece[i] += moveXDistance;
    }

    // Check if hit boundaries or landed block
    if (chosenPiece.any((element) => element >= numberOfSquare)) {
      chosenPiece = List.from(oldPos);
    }

    if (moveXDistance < 0) {
      if (chosenPiece
          .any((elem) => (elem) % 10 == 9 || landed.contains(elem))) {
        chosenPiece = List.from(oldPos);
      }
    }

    if (moveXDistance > 0) {
      if (chosenPiece.any((elem) => (elem + 1) % 10 == 1)) {
        chosenPiece = List.from(oldPos);
      }
    }
  }

  // Transform the given piece
  // arr: which piece list to transform, for example the L block will be rotate 90 deg
  void transform(List<List<int>> arr) {
    var index = arr.indexWhere((item) =>
        item.every((element) => chosenPiece.contains(element + moveXDistance)));
    if (index + 1 == arr.length) {
      if (mounted) {
        setState(() {
          chosenPiece = List.from(arr[0]);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          chosenPiece = List.from(arr[index + 1]);
        });
      }
    }
  }

  // Ligntening the given color
  // return the ligntened color
  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  void clearRow() {
    int count;
    List<int> removeRow = [];

    for (int i = 0; i < numberOfSquare / 10; i++) {
      removeRow.clear();
      count = 0;
      for (int j = 0; j < 10; j++) {
        if (landed.contains(numberOfSquare - 1 - i * 10 - j)) {
          removeRow.add(numberOfSquare - 1 - i * 10 - j);
          count++;
        }

        if (count == 10) {
          setState(() {
            score++;

            for (var element in removeRow) {
              landed.remove(element);
            }

            for (var element in removeRow) {
              landedPieceColors[element] = landedPieceColors[element - 10];
            }

            for (int q = 0; q < landed.length; q++) {
              if (landed[q] < removeRow.first) {
                landed[q] += 10;
              }
            }
          });
        }
      }
    }
  }

  void setSpeed(int? index) {
    if (index == null) {
    } else {
      setState(() {
        switch (index) {
          case 0:
            speedModifier = 8;
            break;
          case 1:
            speedModifier = 4;
            break;
          case 2:
            speedModifier = 2;
            break;
        }
        initialSwitchIndex = index;

        timer.cancel();
        timer = launchTimer();
      });
    }
  }

  void fasten() {
    setState(() {
      speedModifier = 1;

      timer.cancel();
      timer = launchTimer();
    });
  }

  void returnToNormalSpeed() {
    setState(() {
      switch (initialSwitchIndex) {
        case 0:
          speedModifier = 8;
          break;
        case 1:
          speedModifier = 4;
          break;
        case 2:
          speedModifier = 2;
          break;
      }

      timer.cancel();
      timer = launchTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Tetris';

    FlutterStatusbarcolor.setStatusBarColor(backgroundColor, animate: true);
    FlutterStatusbarcolor.setNavigationBarColor(backgroundColor, animate: true);

    return MaterialApp(
      title: title,
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          textTheme: GoogleFonts.jetBrainsMonoTextTheme(
            Theme.of(context).textTheme,
          )),
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        splashColor: Colors.blue.shade300,
                        iconSize: 24,
                        iconPath: "assets/icons/back.svg",
                        callback: () => {}),
                  ),
                  Expanded(
                    flex: 6,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        score.toString(),
                        textAlign: TextAlign.center,
                        key: ValueKey<String>(score.toString()),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                        splashColor: Colors.blue.shade300,
                        iconSize: 24,
                        iconPath: "assets/icons/color.svg",
                        callback: () => {}),
                  ),
                ],
              ),
              Expanded(
                flex: 6,
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Swipe right
                      if (details.velocity.pixelsPerSecond.dx < 1) {
                        moveLeft();
                      } else {
                        moveRight();
                      }
                    },
                    onVerticalDragEnd: (details) {
                      returnToNormalSpeed();
                    },
                    onVerticalDragUpdate: (details) => {
                      // If user is scrolling down, fasten the piece
                      if (details.delta.direction < pi / 2) {fasten()}
                    },
                    onTap: () => rotate(),
                    child: GridView.count(
                      crossAxisCount: 10,
                      padding: const EdgeInsets.all(36),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(numberOfSquare, (index) {
                        return Container(
                          key: Key(index.toString()),
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              border: chosenPiece.contains(index)
                                  ? Border.all(color: backgroundColor)
                                  : Border.all(color: borderColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              color: chosenPiece.contains(index)
                                  ? pieceColors[pieces.indexWhere((item) =>
                                      item.every((element) => initialChosenPiece
                                          .contains(element)))]
                                  : landed.contains(index)
                                      ? landedPieceColors[index]
                                      : backgroundColor),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleSwitch(
                        minWidth: 70.0,
                        minHeight: 32.0,
                        initialLabelIndex: initialSwitchIndex,
                        activeFgColor: Colors.red,
                        inactiveFgColor: Colors.white,
                        activeBgColor: const [Colors.transparent],
                        inactiveBgColor: Colors.transparent,
                        totalSwitches: 3,
                        icons: const [
                          Icons.ac_unit_outlined,
                          Icons.directions_walk_rounded,
                          Icons.accessible_forward_outlined
                        ],
                        dividerColor: Colors.transparent,
                        borderColor: const [Colors.transparent],
                        iconSize: 28.0,
                        onToggle: (index) {
                          setSpeed(index);
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
