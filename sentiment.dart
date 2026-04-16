import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Sentiment Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SentimentAnalysisScreen(),
    );
  }
}

class SentimentAnalysisScreen extends StatefulWidget {
  const SentimentAnalysisScreen({super.key});

  @override
  State<SentimentAnalysisScreen> createState() => _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  
  String? _analysisResult;
  String? _analyzedMovie;
  bool _isAnalyzing = false;

  // Predefined positive words
  final List<String> _positiveWords = [
    'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic', 
    'awesome', 'brilliant', 'perfect', 'love', 'like', 'best', 'nice',
    'beautiful', 'outstanding', 'superb', 'incredible', 'enjoyed',
    'masterpiece', 'favorite', 'recommend', 'worth', 'impressive'
  ];
  
  // Predefined negative words
  final List<String> _negativeWords = [
    'bad', 'terrible', 'awful', 'horrible', 'worst', 'poor', 
    'disappointing', 'boring', 'hate', 'waste', 'useless', 'pathetic',
    'ridiculous', 'annoying', 'wasted', 'regret', 'skip', 'avoid',
    'mediocre', 'uninteresting', 'dull', 'unwatchable'
  ];

  // Predefined movie reviews database (movie name -> list of sentiments)
  final Map<String, List<String>> _movieReviews = {
    'inception': ['mind-blowing', 'brilliant', 'confusing but good'],
    'titanic': ['romantic', 'emotional', 'sad but beautiful'],
    'avatar': ['visual masterpiece', 'amazing graphics', 'predictable story'],
    'joker': ['dark masterpiece', 'disturbing', 'brilliant acting'],
    'interstellar': ['scientific masterpiece', 'emotional', 'complex'],
  };

  void _analyzeSentiment() {
    String movieName = _movieNameController.text.trim();
    String review = _reviewController.text.trim();
    
    if (movieName.isEmpty) {
      _showSnackBar('Please enter a movie name');
      return;
    }
    
    if (review.isEmpty) {
      _showSnackBar('Please enter a review');
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
    });
    
    // Simulate processing time
    Future.delayed(const Duration(milliseconds: 500), () {
      String result = _calculateSentiment(review, movieName);
      
      setState(() {
        _analysisResult = result;
        _analyzedMovie = movieName;
        _isAnalyzing = false;
      });
      
      _showSnackBar('Analysis complete!');
    });
  }
  
  String _calculateSentiment(String review, String movieName) {
    String lowerReview = review.toLowerCase();
    int positiveScore = 0;
    int negativeScore = 0;
    
    // Check for positive words
    for (String word in _positiveWords) {
      if (lowerReview.contains(word)) {
        positiveScore++;
      }
    }
    
    // Check for negative words
    for (String word in _negativeWords) {
      if (lowerReview.contains(word)) {
        negativeScore++;
      }
    }
    
    // Check for intensity words
    if (lowerReview.contains('very') || lowerReview.contains('extremely')) {
      if (positiveScore > 0) positiveScore += 2;
      if (negativeScore > 0) negativeScore += 2;
    }
    
    // Check for predefined movie reviews
    String lowerMovie = movieName.toLowerCase();
    if (_movieReviews.containsKey(lowerMovie)) {
      for (String predefinedReview in _movieReviews[lowerMovie]!) {
        if (lowerReview.contains(predefinedReview.toLowerCase())) {
          if (_positiveWords.any((w) => predefinedReview.contains(w))) {
            positiveScore += 2;
          } else if (_negativeWords.any((w) => predefinedReview.contains(w))) {
            negativeScore += 2;
          }
        }
      }
    }
    
    // Calculate final sentiment
    if (positiveScore > negativeScore) {
      double confidence = (positiveScore / (positiveScore + negativeScore + 0.1)) * 100;
      return 'POSITIVE 😊\nConfidence: ${confidence.toStringAsFixed(1)}%';
    } else if (negativeScore > positiveScore) {
      double confidence = (negativeScore / (positiveScore + negativeScore + 0.1)) * 100;
      return 'NEGATIVE 😞\nConfidence: ${confidence.toStringAsFixed(1)}%';
    } else {
      return 'NEUTRAL 😐\nConfidence: 50.0%';
    }
  }
  
  void _clearFields() {
    _movieNameController.clear();
    _reviewController.clear();
    setState(() {
      _analysisResult = null;
      _analyzedMovie = null;
    });
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Widget _buildSentimentCard() {
    if (_analysisResult == null) return const SizedBox.shrink();
    
    bool isPositive = _analysisResult!.contains('POSITIVE');
    bool isNegative = _analysisResult!.contains('NEGATIVE');
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [Colors.green.shade400, Colors.green.shade700]
                : isNegative
                ? [Colors.red.shade400, Colors.red.shade700]
                : [Colors.orange.shade400, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'Movie: $_analyzedMovie',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _analysisResult!.split('\n')[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _analysisResult!.split('\n')[1],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Sentiment Analyzer'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Name Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _movieNameController,
                decoration: InputDecoration(
                  labelText: 'Movie Name',
                  hintText: 'e.g., Inception, Titanic',
                  prefixIcon: const Icon(Icons.movie),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Review Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Type your movie review here...\n\nExample: "This movie was absolutely amazing! I loved every moment of it."',
                  prefixIcon: const Icon(Icons.comment), // FIXED: Changed from Icons.review to Icons.comment
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeSentiment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics),
                              SizedBox(width: 8),
                              Text('Analyze Sentiment'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFields,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.blue.shade700),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text('Clear'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Result Card
            if (_analysisResult != null) ...[
              const SizedBox(height: 8),
              _buildSentimentCard(),
            ],
            
            const SizedBox(height: 24),
            
            // Quick Examples Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Quick Examples',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleTile('Positive', 'This movie was absolutely amazing! I loved it.'),
                  _buildExampleTile('Negative', 'What a waste of time! Terrible acting and boring story.'),
                  _buildExampleTile('Neutral', 'It was an okay movie, nothing special.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExampleTile(String sentiment, String review) {
    Color color = sentiment == 'Positive' ? Colors.green : 
                  sentiment == 'Negative' ? Colors.red : Colors.orange;
    
    return GestureDetector(
      onTap: () {
        _reviewController.text = review;
        _showSnackBar('Example review loaded!');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                sentiment,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                review,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
