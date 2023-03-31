import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tetranova/screens/tetris.dart';

import '../custom/animated_page_route.dart';
import '../custom/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var gameMode = "Normal";
  var availableGameMode = ["Slow", "Normal", "Fast"];

  var borderColor = const Color.fromRGBO(49, 50, 68, 1);
  var backgroundColor = const Color.fromRGBO(17, 17, 27, 1);

  void swipeLeft() {
    setState(() {
      var index = availableGameMode.indexOf(gameMode);
      if (index + 1 < availableGameMode.length) {
        gameMode = availableGameMode[index + 1];
      }
    });
  }

  void swipeRight() {
    setState(() {
      var index = availableGameMode.indexOf(gameMode);
      if (index > 0) gameMode = availableGameMode[index - 1];
    });
  }

  @override
  Widget build(BuildContext ctx) {
    FlutterStatusbarcolor.setStatusBarColor(backgroundColor, animate: true);
    FlutterStatusbarcolor.setNavigationBarColor(backgroundColor, animate: true);

    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          textTheme: GoogleFonts.quicksandTextTheme(
            Theme.of(context).textTheme,
          )),
      home: SafeArea(
        child: Scaffold(
          body: Column(children: [
            Container(
                alignment: Alignment.centerRight,
                child: CustomButton(
                    splashColor: Colors.blue.shade300,
                    iconSize: 24,
                    iconPath: "assets/icons/color.svg",
                    callback: () => {})),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      "assets/icons/tetris.svg",
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 128,
                      height: 128,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        splashColor: Colors.blue.shade300,
                        iconSize: 12,
                        iconPath: "assets/icons/arrow-left.svg",
                        callback: swipeRight,
                      ),
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          // Swipe right
                          if (details.velocity.pixelsPerSecond.dx < 1) {
                            swipeLeft();
                          } else {
                            swipeRight();
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: SizedBox(
                          width: 150.0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: Text(
                              gameMode,
                              textAlign: TextAlign.center,
                              key: ValueKey<String>(gameMode),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      CustomButton(
                        splashColor: Colors.blue.shade300,
                        iconSize: 12,
                        iconPath: "assets/icons/arrow-right.svg",
                        callback: swipeLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () => {
                      Navigator.of(context).push(AnimatedPageRoute(
                          builder: (context) => const TetrisScreen()))
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(255),
                      ),
                      side: BorderSide(width: 2.0, color: borderColor),
                      fixedSize: const Size.fromWidth(256),
                    ),
                    child: const Text(
                      "New Game",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      splashColor: Colors.blue.shade300,
                      iconSize: 28,
                      iconPath: "assets/icons/settings.svg",
                      callback: () => {},
                    )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      splashColor: Colors.blue.shade300,
                      iconSize: 24,
                      iconPath: "assets/icons/shop.svg",
                      callback: () => {},
                    )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      splashColor: Colors.blue.shade300,
                      iconSize: 28,
                      iconPath: "assets/icons/list.svg",
                      callback: () => {},
                    )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      splashColor: Colors.blue.shade300,
                      iconSize: 28,
                      iconPath: "assets/icons/about.svg",
                      callback: () => {},
                    )),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
