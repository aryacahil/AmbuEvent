import 'package:flutter/material.dart';

class AdminUserScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int) onDelete;

  const AdminUserScreen({super.key, required this.users, required this.onBack, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen User"), 
        backgroundColor: Colors.red, 
        foregroundColor: Colors.white, 
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAdd({'id': DateTime.now().millisecondsSinceEpoch, 'name': 'User Baru', 'email': 'new@mail.com', 'role': 'user'}),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (ctx, i) {
          final u = users[i];
          return Card(
            child: ListTile(
              title: Text(u['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(u['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(label: Text(u['role'].toString().toUpperCase(), style: const TextStyle(fontSize: 10))),
                  IconButton(onPressed: () => onDelete(u['id']), icon: const Icon(Icons.delete, color: Colors.red))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminAmbulanceScreen extends StatelessWidget {
  final List<Map<String, dynamic>> ambulances;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int) onDelete;

  const AdminAmbulanceScreen({super.key, required this.ambulances, required this.onBack, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Armada"), 
        backgroundColor: Colors.red, 
        foregroundColor: Colors.white, 
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAdd({'id': DateTime.now().millisecondsSinceEpoch, 'plate': 'B XXXX New', 'driver': 'Supir Baru', 'status': 'Tersedia'}),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ambulances.length,
        itemBuilder: (ctx, i) {
          final a = ambulances[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.airport_shuttle, color: Colors.white)),
              title: Text(a['plate'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Supir: ${a['driver']}"),
              trailing: IconButton(onPressed: () => onDelete(a['id']), icon: const Icon(Icons.delete, color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}