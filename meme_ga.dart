// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// add http: 0.13.6 in dependencies

// void main() {
//   runApp(MemeApp());
// }
//
// class MemeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Meme Generator',
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       home: MemeHome(),
//     );
//   }
// }
//
// class MemeHome extends StatefulWidget {
//   @override
//   _MemeHomeState createState() => _MemeHomeState();
// }
//
// class _MemeHomeState extends State<MemeHome> {
//   String imageUrl = "";
//   bool isLoading = false;
//
//   TextEditingController topController = TextEditingController();
//   TextEditingController bottomController = TextEditingController();
//
//   /// Fetch meme from API
//   Future<void> fetchMeme() async {
//     setState(() => isLoading = true);
//
//     final response =
//     await http.get(Uri.parse("https://meme-api.com/gimme"));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         imageUrl = data['url'];
//         isLoading = false;
//       });
//     } else {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMeme();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Meme Generator"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: fetchMeme,
//           )
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           children: [
//             /// Meme Display
//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : imageUrl.isEmpty
//                   ? Center(child: Text("No meme loaded"))
//                   : Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Image.network(imageUrl),
//                   Positioned(
//                     top: 10,
//                     child: Text(
//                       topController.text.toUpperCase(),
//                       style: memeTextStyle(),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 10,
//                     child: Text(
//                       bottomController.text.toUpperCase(),
//                       style: memeTextStyle(),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             /// Input fields
//             TextField(
//               controller: topController,
//               decoration: InputDecoration(labelText: "Top Text"),
//               onChanged: (_) => setState(() {}),
//             ),
//             TextField(
//               controller: bottomController,
//               decoration: InputDecoration(labelText: "Bottom Text"),
//               onChanged: (_) => setState(() {}),
//             ),
//
//             SizedBox(height: 10),
//
//             /// Generate Button
//             ElevatedButton(
//               onPressed: fetchMeme,
//               child: Text("Generate New Meme"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Meme text style
//   TextStyle memeTextStyle() {
//     return TextStyle(
//       fontSize: 26,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//       shadows: [
//         Shadow(blurRadius: 3, color: Colors.black, offset: Offset(2, 2)),
//       ],
//     );
//   }
// }

