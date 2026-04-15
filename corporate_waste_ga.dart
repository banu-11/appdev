import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Role")),
      body: ListView(
        children: [
          roleTile(context, "Admin"),
          roleTile(context, "Supervisor"),
          roleTile(context, "Driver"),
          roleTile(context, "Resident"),
        ],
      ),
    );
  }

  Widget roleTile(BuildContext context, String role) {
    return ListTile(
      title: Text(role),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(role: role),
          ),
        );
      },
    );
  }
}

class Dashboard extends StatefulWidget {
  final String role;
  Dashboard({required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> notifications = [];

  void addNotification(String msg) {
    setState(() {
      notifications.add(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role} Dashboard"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (widget.role == "Supervisor")
                  SupervisorPanel(addNotification),
                if (widget.role == "Driver") DriverPanel(addNotification),
                if (widget.role == "Resident") ResidentPanel(addNotification),
                if (widget.role == "Admin") AdminPanel(addNotification),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(notifications[i]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SupervisorPanel extends StatelessWidget {
  final Function(String) notify;
  SupervisorPanel(this.notify);

  final TextEditingController areaController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Assign Pickup Schedule"),
        TextField(
            controller: areaController,
            decoration: InputDecoration(labelText: "Area")),
        TextField(
            controller: dateController,
            decoration: InputDecoration(labelText: "Date")),
        ElevatedButton(
          onPressed: () {
            notify(
                "Pickup scheduled for ${areaController.text} on ${dateController.text}");
          },
          child: Text("Notify Residents"),
        ),
        ElevatedButton(
          onPressed: () {
            notify("Special Drive: Plastic Waste Collection Tomorrow");
          },
          child: Text("Announce Special Drive"),
        )
      ],
    );
  }
}

class DriverPanel extends StatelessWidget {
  final Function(String) notify;
  DriverPanel(this.notify);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Driver Actions"),
        ElevatedButton(
          onPressed: () {
            notify("Driver Alert: Pickup delayed due to traffic");
          },
          child: Text("Send Delay Alert"),
        )
      ],
    );
  }
}

class ResidentPanel extends StatelessWidget {
  final Function(String) notify;
  ResidentPanel(this.notify);

  final TextEditingController complaintController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Resident Panel"),
        TextField(
          controller: complaintController,
          decoration: InputDecoration(labelText: "Complaint"),
        ),
        ElevatedButton(
          onPressed: () {
            notify("Complaint Submitted: ${complaintController.text}");
          },
          child: Text("Submit Complaint"),
        ),
        Divider(),
        TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: "Amount"),
        ),
        ElevatedButton(
          onPressed: () {
            notify("Payment Done: ₹${amountController.text}");
          },
          child: Text("Pay Now"),
        )
      ],
    );
  }
}

class AdminPanel extends StatelessWidget {
  final Function(String) notify;
  AdminPanel(this.notify);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Admin Panel"),
        ElevatedButton(
          onPressed: () {
            notify("System Broadcast: Maintain Cleanliness");
          },
          child: Text("Broadcast Notification"),
        )
      ],
    );
  }
}
