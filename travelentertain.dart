import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel & Entertainment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MovieRatingPage(),
    TravelCostPage(),
    SwipePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Travel'),
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: 'Discover'),
        ],
      ),
    );
  }
}

class Movie {
  final String title;
  final String genre;
  final String imageUrl;
  double rating;

  Movie({required this.title, required this.genre, required this.imageUrl, this.rating = 0});
}

class MovieRatingPage extends StatefulWidget {
  const MovieRatingPage({super.key});

  @override
  State<MovieRatingPage> createState() => _MovieRatingPageState();
}

class _MovieRatingPageState extends State<MovieRatingPage> {
  final List<Movie> movies = [
    Movie(title: 'Inception', genre: 'Sci-Fi', imageUrl: 'https://picsum.photos/seed/inception/200/300'),
    Movie(title: 'The Dark Knight', genre: 'Action', imageUrl: 'https://picsum.photos/seed/batman/200/300'),
    Movie(title: 'Interstellar', genre: 'Sci-Fi', imageUrl: 'https://picsum.photos/seed/space/200/300'),
    Movie(title: 'Parasite', genre: 'Thriller', imageUrl: 'https://picsum.photos/seed/parasite/200/300'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Ratings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.imageUrl,
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(movie.genre, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return GestureDetector(
                              onTap: () => setState(() => movie.rating = starIndex + 1.0),
                              child: Icon(
                                starIndex < movie.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 28,
                              ),
                            );
                          }),
                        ),
                        Text(
                          movie.rating > 0 ? 'Your rating: ${movie.rating.toInt()}/5' : 'Tap to rate',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TravelCostPage extends StatefulWidget {
  const TravelCostPage({super.key});

  @override
  State<TravelCostPage> createState() => _TravelCostPageState();
}

class _TravelCostPageState extends State<TravelCostPage> {
  final _distanceController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _hotelController = TextEditingController();
  final _daysController = TextEditingController();

  String _selectedTransport = 'Car';
  double _totalCost = 0;

  final Map<String, double> _fuelEfficiency = {
    'Car': 12.0,
    'Bike': 40.0,
    'Bus': 5.0,
    'Flight': 0.0,
  };

  void _calculate() {
    final distance = double.tryParse(_distanceController.text) ?? 0;
    final fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0;
    final hotelPerNight = double.tryParse(_hotelController.text) ?? 0;
    final days = double.tryParse(_daysController.text) ?? 0;

    double transportCost = 0;
    if (_selectedTransport == 'Flight') {
      transportCost = distance * 5.0;
    } else {
      final efficiency = _fuelEfficiency[_selectedTransport]!;
      transportCost = (distance / efficiency) * fuelPrice;
    }

    setState(() => _totalCost = transportCost + (hotelPerNight * days));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Cost Calculator'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Transport Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _fuelEfficiency.keys.map((mode) {
                return ChoiceChip(
                  label: Text(mode),
                  selected: _selectedTransport == mode,
                  onSelected: (_) => setState(() => _selectedTransport = mode),
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: _selectedTransport == mode ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildField(_distanceController, 'Distance (km)', Icons.route),
            const SizedBox(height: 12),
            if (_selectedTransport != 'Flight') ...[
              _buildField(_fuelPriceController, 'Fuel Price per Liter (₹)', Icons.local_gas_station),
              const SizedBox(height: 12),
            ],
            _buildField(_hotelController, 'Hotel Cost per Night (₹)', Icons.hotel),
            const SizedBox(height: 12),
            _buildField(_daysController, 'Number of Days', Icons.calendar_today),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Total Cost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_totalCost > 0) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.teal[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Estimated Total Cost',
                          style: TextStyle(fontSize: 16, color: Colors.teal)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final List<Map<String, String>> _items = [
    {'title': 'Paris', 'subtitle': 'City of Light', 'emoji': '🗼'},
    {'title': 'Bali', 'subtitle': 'Island Paradise', 'emoji': '🌴'},
    {'title': 'New York', 'subtitle': 'The Big Apple', 'emoji': '🗽'},
    {'title': 'Tokyo', 'subtitle': 'Land of Rising Sun', 'emoji': '⛩️'},
    {'title': 'Maldives', 'subtitle': 'Crystal Waters', 'emoji': '🏝️'},
  ];

  int _currentIndex = 0;
  final List<String> _liked = [];
  final List<String> _disliked = [];

  void _swipe(bool liked) {
    if (_currentIndex >= _items.length) return;
    final name = _items[_currentIndex]['title']!;
    setState(() {
      if (liked) {
        _liked.add(name);
      } else {
        _disliked.add(name);
      }
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Destinations'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _currentIndex < _items.length
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_items.length - _currentIndex} left',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                Dismissible(
                  key: Key(_items[_currentIndex]['title']!),
                  onDismissed: (direction) {
                    _swipe(direction == DismissDirection.startToEnd);
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 32),
                    child: const Icon(Icons.favorite, color: Colors.green, size: 40),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 32),
                    child: const Icon(Icons.close, color: Colors.red, size: 40),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_items[_currentIndex]['emoji']!,
                              style: const TextStyle(fontSize: 80)),
                          const SizedBox(height: 16),
                          Text(
                            _items[_currentIndex]['title']!,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _items[_currentIndex]['subtitle']!,
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          const Text('← Swipe to decide →',
                              style: TextStyle(color: Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'dislike',
                      onPressed: () => _swipe(false),
                      backgroundColor: Colors.red[100],
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                    const SizedBox(width: 40),
                    FloatingActionButton(
                      heroTag: 'like',
                      onPressed: () => _swipe(true),
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.favorite, color: Colors.green),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    const Text('All done!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_liked.isNotEmpty)
                      Text('Liked: ${_liked.join(', ')}',
                          style: const TextStyle(color: Colors.green)),
                    if (_disliked.isNotEmpty)
                      Text('Skipped: ${_disliked.join(', ')}',
                          style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _currentIndex = 0;
                        _liked.clear();
                        _disliked.clear();
                      }),
                      child: const Text('Start Over'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
