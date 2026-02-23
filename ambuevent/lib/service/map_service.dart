// lib/service/map_service.dart
// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =====================
  // GPS / LOKASI USER
  // =====================

  /// Minta izin lokasi dan ambil posisi user saat ini
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Cek apakah location service aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return null;
      }

      // Ambil posisi
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Stream lokasi user (update real-time)
  Stream<LatLng> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update setiap 10 meter
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => LatLng(position.latitude, position.longitude));
  }

  // =====================
  // AMBULANCE LIVE LOCATION (Firestore)
  // =====================

  /// Stream semua ambulance yang sedang aktif / bertugas
  Stream<List<AmbulanceLocation>> getAmbulancesLocation() {
    return _firestore
        .collection('ambulances')
        .where('status', isEqualTo: 'Booked Event')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) =>
              doc.data().containsKey('lat') && doc.data().containsKey('lng'))
          .map((doc) {
        final data = doc.data();
        return AmbulanceLocation(
          id: doc.id,
          plate: data['plate'] ?? '',
          driver: data['driver'] ?? '',
          lat: (data['lat'] as num).toDouble(),
          lng: (data['lng'] as num).toDouble(),
          status: data['status'] ?? '',
        );
      }).toList();
    });
  }

  /// Update lokasi ambulance (dipanggil dari sisi driver/admin)
  Future<void> updateAmbulanceLocation(
      String ambulanceId, double lat, double lng) async {
    try {
      await _firestore.collection('ambulances').doc(ambulanceId).update({
        'lat': lat,
        'lng': lng,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating ambulance location: $e');
    }
  }

  // =====================
  // ROUTING (OSRM - Open Source)
  // =====================

  /// Hitung jarak antara dua titik (meter)
  double calculateDistance(LatLng from, LatLng to) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Meter, from, to);
  }

  /// Format jarak ke string yang readable
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Estimasi waktu tempuh (asumsi 40 km/jam dalam kota)
  String estimateTime(double meters) {
    final double minutes = (meters / 1000) / 40 * 60;
    if (minutes < 60) {
      return '~${minutes.toStringAsFixed(0)} menit';
    } else {
      final int hours = (minutes / 60).floor();
      final int mins = (minutes % 60).toInt();
      return '~$hours jam $mins menit';
    }
  }
}

/// Model untuk lokasi ambulance
class AmbulanceLocation {
  final String id;
  final String plate;
  final String driver;
  final double lat;
  final double lng;
  final String status;

  AmbulanceLocation({
    required this.id,
    required this.plate,
    required this.driver,
    required this.lat,
    required this.lng,
    required this.status,
  });

  LatLng get latLng => LatLng(lat, lng);
}