import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: const HomeScreen(), debugShowCheckedModeBanner: false, theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true)));

class Order {
  final String service, professional, date, time;
  final double price, rating;
  String status;
  Order(this.service, this.price, this.professional, this.rating, this.date, this.time) : status = 'Pending';
}

final services = [
  {'name': 'Plumbing', 'price': 50.0, 'pro': 'Alice', 'rating': 4.8},
  {'name': 'Electrical', 'price': 80.0, 'pro': 'Bob', 'rating': 4.5},
  {'name': 'Cleaning', 'price': 40.0, 'pro': 'Carol', 'rating': 4.9},
  {'name': 'AC Repair', 'price': 100.0, 'pro': 'David', 'rating': 4.7},
  {'name': 'Painting', 'price': 70.0, 'pro': 'Eva', 'rating': 4.6},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final List<Order> _orders = [];
  final Set<int> _sel = {};
  String? _date, _time;
  final _slots = ['9 AM', '11 AM', '1 PM', '3 PM', '5 PM'];

  double get _total => _sel.fold(0, (s, i) => s + (services[i]['price'] as double));

  void _book() async {
    if (_sel.isEmpty) return;
    _date = null; _time = null;
    await showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: const Text('Date & Time'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_date ?? 'Pick date'),
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
              if (d != null) set(() => _date = '${d.day}/${d.month}/${d.year}');
            },
          ),
          Wrap(spacing: 6, children: _slots.map((t) => ChoiceChip(label: Text(t), selected: _time == t, onSelected: (_) => set(() => _time = t))).toList()),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _date != null && _time != null ? () {
              setState(() {
                for (final i in _sel) {
                  final s = services[i];
                  _orders.add(Order(s['name'] as String, s['price'] as double, s['pro'] as String, s['rating'] as double, _date!, _time!));
                }
                _sel.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booked!')));
            } : null,
            child: const Text('Confirm'),
          ),
        ],
      ),
    ));
  }

  Widget _servicesTab() => Column(children: [
    Expanded(child: ListView.builder(itemCount: services.length, itemBuilder: (_, i) {
      final s = services[i];
      return CheckboxListTile(
        value: _sel.contains(i),
        onChanged: (v) => setState(() => v! ? _sel.add(i) : _sel.remove(i)),
        title: Text('${s['name']}  •  \$${s['price']}'),
        subtitle: Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(' ${s['rating']}  ${s['pro']}')]),
      );
    })),
    if (_sel.isNotEmpty) ColoredBox(color: Colors.teal, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total: \$${_total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ElevatedButton(onPressed: _book, child: const Text('Book')),
      ]),
    )),
  ]);

  Widget _billTab() {
    if (_orders.isEmpty) return const Center(child: Text('No orders yet.'));
    final total = _orders.fold(0.0, (s, o) => s + o.price);
    return Column(children: [
      Expanded(child: ListView(children: _orders.map((o) => ListTile(
        title: Text(o.service), subtitle: Text('${o.date}  ${o.time}'),
        trailing: Text('\$${o.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      )).toList())),
      ColoredBox(color: Colors.teal, child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16)),
          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      )),
    ]);
  }

  Color _sc(String s) => s == 'Pending' ? Colors.orange : s == 'Confirmed' ? Colors.blue : Colors.green;

  Widget _ordersTab() {
    if (_orders.isEmpty) return const Center(child: Text('No orders yet.'));
    return ListView.builder(itemCount: _orders.length, itemBuilder: (_, i) {
      final o = _orders[i];
      return Card(margin: const EdgeInsets.all(8), child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(o.service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Chip(label: Text(o.status), backgroundColor: _sc(o.status).withOpacity(0.2), side: BorderSide(color: _sc(o.status))),
          ]),
          Text('${o.professional}  ★${o.rating}  •  ${o.date} ${o.time}  •  \$${o.price.toStringAsFixed(0)}'),
          const SizedBox(height: 6),
          Row(children: ['Pending', 'Confirmed', 'Solved'].map((s) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: _sc(s), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () => setState(() => o.status = s),
              child: Text(s, style: const TextStyle(fontSize: 12)),
            ),
          )).toList()),
        ]),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Smart Home'), centerTitle: true),
    body: [_servicesTab(), _billTab(), _ordersTab()][_tab],
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_repair_service), label: 'Services'),
        NavigationDestination(icon: Icon(Icons.receipt), label: 'Bill'),
        NavigationDestination(icon: Icon(Icons.list_alt), label: 'Orders'),
      ],
    ),
  );
}
