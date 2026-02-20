import 'package:flutter/material.dart';
import '../widgets/painters.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  final String bookingState;
  final VoidCallback onStartBooking;
  final VoidCallback onCancelForm;
  final VoidCallback onConfirmBooking;
  final String eventType;
  final Function(String) onEventTypeChanged;
  final TextEditingController nameCtrl;
  final TextEditingController dateCtrl;
  final TextEditingController locCtrl;
  final VoidCallback onGoToAdminUser;
  final VoidCallback onGoToAdminAmb;
  final VoidCallback onGoToMap;

  const HomeScreen({
    super.key, required this.role, required this.bookingState,
    required this.onStartBooking, required this.onCancelForm, required this.onConfirmBooking,
    required this.eventType, required this.onEventTypeChanged,
    required this.nameCtrl, required this.dateCtrl, required this.locCtrl,
    required this.onGoToAdminUser, required this.onGoToAdminAmb, required this.onGoToMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Mock Map
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          color: const Color(0xFFE8EAE6),
          child: Stack(
            children: [
              CustomPaint(size: Size.infinite, painter: GridPainter()),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 40, color: Colors.blue),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Text("Area Layanan", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 40, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const Row(children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Dinkes Kab. Madiun", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ]),
                ),
              )
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
            ),
            child: bookingState == 'idle' 
              ? _buildIdleContent() 
              : _buildBookingForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildIdleContent() {
    return Column(
      children: [
        const Icon(Icons.medical_services_outlined, size: 80, color: Colors.red),
        const SizedBox(height: 10),
        Text(role == 'admin' ? "Dashboard Admin" : "Booking Event", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        if (role == 'user') ...[
          const Text("Sediakan layanan medis standby untuk kelancaran event Anda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartBooking,
              icon: const Icon(Icons.calendar_month),
              label: const Text("PESAN AMBULANCE EVENT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ] else ...[
          // Admin View
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: Colors.blue.shade700, width: 4))),
            child: Row(
              children: [
                Icon(Icons.calendar_month, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Expanded(child: Text("3 Jadwal event baru masuk.", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _adminBtn("Kelola User", Icons.people, Colors.blue, onGoToAdminUser)),
              const SizedBox(width: 12),
              Expanded(child: _adminBtn("Kelola Armada", Icons.monitor_heart, Colors.red, onGoToAdminAmb)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGoToMap,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Lihat Peta Event"),
            ),
          )
        ]
      ],
    );
  }

  Widget _adminBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Detail Event", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: onCancelForm, icon: const Icon(Icons.close, color: Colors.grey)),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildTextField("Nama Event", "Contoh: Konser Fair", nameCtrl),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildTextField("Tanggal", "YYYY-MM-DD", dateCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField("Lokasi", "GBK", locCtrl)),
              ]),
              const SizedBox(height: 20),
              const Text("Tipe Acara:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10,
                children: [
                  _eventTypeBtn("Konser", Icons.music_note),
                  _eventTypeBtn("Olahraga", Icons.emoji_events),
                  _eventTypeBtn("Pernikahan", Icons.people_alt),
                  _eventTypeBtn("Gathering", Icons.work),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text("Tim medis akan hadir 1 jam sebelum acara (Loading Dock).", style: TextStyle(fontSize: 12, color: Colors.blue)),
              )
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirmBooking,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text("KONFIRMASI JADWAL", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _eventTypeBtn(String label, IconData icon) {
    bool isSelected = eventType == label;
    return GestureDetector(
      onTap: () => onEventTypeChanged(label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.red : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.red : Colors.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.red : Colors.grey)),
          ],
        ),
      ),
    );
  }
}