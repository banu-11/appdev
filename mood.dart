import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: MoodApp(), debugShowCheckedModeBanner: false));

const moods = [
  {'label': 'Happy',   'emoji': '😊', 'color': Color(0xFFFFE066)},
  {'label': 'Sad',     'emoji': '😢', 'color': Color(0xFF90CAF9)},
  {'label': 'Angry',   'emoji': '😡', 'color': Color(0xFFEF9A9A)},
  {'label': 'Calm',    'emoji': '😌', 'color': Color(0xFF80DEEA)},
  {'label': 'Tired',   'emoji': '😴', 'color': Color(0xFFA5D6A7)},
  {'label': 'Excited', 'emoji': '🤩', 'color': Color(0xFFFFD700)},
];

class MoodApp extends StatefulWidget {
  const MoodApp({super.key});
  @override
  State<MoodApp> createState() => _MoodAppState();
}

class _MoodAppState extends State<MoodApp> {
  Map<String, dynamic> _current = moods[0];
  final List<Map<String, dynamic>> _log = [];

  void _pick(Map<String, dynamic> mood) {
    setState(() {
      _current = mood;
      _log.insert(0, {'mood': mood, 'time': TimeOfDay.now().format(context)});
    });
  }

  // most frequent mood this session
  String get _topMood {
    if (_log.isEmpty) return 'None';
    final counts = <String, int>{};
    for (final e in _log) counts[e['mood']['label']] = (counts[e['mood']['label']] ?? 0) + 1;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: _current['color'] as Color,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mood Tracker'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // current mood
            Text(_current['emoji'] as String, style: const TextStyle(fontSize: 80)),
            Text(_current['label'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Top mood: $_topMood', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 24),

            // mood buttons
            Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.center,
              children: moods.map((m) {
                final selected = m['label'] == _current['label'];
                return GestureDetector(
                  onTap: () => _pick(m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black26 : Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? Colors.black45 : Colors.transparent),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(m['emoji'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(m['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // log
            if (_log.isNotEmpty) ...[
              const Align(alignment: Alignment.centerLeft, child: Text('Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (_, i) {
                    final e = _log[i];
                    return ListTile(
                      leading: Text(e['mood']['emoji'] as String, style: const TextStyle(fontSize: 24)),
                      title: Text(e['mood']['label'] as String),
                      trailing: Text(e['time'] as String, style: const TextStyle(color: Colors.black45)),
                    );
                  },
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
