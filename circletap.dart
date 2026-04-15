import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap the Circle',
      debugShowCheckedModeBanner: false,
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
  int _score = 0;
  int _timeLeft = 30;
  bool _isGameActive = false;
  bool _isVisible = true;
  
  double _left = 100;
  double _top = 200;
  final Random _random = Random();
  
  final double _ballSize = 80;
  
  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
      _isVisible = true;
      _setRandomPosition();
    });
    _startTimer();
  }
  
  void _setRandomPosition() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    double minX = 10;
    double maxX = screenWidth - _ballSize - 10;
    double minY = 100;
    double maxY = screenHeight - _ballSize - 20;
    
    _left = minX + _random.nextDouble() * (maxX - minX);
    _top = minY + _random.nextDouble() * (maxY - minY);
  }
  
  void _startTimer() async {
    while (_timeLeft > 0 && _isGameActive) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isGameActive) {
        setState(() {
          _timeLeft--;
          if (_timeLeft == 0) {
            _isGameActive = false;
            _isVisible = false;
          }
        });
      }
    }
  }
  
  void _tapCircle() {
    if (!_isGameActive) return;
    if (!_isVisible) return;
    
    setState(() {
      _isVisible = false;
      _score++;
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _setRandomPosition();
          _isVisible = true;
        });
      }
    });
  }
  
  void _resetGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
      _isVisible = true;
      _setRandomPosition();
    });
    _startTimer();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            // Score and Timer Display
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Text('SCORE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5 ? Colors.red : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Text('TIME', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('${_timeLeft}s', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Game Area
            Expanded(
              child: Container(
                color: const Color(0xFF0f0f1a),
                child: Stack(
                  children: [
                    // Start Screen
                    if (!_isGameActive && _timeLeft == 30)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Tap the Circle Game',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tap on the orange circle to score points',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              ),
                              child: const Text('START GAME', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    
                    // Game Over Screen
                    if (!_isGameActive && _timeLeft == 0)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'GAME OVER',
                              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Final Score: $_score',
                              style: const TextStyle(color: Colors.orange, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              ),
                              child: const Text('PLAY AGAIN', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    
                    // Simple Circle - No double outline, just a pure orange circle
                    if (_isGameActive && _isVisible)
                      Positioned(
                        left: _left,
                        top: _top,
                        child: GestureDetector(
                          onTap: _tapCircle,
                          child: Container(
                            width: _ballSize,
                            height: _ballSize,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
