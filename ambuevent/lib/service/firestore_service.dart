// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === USER CRUD ===
  
  // Get semua user
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // tambahkan document ID
        return data;
      }).toList();
    });
  }

  // Update user
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error update user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      print('Error delete user: $e');
      return false;
    }
  }

  // === ARMADA CRUD ===
  
  // Get semua armada
  Stream<List<Map<String, dynamic>>> getAmbulances() {
    return _firestore.collection('ambulances').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Tambah armada
  Future<bool> addAmbulance(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('ambulances').add({
        ...data,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error add ambulance: $e');
      return false;
    }
  }

  // Update armada
  Future<bool> updateAmbulance(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('ambulances').doc(id).update(data);
      return true;
    } catch (e) {
      print('Error update ambulance: $e');
      return false;
    }
  }

  // Delete armada
  Future<bool> deleteAmbulance(String id) async {
    try {
      await _firestore.collection('ambulances').doc(id).delete();
      return true;
    } catch (e) {
      print('Error delete ambulance: $e');
      return false;
    }
  }
}