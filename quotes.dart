import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Quote App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: QuotePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuotePage extends StatefulWidget {
  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  TextEditingController moodController = TextEditingController();
  
  String mood = "";
  String quote = "Enter your mood and tap 'Get Quote'";
  String author = "";
  bool isLoading = false;
  String errorMessage = "";

  // Fallback quotes in case API fails
  final Map<String, List<Map<String, String>>> fallbackQuotes = {
    "happy": [
      {"quote": "Happiness is not something ready made. It comes from your own actions.", "author": "Dalai Lama"},
      {"quote": "The happiness of your life depends upon the quality of your thoughts.", "author": "Marcus Aurelius"},
      {"quote": "Happiness is when what you think, what you say, and what you do are in harmony.", "author": "Mahatma Gandhi"},
    ],
    "sad": [
      {"quote": "The pain you feel today is the strength you feel tomorrow.", "author": "Unknown"},
      {"quote": "Every adversity carries with it the seed of an equal or greater benefit.", "author": "Napoleon Hill"},
      {"quote": "Tough times never last, but tough people do.", "author": "Robert H. Schuller"},
    ],
    "angry": [
      {"quote": "For every minute you remain angry, you give up sixty seconds of peace of mind.", "author": "Ralph Waldo Emerson"},
      {"quote": "Anger is an acid that can do more harm to the vessel in which it is stored than to anything on which it is poured.", "author": "Mark Twain"},
      {"quote": "Speak when you are angry and you will make the best speech you will ever regret.", "author": "Ambrose Bierce"},
    ],
    "motivated": [
      {"quote": "The only way to do great work is to love what you do.", "author": "Steve Jobs"},
      {"quote": "Don't watch the clock; do what it does. Keep going.", "author": "Sam Levenson"},
      {"quote": "The future depends on what you do today.", "author": "Mahatma Gandhi"},
    ],
    "calm": [
      {"quote": "Peace is not absence of conflict, it is the ability to handle conflict by peaceful means.", "author": "Ronald Reagan"},
      {"quote": "Calm mind brings inner strength and self-confidence.", "author": "Dalai Lama"},
      {"quote": "The nearer a man comes to a calm mind, the closer he is to strength.", "author": "Marcus Aurelius"},
    ],
    "lonely": [
      {"quote": "The greatest thing in the world is to know how to belong to oneself.", "author": "Michel de Montaigne"},
      {"quote": "Loneliness expresses the pain of being alone and solitude expresses the glory of being alone.", "author": "Paul Tillich"},
      {"quote": "The eternal quest of the human being is to shatter his loneliness.", "author": "Norman Cousins"},
    ],
    "love": [
      {"quote": "Where there is love, there is life.", "author": "Mahatma Gandhi"},
      {"quote": "Love all, trust a few, do wrong to none.", "author": "William Shakespeare"},
      {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn"},
    ],
  };

  // Map moods to quote categories/tags
  Map<String, String> moodTags = {
    "happy": "happiness",
    "sad": "hope",
    "angry": "anger",
    "motivated": "motivation",
    "calm": "calm",
    "lonely": "loneliness",
    "love": "love",
  };

  // List of alternative APIs to try
  final List<String> alternativeApis = [
    "https://api.quotable.io/random",
    "https://type.fit/api/quotes",
    "https://zenquotes.io/api/random",
    "https://api.adviceslip.com/advice",
  ];

  Future<void> getQuote() async {
    // Get the mood from text field and convert to lowercase
    String enteredMood = moodController.text.trim().toLowerCase();
    
    if (enteredMood.isEmpty) {
      setState(() {
        errorMessage = "Please enter a mood!";
        quote = "Enter your mood and tap 'Get Quote'";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
      mood = enteredMood;
      quote = "Fetching quote...";
    });

    // Try to fetch from API first
    bool apiSuccess = await tryFetchFromApis(enteredMood);
    
    // If API fails, use fallback quotes
    if (!apiSuccess) {
      useFallbackQuote(enteredMood);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> tryFetchFromApis(String enteredMood) async {
    // Try Quotable API first with mood tag
    if (moodTags.containsKey(enteredMood)) {
      String tag = moodTags[enteredMood]!;
      bool success = await fetchFromUrl("https://api.quotable.io/random?tags=$tag");
      if (success) return true;
    }

    // Try Quotable API without tag
    bool success = await fetchFromUrl("https://api.quotable.io/random");
    if (success) return true;

    // Try Type.fit API
    success = await fetchFromTypeFitApi();
    if (success) return true;

    // Try ZenQuotes API
    success = await fetchFromZenQuotes();
    if (success) return true;

    return false;
  }

  Future<bool> fetchFromUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['content'] != null && data['author'] != null) {
          setState(() {
            quote = data['content'];
            author = data['author'];
            errorMessage = "";
          });
          return true;
        }
      }
    } catch (e) {
      // Continue to next API
    }
    return false;
  }

  Future<bool> fetchFromTypeFitApi() async {
    try {
      final response = await http.get(
        Uri.parse("https://type.fit/api/quotes"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> quotes = json.decode(response.body);
        if (quotes.isNotEmpty) {
          var randomQuote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
          setState(() {
            quote = randomQuote['text'];
            author = randomQuote['author'] ?? 'Unknown';
            errorMessage = "";
          });
          return true;
        }
      }
    } catch (e) {
      // Continue
    }
    return false;
  }

  Future<bool> fetchFromZenQuotes() async {
    try {
      final response = await http.get(
        Uri.parse("https://zenquotes.io/api/random"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            quote = data[0]['q'];
            author = data[0]['a'];
            errorMessage = "";
          });
          return true;
        }
      }
    } catch (e) {
      // Continue
    }
    return false;
  }

  void useFallbackQuote(String enteredMood) {
    // Find matching mood or use general
    String matchedMood = "happy";
    if (fallbackQuotes.containsKey(enteredMood)) {
      matchedMood = enteredMood;
    } else {
      // Find closest match
      for (String key in fallbackQuotes.keys) {
        if (enteredMood.contains(key) || key.contains(enteredMood)) {
          matchedMood = key;
          break;
        }
      }
    }
    
    List<Map<String, String>> quotes = fallbackQuotes[matchedMood]!;
    var randomQuote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
    
    setState(() {
      quote = randomQuote['quote']!;
      author = randomQuote['author']!;
      errorMessage = "Using offline quotes (no internet connection)";
    });
  }

  Color getColor() {
    switch (mood.toLowerCase()) {
      case "happy":
        return Colors.amber.shade100;
      case "sad":
        return Colors.blue.shade100;
      case "angry":
        return Colors.red.shade100;
      case "motivated":
        return Colors.green.shade100;
      case "calm":
        return Colors.teal.shade100;
      case "lonely":
        return Colors.purple.shade100;
      case "love":
        return Colors.pink.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String getMoodEmoji() {
    switch (mood.toLowerCase()) {
      case "happy":
        return "😊";
      case "sad":
        return "😢";
      case "angry":
        return "😡";
      case "motivated":
        return "💪";
      case "calm":
        return "😌";
      case "lonely":
        return "🥺";
      case "love":
        return "❤️";
      default:
        return "📝";
    }
  }

  @override
  void dispose() {
    moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getColor(),
      appBar: AppBar(
        title: const Text("Mood Quote App"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mood input with emoji hint
            TextField(
              controller: moodController,
              decoration: InputDecoration(
                labelText: "Enter your mood",
                hintText: "e.g., happy, sad, motivated...",
                prefixIcon: const Icon(Icons.mood),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
              onSubmitted: (value) => getQuote(),
            ),

            const SizedBox(height: 20),

            // Get Quote Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : getQuote,
              icon: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.format_quote),
              label: Text(isLoading ? "Loading..." : "Get Quote"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Error/Success message
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: errorMessage.contains("offline") ? Colors.orange.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: errorMessage.contains("offline") ? Colors.orange.shade300 : Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      errorMessage.contains("offline") ? Icons.wifi_off : Icons.error_outline, 
                      color: errorMessage.contains("offline") ? Colors.orange.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: errorMessage.contains("offline") ? Colors.orange.shade700 : Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (errorMessage.isNotEmpty) const SizedBox(height: 20),

            // Quote Card
            if (quote.isNotEmpty && quote != "Enter your mood and tap 'Get Quote'")
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Mood emoji
                    Text(
                      getMoodEmoji(),
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quote text
                    Text(
                      '"$quote"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Author
                    if (author.isNotEmpty && author != "null")
                      Text(
                        '— $author',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Mood indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: getColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Feeling $mood",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else if (!isLoading && quote != "Fetching quote..." && quote != "Enter your mood and tap 'Get Quote'")
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mood, size: 50, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
