import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      home: const DeliveryApp(),
    );
  }
}

class DeliveryApp extends StatefulWidget {
  const DeliveryApp({super.key});

  @override
  State<DeliveryApp> createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  int statusIndex = 0;
  List<String> statusList = ["Order Placed", "Preparing", "Out for Delivery", "Delivered"];
  
  List<Map<String, dynamic>> menu = [
    {"name": "Pizza", "price": 250},
    {"name": "Burger", "price": 120},
    {"name": "Biryani", "price": 200},
    {"name": "Pasta", "price": 180},
  ];
  
  Map<String, dynamic>? selectedItem;
  int eta = 30;
  double zoom = 1.0;

  void updateETA() {
    if (statusIndex == 0) eta = 30;
    else if (statusIndex == 1) eta = 20;
    else if (statusIndex == 2) eta = 10;
    else eta = 0;
    setState(() {});
  }

  void nextStatus() {
    if (statusIndex < 3) {
      statusIndex++;
      updateETA();
    }
  }

  void prevStatus() {
    if (statusIndex > 0) {
      statusIndex--;
      updateETA();
    }
  }

  void zoomIn() {
    setState(() {
      zoom = (zoom + 0.2).clamp(1.0, 3.0);
    });
  }

  void zoomOut() {
    setState(() {
      zoom = (zoom - 0.2).clamp(1.0, 3.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Food Menu"), backgroundColor: Colors.orange),
        body: ListView.builder(
          itemCount: menu.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(menu[index]["name"]),
                subtitle: Text("Rs. ${menu[index]["price"]}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = menu[index];
                      statusIndex = 0;
                      updateETA();
                    });
                  },
                  child: const Text("Order"),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedItem!["name"]} Order"),
        backgroundColor: Colors.orange,
      ),
      body: GestureDetector(
        onDoubleTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Reordering ${selectedItem!["name"]}")),
          );
          statusIndex = 0;
          updateETA();
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Cancel Order?"),
              content: Text("Cancel ${selectedItem!["name"]}?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order Cancelled")),
                    );
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          );
        },
        child: ListView(
          children: [
            // Swipe Status Bar
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) nextStatus();
                else if (details.primaryVelocity! < 0) prevStatus();
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("Swipe Left/Right to Update Status"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < statusList.length; i++)
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusIndex >= i ? Colors.orange : Colors.grey,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${i + 1}",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  statusList[i],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: statusIndex == i ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (statusIndex + 1) / 4,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            
            // ETA Display
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Estimated Time of Arrival", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      "$eta minutes",
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    if (statusIndex == 3) const Text("Order Delivered!"),
                  ],
                ),
              ),
            ),
            
            // Pinch to Zoom Location (Now with Mouse support)
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Transform.scale(
                      scale: zoom,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 50, color: Colors.red),
                            Text("Delivery Location", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Zoom buttons for mouse users
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.zoom_out),
                        onPressed: zoomOut,
                        tooltip: "Zoom Out (or Ctrl + Scroll)",
                      ),
                      Text("Zoom: ${zoom.toStringAsFixed(1)}x"),
                      IconButton(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: zoomIn,
                        tooltip: "Zoom In (or Ctrl + Scroll)",
                      ),
                    ],
                  ),
                  const Text("💡 Tip: Press Ctrl + Scroll to Zoom", style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
            
            // Gesture Instructions
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text("GESTURE CONTROLS", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("👆 Swipe Left/Right - Update Status"),
                  Text("👆 Double Tap - Reorder Favorite"),
                  Text("👆 Long Press - Cancel Order"),
                  Text("🖱️ Click +/- Buttons or Ctrl+Scroll - Zoom Location"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
