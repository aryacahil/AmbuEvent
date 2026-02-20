import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _adminEmails = [
    'campgreget2@gmail.com',
    'rafiputraadipratama4@gmail.com'
  ];

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // === LOGIN DENGAN EMAIL & PASSWORD ===
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user == null) return null;

      // Ambil data user dari Firestore
      return await getUserData(user.uid);
    } catch (e) {
      print('Error sign in with email: $e');
      return null;
    }
  }

  // === REGISTER DENGAN EMAIL & PASSWORD ===
  Future<UserModel?> registerWithEmail(
  String email,
  String password,
  String name,
) async {
  try {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = result.user;
    if (user == null) return null;

    // Tentukan role
    final String role = _adminEmails.contains(email) ? 'admin' : 'user';

    // Simpan ke Firestore DULU (saat user masih ter-autentikasi)
    final newUser = UserModel(
      uid: user.uid,
      email: email,
      name: name,
      photoUrl: '',
      role: role,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

    // Update display name SETELAH data tersimpan
    await user.updateDisplayName(name);
    await user.reload();

    return newUser;
  } catch (e) {
    print('Error register: $e');
    return null;
  }
}

  // === LOGIN DENGAN GOOGLE ===
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final User? user = result.user;
      if (user == null) return null;

      final String role =
          _adminEmails.contains(user.email) ? 'admin' : 'user';

      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          photoUrl: user.photoURL ?? '',
          role: role,
          createdAt: DateTime.now(),
        );
        await docRef.set(newUser.toMap());
        return newUser;
      } else {
        return UserModel.fromMap(docSnapshot.data()!);
      }
    } catch (e) {
      print('Error sign in with Google: $e');
      return null;
    }
  }

  // === GET USER DATA ===
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // === LOGOUT ===
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}