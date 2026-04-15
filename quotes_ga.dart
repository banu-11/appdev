// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// add http: 0.13.6 in dependencies

// void main() {
//   runApp(QuoteApp());
// }
//
// class QuoteApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: QuoteHome(),
//     );
//   }
// }
//
// class QuoteHome extends StatefulWidget {
//   @override
//   _QuoteHomeState createState() => _QuoteHomeState();
// }
//
// class _QuoteHomeState extends State<QuoteHome> {
//   String selectedMood = "Happy";
//   String quote = "Loading...";
//   String author = "";
//   bool isLoading = false;
//
//   final moods = {
//     "Happy": "😊",
//     "Sad": "😢",
//     "Motivated": "🔥",
//     "Calm": "😌",
//     "Angry": "😡",
//   };
//
//   /// FALLBACK QUOTES
//   final fallbackQuotes = {
//     "Happy": [
//       {"q": "Happiness is a choice.", "a": "Unknown"},
//       {"q": "Smile, it's a beautiful day!", "a": "Unknown"},
//     ],
//     "Sad": [
//       {"q": "Tough times never last.", "a": "Robert Schuller"},
//       {"q": "Every storm runs out of rain.", "a": "Maya Angelou"},
//     ],
//     "Motivated": [
//       {"q": "Push yourself, because no one else will.", "a": "Unknown"},
//       {"q": "Success starts with self-discipline.", "a": "Unknown"},
//     ],
//     "Calm": [
//       {"q": "Peace begins with a deep breath.", "a": "Unknown"},
//       {"q": "Stay calm, everything will pass.", "a": "Unknown"},
//     ],
//     "Angry": [
//       {"q": "For every minute of anger, you lose happiness.", "a": "Emerson"},
//       {"q": "Control your anger before it controls you.", "a": "Unknown"},
//     ],
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     fetchQuote();
//   }
//
//   /// COLOR BASED ON MOOD
//   Color getColor(String mood) {
//     switch (mood) {
//       case "Happy":
//         return Colors.yellow.shade300;
//       case "Sad":
//         return Colors.blue.shade300;
//       case "Motivated":
//         return Colors.orange.shade300;
//       case "Calm":
//         return Colors.green.shade300;
//       case "Angry":
//         return Colors.red.shade300;
//       default:
//         return Colors.white;
//     }
//   }
//
//   /// USE FALLBACK
//   void useFallback() {
//     final list = fallbackQuotes[selectedMood]!;
//     final random = list[Random().nextInt(list.length)];
//
//     setState(() {
//       quote = random['q']!;
//       author = random['a']!;
//       isLoading = false;
//     });
//   }
//
//   /// FETCH FROM API
//   Future<void> fetchQuote() async {
//     setState(() => isLoading = true);
//
//     try {
//       final response =
//       await http.get(Uri.parse("https://zenquotes.io/api/random"));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         setState(() {
//           quote = data[0]['q'];
//           author = data[0]['a'];
//           isLoading = false;
//         });
//       } else {
//         useFallback();
//       }
//     } catch (e) {
//       useFallback();
//     }
//   }
//
//   /// MOOD SELECT
//   void selectMood(String mood) {
//     setState(() {
//       selectedMood = mood;
//     });
//     fetchQuote();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: getColor(selectedMood),
//       appBar: AppBar(
//         title: Text("Mood Quotes"),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// MOOD SELECTOR
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: moods.entries.map((entry) {
//                 return GestureDetector(
//                   onTap: () => selectMood(entry.key),
//                   child: Column(
//                     children: [
//                       Text(entry.value, style: TextStyle(fontSize: 32)),
//                       SizedBox(height: 5),
//                       Text(entry.key),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//
//             SizedBox(height: 40),
//
//             /// QUOTE DISPLAY (FIXED)
//             Expanded(
//               child: Center(
//                 child: isLoading
//                     ? CircularProgressIndicator()
//                     : Card(
//                   elevation: 6,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "\"$quote\"",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           "- $author",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             /// BUTTON
//             ElevatedButton.icon(
//               onPressed: fetchQuote,
//               icon: Icon(Icons.refresh),
//               label: Text("New Quote"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
