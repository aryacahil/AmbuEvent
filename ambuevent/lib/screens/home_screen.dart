// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/map_service.dart';

class HomeScreen extends StatefulWidget {
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
    super.key,
    required this.role,
    required this.bookingState,
    required this.onStartBooking,
    required this.onCancelForm,
    required this.onConfirmBooking,
    required this.eventType,
    required this.onEventTypeChanged,
    required this.nameCtrl,
    required this.dateCtrl,
    required this.locCtrl,
    required this.onGoToAdminUser,
    required this.onGoToAdminAmb,
    required this.onGoToMap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();

  static const LatLng _dinkesLocation = LatLng(-7.624662988533274, 111.4947916090254);

  LatLng? _userLocation;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final location = await _mapService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = location;
        _locationLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== MINI MAP OSM =====
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Stack(
            children: [
              // FlutterMap - selalu center ke Dinkes
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _dinkesLocation,
                  initialZoom: 15, // zoom in karena ini lokasi tetap
                  maxZoom: 18,
                  minZoom: 5,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.none, // non-interaktif di home
                  ),
                ),
                children: [
                  // Tile OSM
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ambuevent',
                    maxZoom: 18,
                  ),

                  // Marker Layer
                  MarkerLayer(
                    markers: [
                      // ✅ Marker merah untuk Dinkes Kab. Madiun
                      Marker(
                        point: _dinkesLocation,
                        width: 60,
                        height: 70,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      // Marker biru untuk lokasi user (jika GPS aktif)
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Loading GPS
              if (!_locationLoaded)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Mendapatkan lokasi Anda...',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Info bar Dinkes di atas peta
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_hospital,
                            color: Colors.red, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dinkes Kab. Madiun",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Jl. Raya Solo No. 32, Jiwan",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol buka peta penuh
              Positioned(
                bottom: 14,
                right: 14,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onGoToMap,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.fullscreen, color: Colors.red, size: 22),
                    ),
                  ),
                ),
              ),

              // Badge jarak dari user ke Dinkes (jika GPS aktif)
              if (_userLocation != null)
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          _mapService.formatDistance(
                            _mapService.calculateDistance(
                              _userLocation!,
                              _dinkesLocation,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          ' dari Anda',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ===== CONTENT BAWAH =====
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                )
              ],
            ),
            child: widget.bookingState == 'idle'
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
        const Icon(Icons.medical_services_outlined,
            size: 80, color: Colors.red),
        const SizedBox(height: 10),
        Text(
          widget.role == 'admin' ? "Dashboard Admin" : "Booking Event",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (widget.role == 'user') ...[
          const Text(
            "Sediakan layanan medis standby untuk kelancaran event Anda.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onStartBooking,
              icon: const Icon(Icons.calendar_month),
              label: const Text("PESAN AMBULANCE EVENT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                  left: BorderSide(color: Colors.blue.shade700, width: 4)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "3 Jadwal event baru masuk.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _adminBtn("Kelola User", Icons.people, Colors.blue,
                    widget.onGoToAdminUser),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _adminBtn("Kelola Armada", Icons.monitor_heart,
                    Colors.red, widget.onGoToAdminAmb),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onGoToMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Lihat Peta Event"),
            ),
          ),
        ],
      ],
    );
  }

  Widget _adminBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
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
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12)),
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
            const Text("Detail Event",
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: widget.onCancelForm,
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildTextField(
                  "Nama Event", "Contoh: Konser Fair", widget.nameCtrl),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        "Tanggal", "YYYY-MM-DD", widget.dateCtrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _buildTextField("Lokasi", "GBK", widget.locCtrl),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Tipe Acara:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Tim medis akan hadir 1 jam sebelum acara (Loading Dock).",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onConfirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("KONFIRMASI JADWAL",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _eventTypeBtn(String label, IconData icon) {
    bool isSelected = widget.eventType == label;
    return GestureDetector(
      onTap: () => widget.onEventTypeChanged(label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.red : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}