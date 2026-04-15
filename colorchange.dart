import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Match Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ColorMatchGame(),
    );
  }
}

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  // Target color (the color player needs to match)
  Color targetColor = Colors.blue;
  
  // Current color (player's selected color)
  Color currentColor = Colors.red;
  
  // Score
  int score = 0;
  
  // Timer
  int timeLeft = 30;
  Timer? gameTimer;
  bool isGameActive = true;
  
  // List of colors to choose from
  List<Color> colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
  ];
  
  // Color names for display
  Map<Color, String> colorNames = {
    Colors.red: "RED",
    Colors.green: "GREEN",
    Colors.blue: "BLUE",
    Colors.yellow: "YELLOW",
    Colors.orange: "ORANGE",
    Colors.purple: "PURPLE",
    Colors.pink: "PINK",
    Colors.brown: "BROWN",
    Colors.cyan: "CYAN",
    Colors.indigo: "INDIGO",
  };

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameActive = true;
      randomizeTargetColor();
      currentColor = colorOptions[0];
    });
    startTimer();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0 && isGameActive) {
          timeLeft--;
        } else {
          timer.cancel();
          isGameActive = false;
        }
      });
    });
  }

  void randomizeTargetColor() {
    setState(() {
      int randomIndex = (DateTime.now().millisecondsSinceEpoch % colorOptions.length).toInt();
      targetColor = colorOptions[randomIndex];
    });
  }

  void changeCurrentColor(Color newColor) {
    if (!isGameActive) return;
    
    setState(() {
      currentColor = newColor;
      
      // Check if colors match
      if (currentColor.value == targetColor.value) {
        // Match found!
        score++;
        randomizeTargetColor();
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ MATCH! +1 point (Total: $score)"),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void resetGame() {
    gameTimer?.cancel();
    startGame();
  }

  Color getTimerColor() {
    if (timeLeft <= 10) return Colors.red;
    if (timeLeft <= 20) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎨 Color Match Game"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score and Timer Row
            Row(
              children: [
                // Score Card
                Expanded(
                  child: Card(
                    color: Colors.purple.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text("SCORE", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "$score",
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Timer Card
                Expanded(
                  child: Card(
                    color: getTimerColor().withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text("TIME LEFT", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "$timeLeft",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: getTimerColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Target Color Display
            const Text("🎯 TARGET COLOR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: targetColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                ],
              ),
              child: Center(
                child: Text(
                  colorNames[targetColor] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current Color Display
            const Text("👉 YOUR COLOR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Tap on current color container - changes color to next option
                if (isGameActive) {
                  int currentIndex = colorOptions.indexOf(currentColor);
                  int nextIndex = (currentIndex + 1) % colorOptions.length;
                  changeCurrentColor(colorOptions[nextIndex]);
                }
              },
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tap_and_play, color: Colors.white, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        colorNames[currentColor] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      const Text(
                        "TAP TO CHANGE",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Color Options Grid (Alternative tap method)
            const Text("OR TAP ANY COLOR BELOW", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: colorOptions.length,
                itemBuilder: (context, index) {
                  Color color = colorOptions[index];
                  return GestureDetector(
                    onTap: () => changeCurrentColor(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentColor == color ? Colors.white : Colors.grey,
                          width: currentColor == color ? 3 : 1,
                        ),
                        boxShadow: [
                          if (currentColor == color)
                            BoxShadow(color: color, blurRadius: 8, spreadRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          colorNames[color]?.substring(0, 1) ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Game Over Message and Reset Button
            if (!isGameActive)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "⏰ GAME OVER!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    Text(
                      "Your final score: $score",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: resetGame,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            
            // Game Active Hint
            if (isGameActive)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb, size: 16),
                    SizedBox(width: 4),
                    Text("💡 Tip: Tap the large color box OR tap any color below to change", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
