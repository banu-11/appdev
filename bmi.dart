import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BMICalculatorPage(),
    );
  }
}

class BMICalculatorPage extends StatefulWidget {
  @override
  _BMICalculatorPageState createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  
  double bmi = 0;
  String category = "";
  String advice = "";
  Color bgColor = Colors.blue;
  bool isCalculated = false;
  
  void calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0;
    double height = double.tryParse(heightController.text) ?? 0;
    
    if (weight > 0 && height > 0) {
      double heightInMeters = height / 100;
      bmi = weight / (heightInMeters * heightInMeters);
      
      if (bmi < 18.5) {
        category = "Underweight";
        advice = "🍎 Eat more nutritious foods";
        bgColor = Colors.orange;
      } else if (bmi >= 18.5 && bmi < 25) {
        category = "Normal Weight";
        advice = "💪 Maintain with balanced diet";
        bgColor = Colors.green;
      } else if (bmi >= 25 && bmi < 30) {
        category = "Overweight";
        advice = "🏃 Exercise regularly";
        bgColor = Colors.orange;
      } else {
        category = "Obese";
        advice = "⚠️ Consult a doctor";
        bgColor = Colors.red;
      }
      
      setState(() {
        isCalculated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height')),
      );
    }
  }
  
  void reset() {
    weightController.clear();
    heightController.clear();
    setState(() {
      isCalculated = false;
      bmi = 0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(  // ✅ Changed from ListView to Column
          children: [
            // Input Section (No Expanded needed here)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Enter Your Details', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: calculateBMI,
                            child: const Text('Calculate'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: reset,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Result Section - Using Flexible instead of Expanded
            if (isCalculated)
              Flexible(
                child: Card(
                  color: bgColor.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: bgColor, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'BMI: ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 35, 
                              fontWeight: FontWeight.bold, 
                              color: bgColor
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            advice,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            // Message when no calculation done yet
            if (!isCalculated)
              const Expanded(
                child: Center(
                  child: Text(
                    'Enter weight and height\nto calculate BMI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
