import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ball Catch Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double ballSize = 30;
  static const double paddleHeight = 15;
  static const double paddleWidth = 100;

  double ballX = 0;
  double ballY = 0;
  double ballSpeedY = 3;
  double paddleX = 0;
  int score = 0;
  double speedMultiplier = 1.0;
  bool isPlaying = false;
  Timer? gameTimer;
  final Random _random = Random();

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  void startGame() {
    resetBall();
    setState(() {
      score = 0;
      isPlaying = true;
    });
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => update());
  }

  void resetBall() {
    ballX = _random.nextDouble() * (screenWidth - ballSize);
    ballY = 0;
  }

  void update() {
    setState(() {
      ballY += ballSpeedY * speedMultiplier;

      // Ball reached bottom
      if (ballY + ballSize >= screenHeight - paddleHeight - 80) {
        final paddleLeft = paddleX;
        final paddleRight = paddleX + paddleWidth;
        final ballCenter = ballX + ballSize / 2;

        if (ballCenter >= paddleLeft && ballCenter <= paddleRight) {
          score++;
        } else {
          score--;
        }
        resetBall();
      }
    });
  }

  void resetGame() {
    gameTimer?.cancel();
    setState(() {
      score = 0;
      isPlaying = false;
      ballY = 0;
      ballX = 100;
      paddleX = 0;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    paddleX = paddleX.clamp(0, screenWidth - paddleWidth);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Score
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Speed controls
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Speed:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (speedMultiplier > 0.5) {
                      setState(() => speedMultiplier = (speedMultiplier - 0.5).clamp(0.5, 4.0));
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${speedMultiplier.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    if (speedMultiplier < 4.0) {
                      setState(() => speedMultiplier = (speedMultiplier + 0.5).clamp(0.5, 4.0));
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Ball
          if (isPlaying)
            Positioned(
              left: ballX,
              top: ballY,
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Paddle (drag to move)
          if (isPlaying)
            Positioned(
              left: paddleX,
              bottom: 80,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    paddleX = (paddleX + details.delta.dx)
                        .clamp(0, screenWidth - paddleWidth);
                  });
                },
                child: Container(
                  width: paddleWidth,
                  height: paddleHeight,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

          // Tap anywhere to move paddle (alternative control)
          if (isPlaying)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  setState(() {
                    paddleX = (details.localPosition.dx - paddleWidth / 2)
                        .clamp(0, screenWidth - paddleWidth);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    paddleX = (details.localPosition.dx - paddleWidth / 2)
                        .clamp(0, screenWidth - paddleWidth);
                  });
                },
              ),
            ),

          // Start / Reset buttons
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPlaying)
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Start', style: TextStyle(fontSize: 18)),
                  ),
                if (isPlaying) ...[
                  ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ],
            ),
          ),

          // Game over hint
          if (!isPlaying && score != 0)
            Center(
              child: Text(
                score > 0 ? 'Nice! Score: $score' : 'Game Over! Score: $score',
                style: TextStyle(
                  fontSize: 24,
                  color: score > 0 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
