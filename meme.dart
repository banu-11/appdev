import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(home: MemeApp(), debugShowCheckedModeBanner: false));

class Meme {
  final String id, name, url;
  Meme(this.id, this.name, this.url);
  factory Meme.fromJson(Map j) => Meme(j['id'], j['name'], j['url']);
}

class MemeApp extends StatefulWidget {
  const MemeApp({super.key});
  @override
  State<MemeApp> createState() => _MemeAppState();
}

class _MemeAppState extends State<MemeApp> {
  List<Meme> _memes = [];
  Meme? _selected;
  String _top = '', _bottom = '', _generatedUrl = '', _error = '';
  bool _loading = false;
  final _topCtrl = TextEditingController();
  final _botCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMemes();
  }

  Future<void> _fetchMemes() async {
    setState(() => _loading = true);
    final res = await http.get(Uri.parse('https://api.imgflip.com/get_memes'));
    final data = jsonDecode(res.body);
    setState(() {
      _memes = (data['data']['memes'] as List).take(20).map((m) => Meme.fromJson(m)).toList();
      _loading = false;
    });
  }

  Future<void> _generate() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    final res = await http.post(
      Uri.parse('https://api.imgflip.com/caption_image'),
      body: {
        'template_id': _selected!.id,
        'username': 'imgflip_hubot',
        'password': 'imgflip_hubot',
        'text0': _top,
        'text1': _bottom,
      },
    );
    final data = jsonDecode(res.body);
    setState(() {
      if (data['success'] == true) {
        _generatedUrl = data['data']['url'];
        _error = '';
      } else {
        _generatedUrl = '';
        _error = data['error_message'] ?? 'Failed to generate meme';
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meme Generator'), centerTitle: true,
          backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Template picker
                const Align(alignment: Alignment.centerLeft, child: Text('Pick a Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _memes.length,
                    itemBuilder: (_, i) {
                      final m = _memes[i];
                      final picked = _selected?.id == m.id;
                      return GestureDetector(
                        onTap: () => setState(() { _selected = m; _generatedUrl = ''; }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: picked ? Colors.deepPurple : Colors.grey, width: picked ? 3 : 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(m.url, width: 90, height: 90, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selected != null) Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Selected: ${_selected!.name}', style: const TextStyle(color: Colors.deepPurple)),
                ),
                const SizedBox(height: 16),
                // Text inputs
                TextField(
                  controller: _topCtrl,
                  decoration: const InputDecoration(labelText: 'Top Text', border: OutlineInputBorder()),
                  onChanged: (v) => _top = v,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _botCtrl,
                  decoration: const InputDecoration(labelText: 'Bottom Text', border: OutlineInputBorder()),
                  onChanged: (v) => _bottom = v,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selected != null ? _generate : null,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Generate Meme'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(height: 20),
                // Error message
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error, style: const TextStyle(color: Colors.red)),
                  ),
                // Generated meme
                if (_generatedUrl.isNotEmpty) ...[
                  const Text('Your Meme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_generatedUrl, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(_generatedUrl, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ]),
            ),
    );
  }
}
