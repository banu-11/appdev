import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ElectionNewsScreen(),
    );
  }
}

class ElectionNewsScreen extends StatefulWidget {
  @override
  _ElectionNewsScreenState createState() => _ElectionNewsScreenState();
}

class _ElectionNewsScreenState extends State<ElectionNewsScreen> {
  bool subscribed = false;
  String selectedConstituency = "Chennai";
  String filter = "All";

  Map<String, List<Map<String, dynamic>>> newsCache = {
    "Chennai": [],
    "Delhi": [],
    "Mumbai": []
  };

  final List<String> constituencies = ["Chennai", "Delhi", "Mumbai"];

  Timer? timer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startNewsStream();
  }

  void startNewsStream() {
    timer = Timer.periodic(Duration(seconds: 4), (t) {
      if (!subscribed) return;

      List<String> headlines = [
        "Candidate rally gains momentum",
        "New development project announced",
        "Voting awareness campaign started",
        "Opposition raises concerns",
        "Major speech attracts crowd"
      ];

      bool important = random.nextBool();

      Map<String, dynamic> newsItem = {
        "title": headlines[random.nextInt(headlines.length)],
        "time": DateTime.now().toString().substring(11, 19),
        "important": important
      };

      setState(() {
        newsCache[selectedConstituency]!.insert(0, newsItem);
      });

      // 🔔 Notification effect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New update in $selectedConstituency"),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  List<Map<String, dynamic>> get filteredNews {
    List<Map<String, dynamic>> list =
    newsCache[selectedConstituency]!;

    if (filter == "Important") {
      return list.where((e) => e["important"]).toList();
    }
    return list;
  }

  void manualRefresh() {
    setState(() {
      newsCache[selectedConstituency]!.insert(0, {
        "title": "Manual refresh update",
        "time": DateTime.now().toString().substring(11, 19),
        "important": true
      });
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
      appBar: AppBar(
        title: Text("Election News System"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: manualRefresh,
          )
        ],
      ),
      body: Column(
        children: [
          // 🔽 Constituency Dropdown
          DropdownButton(
            value: selectedConstituency,
            items: constituencies
                .map((c) =>
                DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedConstituency = val.toString();
              });
            },
          ),

          // 🔔 Subscribe Toggle
          SwitchListTile(
            title: Text("Subscribe to Updates"),
            value: subscribed,
            onChanged: (val) {
              setState(() {
                subscribed = val;
              });
            },
          ),

          // 🎯 Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text("All"),
                selected: filter == "All",
                onSelected: (_) => setState(() => filter = "All"),
              ),
              SizedBox(width: 10),
              ChoiceChip(
                label: Text("Important"),
                selected: filter == "Important",
                onSelected: (_) =>
                    setState(() => filter = "Important"),
              ),
            ],
          ),

          Divider(),

          // 📰 News List
          Expanded(
            child: filteredNews.isEmpty
                ? Center(child: Text("No updates yet"))
                : ListView.builder(
              itemCount: filteredNews.length,
              itemBuilder: (context, index) {
                var item = filteredNews[index];

                return Card(
                  color: item["important"]
                      ? Colors.red.shade100
                      : Colors.white,
                  child: ListTile(
                    title: Text(item["title"]),
                    subtitle: Text("Time: ${item["time"]}"),
                    trailing: item["important"]
                        ? Icon(Icons.priority_high,
                        color: Colors.red)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
