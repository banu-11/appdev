import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MoviePage(),
    );
  }
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  int currentIndex = 0;
  int userRating = 0;

  // Movie data
  List<Map<String, dynamic>> movies = [
    {
      "name": "Avengers",
      "genre": "Action",
      "rating": 4.0,
      "totalRatings": 100,
      "peopleCount": 25,
      "image": "assets/images/avengers.jpg"
    },
    {
      "name": "Titanic",
      "genre": "Romance",
      "rating": 4.5,
      "totalRatings": 135,
      "peopleCount": 30,
      "image": "assets/images/titanic.jpg"
    },
    {
      "name": "Joker",
      "genre": "Drama",
      "rating": 4.2,
      "totalRatings": 126,
      "peopleCount": 30,
      "image": "assets/images/joker.jpg"
    }
  ];

  // 🎨 Background color based on rating (UPDATED to match requirements)
  // ✅ Rating >= 4 → Green
  // ✅ Rating = 3 → Orange  
  // ✅ Rating < 3 → Red
  Color getBgColor() {
    if (userRating >= 4) {
      return Colors.green;      // 4 or 5 stars = Green
    } else if (userRating == 3) {
      return Colors.orange;     // 3 stars = Orange
    } else if (userRating >= 1 && userRating <= 2) {
      return Colors.red;        // 1 or 2 stars = Red
    } else {
      return Colors.white;      // No rating yet
    }
  }

  // ⭐ Update average rating dynamically
  void updateRating(int newRating) {
    setState(() {
      userRating = newRating;
      
      // Get current movie data
      int currentTotalRatings = movies[currentIndex]["totalRatings"];
      int currentPeopleCount = movies[currentIndex]["peopleCount"];
      
      // Add new rating
      int newTotalRatings = currentTotalRatings + newRating;
      int newPeopleCount = currentPeopleCount + 1;
      
      // Calculate new average
      double newAvg = newTotalRatings / newPeopleCount;
      
      // Update movie data
      movies[currentIndex]["totalRatings"] = newTotalRatings;
      movies[currentIndex]["peopleCount"] = newPeopleCount;
      movies[currentIndex]["rating"] = newAvg;
    });
  }

  // 👉 Next movie
  void nextMovie() {
    setState(() {
      currentIndex = (currentIndex + 1) % movies.length;
      userRating = 0; // Reset user rating for new movie
    });
  }

  @override
  Widget build(BuildContext context) {
    var movie = movies[currentIndex];

    return Scaffold(
      backgroundColor: getBgColor(),
      appBar: AppBar(
        title: const Text("Movie Rating App"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          nextMovie();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Movie Poster
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.movie,
                    size: 100,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 20),

                // Movie Title
                Text(
                  movie["name"],
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 10),

                // Movie Genre
                Text(
                  "Genre: ${movie["genre"]}",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 10),

                // Average Rating Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 5),
                    Text(
                      "Average Rating: ${movie["rating"].toStringAsFixed(1)}/5",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 5),
                
                // Number of ratings
                Text(
                  "Based on ${movie["peopleCount"]} ratings",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // Your Rating Label
                const Text(
                  "Your Rating",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // ⭐ Stars for user rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        size: 40,
                        color: index < userRating
                            ? Colors.amber
                            : Colors.grey,
                      ),
                      onPressed: () {
                        updateRating(index + 1);
                      },
                    );
                  }),
                ),
                
                // Show user rating if rated
                if (userRating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Text(
                          "You rated: $userRating stars",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Show background color indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: getBgColor(),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _getBackgroundMessage(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Swipe instruction
                const Text(
                  "👉 Swipe left to see next movie",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to show background color meaning
  String _getBackgroundMessage() {
    if (userRating >= 4) {
      return "🎉 Great rating! Green background";
    } else if (userRating == 3) {
      return "👍 Good rating! Orange background";
    } else if (userRating >= 1 && userRating <= 2) {
      return "👎 Low rating! Red background";
    }
    return "";
  }
}
