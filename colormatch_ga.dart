import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColorGameScreen(),
    );
  }
}

class ColorGameScreen extends StatefulWidget {
  @override
  _ColorGameScreenState createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> {
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange
  ];

  Color targetColor = Colors.red;
  Color playerColor = Colors.blue;

  int score = 0;
  bool matched = false;

  Timer? timer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    changeTarget();

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 3), (t) {
      changeTarget(); // ⚡ auto difficulty
    });
  }

  void changeTarget() {
    setState(() {
      targetColor = colors[random.nextInt(colors.length)];
    });
  }

  void changePlayerColor() {
    setState(() {
      playerColor = colors[random.nextInt(colors.length)];

      if (playerColor == targetColor) {
        score++;
        matched = true;

        // 🎉 animation reset
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() => matched = false);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Color Match Game"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: startGame,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 📊 Score
          Text(
            "Score: $score",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),

          SizedBox(height: 30),

          // 🎯 Target Box
          Text("Target Color",
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 120,
            width: 120,
            color: targetColor,
          ),

          SizedBox(height: 50),

          // 🎨 Player Box
          Text("Tap to Match",
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),

          GestureDetector(
            onTap: changePlayerColor,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: matched ? 140 : 120,
              width: matched ? 140 : 120,
              decoration: BoxDecoration(
                color: playerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          SizedBox(height: 40),

          Text(
            "Match colors before it changes!",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
