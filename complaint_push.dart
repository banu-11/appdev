import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Notifications ─────────────────────────────────────────────────────────────
final _plugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _plugin.initialize(const InitializationSettings(android: android));
}

Future<void> pushNotification(String title, String body) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails('wms', 'Waste Management',
        importance: Importance.high, priority: Priority.high),
  );
  await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  AppState().notifications.insert(0, '[$title] $body');
}

// ── Models ────────────────────────────────────────────────────────────────────
enum Role { admin, supervisor, driver, resident }

class Schedule { String zone, date, time; Schedule(this.zone, this.date, this.time); }
class Complaint { String name, msg; bool resolved; DateTime at; Complaint(this.name, this.msg, this.at, {this.resolved = false}); }
class Drive { String title, type, date, zone; Drive(this.title, this.type, this.date, this.zone); }
class Payment { String name; double amount; bool paid; Payment(this.name, this.amount, {this.paid = false}); }
class DelayAlert { String zone, msg; DateTime at; DelayAlert(this.zone, this.msg, this.at); }

// ── Shared State ──────────────────────────────────────────────────────────────
class AppState {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._();

  final schedules = [
    Schedule('Zone A', 'Apr 16, 2026', '8:00 AM'),
    Schedule('Zone B', 'Apr 17, 2026', '9:00 AM'),
    Schedule('Zone C', 'Apr 18, 2026', '10:00 AM'),
  ];
  final complaints = <Complaint>[];
  final drives = [
    Drive('Plastic Collection Drive', 'Plastic', 'Apr 20, 2026', 'All Zones'),
    Drive('E-Waste Drive', 'E-Waste', 'Apr 25, 2026', 'Zone A'),
  ];
  final payments = [
    Payment('Alice (Zone A)', 150.0),
    Payment('Bob (Zone B)', 200.0, paid: true),
    Payment('Carol (Zone C)', 175.0),
  ];
  final delays = <DelayAlert>[];
  final notifications = <String>[];
}

// ── Main ──────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false));
}

// ── Login ─────────────────────────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext ctx, Role role) {
    Widget screen;
    switch (role) {
      case Role.admin:      screen = const AdminScreen(); break;
      case Role.supervisor: screen = const SupervisorScreen(); break;
      case Role.driver:     screen = const DriverScreen(); break;
      case Role.resident:   screen = const ResidentScreen(); break;
    }
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'role': Role.admin,      'label': 'Admin',      'icon': Icons.admin_panel_settings, 'color': Colors.purple},
      {'role': Role.supervisor, 'label': 'Supervisor', 'icon': Icons.manage_accounts,       'color': Colors.blue},
      {'role': Role.driver,     'label': 'Driver',     'icon': Icons.local_shipping,        'color': Colors.orange},
      {'role': Role.resident,   'label': 'Resident',   'icon': Icons.home,                  'color': Colors.green},
    ];
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.delete_outline, size: 64, color: Colors.green),
            const SizedBox(height: 8),
            const Text('Waste Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Select your role to continue', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ...roles.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _enter(context, r['role'] as Role),
                  icon: Icon(r['icon'] as IconData),
                  label: Text(r['label'] as String, style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: r['color'] as Color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )),
          ]),
        ),
      ),
    );
  }
}

// ── Admin ─────────────────────────────────────────────────────────────────────
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final s = AppState();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(labelColor: Colors.white, indicatorColor: Colors.white, tabs: [
            Tab(icon: Icon(Icons.bar_chart), text: 'Overview'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ]),
        ),
        body: TabBarView(children: [
          // Overview
          ListView(padding: const EdgeInsets.all(16), children: [
            _stat('Schedules', s.schedules.length, Icons.calendar_today, Colors.blue),
            _stat('Special Drives', s.drives.length, Icons.recycling, Colors.orange),
            _stat('Payments Pending', s.payments.where((p) => !p.paid).length, Icons.payment, Colors.red),
            _stat('Open Complaints', s.complaints.where((c) => !c.resolved).length, Icons.report, Colors.deepOrange),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await pushNotification('Admin Broadcast', 'Reminder: Follow waste segregation rules.');
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent!')));
              },
              icon: const Icon(Icons.campaign),
              label: const Text('Send Broadcast'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            ),
          ]),
          // Notifications
          s.notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: s.notifications.length,
                  itemBuilder: (_, i) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.purple),
                      title: Text(s.notifications[i], style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
        ]),
      ),
    );
  }

  Widget _stat(String label, int val, IconData icon, Color color) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(label),
      trailing: Text('$val', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    ),
  );
}

// ── Supervisor ────────────────────────────────────────────────────────────────
class SupervisorScreen extends StatefulWidget {
  const SupervisorScreen({super.key});
  @override
  State<SupervisorScreen> createState() => _SupervisorScreenState();
}

class _SupervisorScreenState extends State<SupervisorScreen> {
  final s = AppState();
  final zones = ['Zone A', 'Zone B', 'Zone C'];
  String zone = 'Zone A', date = 'Apr 19, 2026', time = '8:00 AM';
  String driveTitle = '', driveType = 'Plastic', driveZone = 'Zone A', driveDate = 'Apr 22, 2026';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supervisor Panel'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          bottom: const TabBar(labelColor: Colors.white, indicatorColor: Colors.white, tabs: [
            Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
            Tab(icon: Icon(Icons.recycling), text: 'Special Drives'),
          ]),
        ),
        body: TabBarView(children: [
          // Schedule tab
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Assign Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: zone,
              decoration: const InputDecoration(labelText: 'Zone', border: OutlineInputBorder()),
              items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (v) => setState(() => zone = v!),
            ),
            const SizedBox(height: 10),
            TextFormField(initialValue: date, decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()), onChanged: (v) => date = v),
            const SizedBox(height: 10),
            TextFormField(initialValue: time, decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder()), onChanged: (v) => time = v),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () async {
                s.schedules.add(Schedule(zone, date, time));
                await pushNotification('Pickup Scheduled', '$zone: $date at $time');
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$zone residents notified!')));
              },
              icon: const Icon(Icons.send),
              label: const Text('Assign & Notify'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Schedules', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...s.schedules.map((sc) => Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: Text(sc.zone),
                subtitle: Text('${sc.date} at ${sc.time}'),
              ),
            )),
          ]),
          // Drives tab
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Announce Special Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()), onChanged: (v) => driveTitle = v),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: driveType,
              decoration: const InputDecoration(labelText: 'Waste Type', border: OutlineInputBorder()),
              items: ['Biodegradable', 'Plastic', 'E-Waste'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => driveType = v!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: driveZone,
              decoration: const InputDecoration(labelText: 'Zone', border: OutlineInputBorder()),
              items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (v) => setState(() => driveZone = v!),
            ),
            const SizedBox(height: 10),
            TextFormField(initialValue: driveDate, decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()), onChanged: (v) => driveDate = v),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () async {
                final t = driveTitle.isEmpty ? '$driveType Drive' : driveTitle;
                s.drives.add(Drive(t, driveType, driveDate, driveZone));
                await pushNotification('Special Drive: $driveType', '$t on $driveDate at $driveZone');
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Drive announced!')));
              },
              icon: const Icon(Icons.campaign),
              label: const Text('Announce & Notify'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Upcoming Drives', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...s.drives.map((d) => Card(
              child: ListTile(
                leading: Icon(_driveIcon(d.type), color: _driveColor(d.type)),
                title: Text(d.title),
                subtitle: Text('${d.type} \u2022 ${d.date} \u2022 ${d.zone}'),
              ),
            )),
          ]),
        ]),
      ),
    );
  }

  IconData _driveIcon(String t) => t == 'E-Waste' ? Icons.electrical_services : t == 'Plastic' ? Icons.local_drink : Icons.eco;
  Color _driveColor(String t) => t == 'E-Waste' ? Colors.purple : t == 'Plastic' ? Colors.blue : Colors.green;
}

// ── Driver ────────────────────────────────────────────────────────────────────
class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final s = AppState();
  final zones = ['Zone A', 'Zone B', 'Zone C'];
  String zone = 'Zone A';
  final msgCtrl = TextEditingController();

  @override
  void dispose() { msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Panel'), backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Today\'s Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...s.schedules.map((sc) => Card(
          color: Colors.orange[50],
          child: ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.orange),
            title: Text(sc.zone),
            subtitle: Text('${sc.date} at ${sc.time}'),
          ),
        )),
        const SizedBox(height: 24),
        const Text('Send Delay Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: zone,
          decoration: const InputDecoration(labelText: 'Zone', border: OutlineInputBorder()),
          items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
          onChanged: (v) => setState(() => zone = v!),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: msgCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason for delay', border: OutlineInputBorder(), hintText: 'e.g. Heavy traffic...'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final msg = msgCtrl.text.trim().isEmpty ? 'Pickup delayed.' : msgCtrl.text.trim();
            s.delays.add(DelayAlert(zone, msg, DateTime.now()));
            await pushNotification('\u26A0 Delay - $zone', msg);
            msgCtrl.clear();
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert sent to $zone!')));
          },
          icon: const Icon(Icons.warning_amber),
          label: const Text('Send Delay Alert'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
        ),
        const SizedBox(height: 20),
        if (s.delays.isNotEmpty) ...[
          const Text('Sent Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...s.delays.reversed.map((a) => Card(
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(a.zone),
              subtitle: Text(a.msg),
              trailing: Text('${a.at.hour}:${a.at.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          )),
        ],
      ]),
    );
  }
}

// ── Resident ──────────────────────────────────────────────────────────────────
class ResidentScreen extends StatefulWidget {
  const ResidentScreen({super.key});
  @override
  State<ResidentScreen> createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  final s = AppState();
  final compCtrl = TextEditingController();

  @override
  void dispose() { compCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resident Portal'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
              Tab(icon: Icon(Icons.report_problem), text: 'Complaints'),
              Tab(icon: Icon(Icons.payment), text: 'Payments'),
              Tab(icon: Icon(Icons.recycling), text: 'Drives'),
            ],
          ),
        ),
        body: TabBarView(children: [
          // Schedule
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Pickup Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...s.schedules.map((sc) => Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: Text(sc.zone),
                subtitle: Text('${sc.date} at ${sc.time}'),
              ),
            )),
            const SizedBox(height: 16),
            if (s.delays.isNotEmpty) ...[
              const Text('Delay Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange)),
              const SizedBox(height: 8),
              ...s.delays.map((a) => Card(
                color: Colors.orange[50],
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(a.zone),
                  subtitle: Text(a.msg),
                ),
              )),
            ],
          ]),
          // Complaints
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Post a Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: compCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Describe your complaint', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                if (compCtrl.text.trim().isEmpty) return;
                s.complaints.add(Complaint('Resident', compCtrl.text.trim(), DateTime.now()));
                await pushNotification('New Complaint', compCtrl.text.trim());
                compCtrl.clear();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted!')));
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('My Complaints', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (s.complaints.isEmpty) const Text('No complaints yet.', style: TextStyle(color: Colors.grey)),
            ...s.complaints.reversed.map((c) => Card(
              child: ListTile(
                leading: Icon(c.resolved ? Icons.check_circle : Icons.pending, color: c.resolved ? Colors.green : Colors.orange),
                title: Text(c.msg),
                subtitle: Text(c.resolved ? 'Resolved' : 'Pending'),
              ),
            )),
          ]),
          // Payments
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Due Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...s.payments.map((p) => Card(
              child: ListTile(
                leading: Icon(p.paid ? Icons.check_circle : Icons.payment, color: p.paid ? Colors.green : Colors.red),
                title: Text(p.name),
                subtitle: Text(p.paid ? 'Paid' : 'Due: \u20B9${p.amount.toStringAsFixed(0)}'),
                trailing: p.paid
                    ? const Chip(label: Text('Paid'), backgroundColor: Color(0xFFc8e6c9))
                    : ElevatedButton(
                        onPressed: () async {
                          p.paid = true;
                          await pushNotification('Payment Received', '${p.name} paid \u20B9${p.amount.toStringAsFixed(0)}');
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                        child: const Text('Pay Now'),
                      ),
              ),
            )),
          ]),
          // Drives
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Special Drives', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...s.drives.map((d) => Card(
              child: ListTile(
                leading: Icon(
                  d.type == 'E-Waste' ? Icons.electrical_services : d.type == 'Plastic' ? Icons.local_drink : Icons.eco,
                  color: d.type == 'E-Waste' ? Colors.purple : d.type == 'Plastic' ? Colors.blue : Colors.green,
                  size: 32,
                ),
                title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${d.type} \u2022 ${d.date}\n${d.zone}'),
                isThreeLine: true,
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}
