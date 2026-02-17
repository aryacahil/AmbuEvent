import 'package:flutter/material.dart';
import '../widgets/painters.dart'; // Import painter untuk MapScreen

// --- Map Screen ---
class MapScreen extends StatelessWidget {
  final String bookingState;
  final String eventName;
  final String eventDate;
  final String eventLoc;
  final VoidCallback onCancel;

  const MapScreen({super.key, required this.bookingState, required this.eventName, required this.eventDate, required this.eventLoc, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookingState == 'searching' ? "Memproses..." : "Peta Event"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFE8EAE6), child: CustomPaint(size: Size.infinite, painter: GridPainter())),
          
          // User Marker
          const Center(child: Icon(Icons.location_on, size: 50, color: Colors.blue)),
          
          // Ambulance Marker (Simulated)
          if(bookingState == 'idle')
            const Positioned(top: 100, right: 50, child: Icon(Icons.airport_shuttle, color: Colors.red)),

          // Booking Overlay
          if (bookingState == 'searching')
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text("Memverifikasi Ketersediaan..."),
                      const SizedBox(height: 10),
                      TextButton(onPressed: onCancel, child: const Text("Batalkan", style: TextStyle(color: Colors.red)))
                    ],
                  ),
                ),
              ),
            ),

          if (bookingState == 'booked')
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(4), color: Colors.green.shade100, child: const Text("BOOKING TERKIRIM", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 10),
                      const Text("Menunggu Konfirmasi Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text("Kami akan menghubungi via WhatsApp 1x24 jam.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.description, color: Colors.blue),
                        title: Text(eventName.isEmpty ? "Event Baru" : eventName),
                        subtitle: Text("$eventDate • $eventLoc"),
                      ),
                      ElevatedButton(onPressed: onCancel, child: const Text("Kembali ke Menu Utama"))
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// --- History Screen ---
class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Event"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 10, left: 16, right: 16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          Color statusColor = item['status'] == 'Selesai' ? Colors.green : (item['status'] == 'Dibatalkan' ? Colors.red : Colors.orange);
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(item['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.music_note, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['eventName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Tipe: ${item['type']} • Supir: ${item['driver']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Menu/Profile Screen ---
class MenuScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const MenuScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("Selamat", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("Siang! 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text("Rafi Putra", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text("rafi@gmail.com", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _menuItem(Icons.notifications, "Notifications"),
                  _menuItem(Icons.message, "Messages", badge: "2"),
                  _menuItem(Icons.person, "My Profile"),
                  _menuItem(Icons.settings, "Settings"),
                  ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle), child: const Icon(Icons.logout, color: Colors.white, size: 16)),
                    title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: onLogout,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {String? badge}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(icon, color: Colors.black, size: 18)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: badge != null ? Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10))) : null,
    );
  }
}