import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electricity Bill Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BillCalculator(),
    );
  }
}

class BillCalculator extends StatefulWidget {
  const BillCalculator({super.key});

  @override
  State<BillCalculator> createState() => _BillCalculatorState();
}

class _BillCalculatorState extends State<BillCalculator> {
  // Appliances list
  final List<String> appliances = ['Fan', 'AC', 'Refrigerator', 'Washing Machine'];
  String selectedAppliance = 'Fan';

  // Appliance default values (power in watts, usage in hours/day)
  final Map<String, int> defaultPower = {
    'Fan': 75,
    'AC': 1500,
    'Refrigerator': 200,
    'Washing Machine': 500,
  };

  final Map<String, int> defaultUsage = {
    'Fan': 8,
    'AC': 5,
    'Refrigerator': 24,
    'Washing Machine': 1,
  };

  // Slider values
  double power = 75;        // watts
  double usage = 8;         // hours/day
  double days = 30;         // days
  double costPerUnit = 6;   // rupees per kWh

  // Counter for fun
  int counter = 0;

  // Calculate energy used (kWh)
  double get energyUsed {
    return (power / 1000) * usage * days;
  }

  // Calculate monthly bill
  double get monthlyBill {
    return energyUsed * costPerUnit;
  }

  // Calculate yearly projection
  double get yearlyProjection {
    return monthlyBill * 12;
  }

  // Get color based on energy usage
  Color getUsageColor() {
    if (energyUsed > 150) return Colors.red;
    if (energyUsed > 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity Bill Calculator'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dropdown for appliances
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  value: selectedAppliance,
                  decoration: const InputDecoration(labelText: 'Select Appliance'),
                  items: appliances.map((appliance) {
                    return DropdownMenuItem(
                      value: appliance,
                      child: Text(appliance),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAppliance = value!;
                      power = defaultPower[selectedAppliance]!.toDouble();
                      usage = defaultUsage[selectedAppliance]!.toDouble();
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Power Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text('Power (Watts): ${power.toStringAsFixed(0)} W'),
                    Slider(
                      value: power,
                      min: 10,
                      max: 2000,
                      divisions: 199,
                      onChanged: (val) => setState(() => power = val),
                    ),
                  ],
                ),
              ),
            ),

            // Usage Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text('Usage (Hours/Day): ${usage.toStringAsFixed(1)} hrs'),
                    Slider(
                      value: usage,
                      min: 0,
                      max: 24,
                      divisions: 24,
                      onChanged: (val) => setState(() => usage = val),
                    ),
                  ],
                ),
              ),
            ),

            // Days Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text('Number of Days: ${days.toStringAsFixed(0)} days'),
                    Slider(
                      value: days,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (val) => setState(() => days = val),
                    ),
                  ],
                ),
              ),
            ),

            // Cost Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text('Cost per Unit (₹/kWh): ${costPerUnit.toStringAsFixed(1)} ₹'),
                    Slider(
                      value: costPerUnit,
                      min: 1,
                      max: 15,
                      divisions: 14,
                      onChanged: (val) => setState(() => costPerUnit = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Energy Meter Display with dynamic color
            Card(
              color: getUsageColor().withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'ENERGY METER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: getUsageColor(),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.flash_on),
                      title: const Text('Energy Used'),
                      trailing: Text(
                        '${energyUsed.toStringAsFixed(2)} kWh',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text('Monthly Bill'),
                      trailing: Text(
                        '₹ ${monthlyBill.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Yearly Projection'),
                      trailing: Text(
                        '₹ ${yearlyProjection.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Usage Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getUsageColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: getUsageColor()),
                  const SizedBox(width: 8),
                  Text(
                    energyUsed > 150 ? '🔴 HIGH USAGE' : (energyUsed > 50 ? '🟠 MEDIUM USAGE' : '🟢 LOW USAGE'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getUsageColor(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Counter (as requested)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, size: 40),
                      onPressed: () => setState(() => counter--),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Text('COUNTER', style: TextStyle(fontSize: 12)),
                          Text(
                            '$counter',
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 40),
                      onPressed: () => setState(() => counter++),
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
