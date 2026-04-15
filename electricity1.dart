import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electricity Bill Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ElectricityBillPage(),
    );
  }
}

class ElectricityBillPage extends StatefulWidget {
  @override
  _ElectricityBillPageState createState() => _ElectricityBillPageState();
}

class _ElectricityBillPageState extends State<ElectricityBillPage> {
  // Dropdown values
  String selectedAppliance = 'Fan';
  
  // Appliance data (power in watts)
  Map<String, int> appliancePower = {
    'Fan': 75,
    'AC': 1500,
    'Refrigerator': 200,
    'Washing Machine': 500,
  };
  
  // User inputs
  double power = 75; // watts
  double usageHours = 8; // hours per day
  double numberOfDays = 30; // days
  double costPerUnit = 5; // cost per kWh
  
  // Controllers for text fields
  TextEditingController powerController = TextEditingController();
  TextEditingController usageController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  TextEditingController costController = TextEditingController();
  
  int counter = 0;
  
  @override
  void initState() {
    super.initState();
    updateControllers();
  }
  
  void updateControllers() {
    powerController.text = power.toString();
    usageController.text = usageHours.toString();
    daysController.text = numberOfDays.toString();
    costController.text = costPerUnit.toString();
  }
  
  void updateFromControllers() {
    setState(() {
      power = double.tryParse(powerController.text) ?? power;
      usageHours = double.tryParse(usageController.text) ?? usageHours;
      numberOfDays = double.tryParse(daysController.text) ?? numberOfDays;
      costPerUnit = double.tryParse(costController.text) ?? costPerUnit;
    });
  }
  
  // Calculate energy used (kWh)
  double calculateEnergyUsed() {
    double energyInKWh = (power * usageHours * numberOfDays) / 1000;
    return energyInKWh;
  }
  
  // Calculate monthly bill
  double calculateMonthlyBill() {
    return calculateEnergyUsed() * costPerUnit;
  }
  
  // Calculate yearly projection
  double calculateYearlyProjection() {
    return calculateMonthlyBill() * 12;
  }
  
  // Get color based on usage
  Color getUsageColor() {
    double energy = calculateEnergyUsed();
    if (energy > 300) {
      return Colors.red;
    } else if (energy > 100) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  String getUsageLevel() {
    double energy = calculateEnergyUsed();
    if (energy > 300) {
      return 'High Usage';
    } else if (energy > 100) {
      return 'Medium Usage';
    } else {
      return 'Low Usage';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electricity Bill Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Appliance Dropdown
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Appliance', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedAppliance,
                      isExpanded: true,
                      items: appliancePower.keys.map((String appliance) {
                        return DropdownMenuItem<String>(
                          value: appliance,
                          child: Text(appliance),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedAppliance = newValue!;
                          power = appliancePower[selectedAppliance]!.toDouble();
                          powerController.text = power.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Input Fields
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: powerController,
                      decoration: InputDecoration(
                        labelText: 'Power (Watts)',
                        border: OutlineInputBorder(),
                        suffixText: 'W',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => updateFromControllers(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: usageController,
                      decoration: InputDecoration(
                        labelText: 'Usage (Hours per day)',
                        border: OutlineInputBorder(),
                        suffixText: 'hrs',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => updateFromControllers(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: daysController,
                      decoration: InputDecoration(
                        labelText: 'Number of Days',
                        border: OutlineInputBorder(),
                        suffixText: 'days',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => updateFromControllers(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: costController,
                      decoration: InputDecoration(
                        labelText: 'Cost per Unit (kWh)',
                        border: OutlineInputBorder(),
                        suffixText: '₹/kWh',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => updateFromControllers(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Sliders
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text('Adjust Usage Hours: ${usageHours.toStringAsFixed(1)} hrs', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: usageHours,
                      min: 0,
                      max: 24,
                      divisions: 24,
                      label: usageHours.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          usageHours = value;
                          usageController.text = usageHours.toString();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Text('Adjust Days: ${numberOfDays.toStringAsFixed(0)} days',
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: numberOfDays,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: numberOfDays.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          numberOfDays = value;
                          daysController.text = numberOfDays.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Dynamic Energy Meter
            Card(
              color: getUsageColor().withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('ENERGY METER', 
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: getUsageColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        getUsageLevel(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Energy Used:', style: TextStyle(fontSize: 16)),
                        Text('${calculateEnergyUsed().toStringAsFixed(2)} kWh',
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Bill:', style: TextStyle(fontSize: 16)),
                        Text('₹${calculateMonthlyBill().toStringAsFixed(2)}',
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Yearly Projection:', style: TextStyle(fontSize: 16)),
                        Text('₹${calculateYearlyProjection().toStringAsFixed(2)}',
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Counter
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculation Counter:', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              counter--;
                            });
                          },
                        ),
                        Text('$counter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              counter++;
                            });
                          },
                        ),
                      ],
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
