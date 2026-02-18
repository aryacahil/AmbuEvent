import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'service/auth_service.dart';
import 'models/user_models.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/loading_widget.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/user_screens.dart';
import 'screens/admin_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSC 119 Event Medic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Cek status login dulu sebelum masuk app
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Masih loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Memuat...');
        }
        // Belum login → ke Welcome/Login
        if (!snapshot.hasData || snapshot.data == null) {
          return const MainAppController(isLoggedIn: false);
        }
        // Sudah login → ambil data role dari Firestore
        return FutureBuilder<UserModel?>(
          future: AuthService().getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(message: 'Memuat profil...');
            }
            if (userSnapshot.data == null) {
              AuthService().signOut();
              return const MainAppController(isLoggedIn: false);
            }
            // Masuk app dengan role dari Firestore
            return MainAppController(
              isLoggedIn: true,
              initialRole: userSnapshot.data!.role,
              loggedInUser: userSnapshot.data!,
            );
          },
        );
      },
    );
  }
}

class MainAppController extends StatefulWidget {
  final bool isLoggedIn;
  final String initialRole;
  final UserModel? loggedInUser;

  const MainAppController({
    super.key,
    this.isLoggedIn = false,
    this.initialRole = 'user',
    this.loggedInUser,
  });

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  late String currentScreen;
  late String userRole;
  String bookingState = 'idle';
  UserModel? _currentUser;

  // Data State
  String eventType = 'Konser';
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventLocController = TextEditingController();

  // Mock Data
  List<Map<String, dynamic>> historyList = [
    {'id': 1, 'date': '20 Mar 2026', 'eventName': 'Konser Musik Jazz', 'type': 'Konser', 'status': 'Terkonfirmasi', 'driver': 'Budi Supir', 'plate': 'B 1234 PSC'},
    {'id': 2, 'date': '15 Feb 2026', 'eventName': 'Marathon Jakarta', 'type': 'Olahraga', 'status': 'Selesai', 'driver': 'Joko', 'plate': 'B 9999 DAR'},
  ];

  List<Map<String, dynamic>> usersList = [
    {'id': 1, 'name': 'Budi Supir', 'email': 'budi@psc.com', 'role': 'admin'},
    {'id': 2, 'name': 'Rafi Putra', 'email': 'rafi@gmail.com', 'role': 'user'},
  ];

  List<Map<String, dynamic>> ambulancesList = [
    {'id': 1, 'plate': 'B 1234 PSC', 'driver': 'Budi Supir', 'status': 'Tersedia'},
    {'id': 2, 'plate': 'B 9999 DAR', 'driver': 'Joko', 'status': 'Booked Event'},
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.loggedInUser;

    if (widget.isLoggedIn) {
      // Sudah login → langsung ke home
      currentScreen = 'home';
      userRole = widget.initialRole;
    } else {
      // Belum login → mulai dari welcome
      currentScreen = 'welcome';
      userRole = 'user';
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && currentScreen == 'welcome') {
          setState(() => currentScreen = 'login');
        }
      });
    }
  }

  // --- Actions ---
  void handleLogin(String role, {UserModel? user}) {
    setState(() {
      userRole = role;
      _currentUser = user;
      currentScreen = 'home';
    });
  }

  void startBooking() => setState(() => bookingState = 'form');

  void confirmBooking() {
    setState(() {
      bookingState = 'searching';
      currentScreen = 'map';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          bookingState = 'booked';
          historyList.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'date': _eventDateController.text.isEmpty ? 'Hari Ini' : _eventDateController.text,
            'eventName': _eventNameController.text.isEmpty ? 'Event Baru' : _eventNameController.text,
            'type': eventType,
            'status': 'Menunggu Konfirmasi',
            'driver': '-',
            'plate': '-',
          });
        });
      }
    });
  }

  void cancelBooking() {
    if (bookingState == 'booked' && historyList.isNotEmpty) {
      if (historyList[0]['status'] == 'Menunggu Konfirmasi') {
        historyList[0]['status'] = 'Dibatalkan';
      }
    }
    setState(() {
      bookingState = 'idle';
      _eventNameController.clear();
      _eventDateController.clear();
      _eventLocController.clear();
      currentScreen = 'home';
    });
  }

  // --- CRUD Actions ---
  void addUser(Map<String, dynamic> user) => setState(() => usersList.add(user));
  void deleteUser(int id) => setState(() => usersList.removeWhere((u) => u['id'] == id));
  void addAmbulance(Map<String, dynamic> amb) => setState(() => ambulancesList.add(amb));
  void deleteAmbulance(int id) => setState(() => ambulancesList.removeWhere((a) => a['id'] == id));

  // Logout
  void handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
      setState(() {
        currentScreen = 'welcome';
        bookingState = 'idle';
        _currentUser = null;
        userRole = 'user';
        // Kembali ke welcome lalu login setelah 3 detik
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && currentScreen == 'welcome') {
            setState(() => currentScreen = 'login');
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _buildScreen(),
          if (['home', 'map', 'history', 'menu'].contains(currentScreen))
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: BottomNav(
                currentScreen: currentScreen,
                onTab: (screen) => setState(() => currentScreen = screen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (currentScreen) {
      case 'welcome':
        return const WelcomeScreen();
      case 'login':
        return LoginScreen(
          onLogin: handleLogin,
          onToSignup: () => setState(() => currentScreen = 'signup'),
        );
      case 'signup':
        return SignupScreen(
          onToLogin: () => setState(() => currentScreen = 'login'),
        );
      case 'home':
        return HomeScreen(
          role: userRole,
          bookingState: bookingState,
          onStartBooking: startBooking,
          onCancelForm: () => setState(() => bookingState = 'idle'),
          onConfirmBooking: confirmBooking,
          eventType: eventType,
          onEventTypeChanged: (val) => setState(() => eventType = val),
          nameCtrl: _eventNameController,
          dateCtrl: _eventDateController,
          locCtrl: _eventLocController,
          onGoToAdminUser: () => setState(() => currentScreen = 'adminUsers'),
          onGoToAdminAmb: () => setState(() => currentScreen = 'adminAmbulances'),
          onGoToMap: () => setState(() => currentScreen = 'map'),
        );
      case 'map':
        return MapScreen(
          bookingState: bookingState,
          eventName: _eventNameController.text,
          eventDate: _eventDateController.text,
          eventLoc: _eventLocController.text,
          onCancel: cancelBooking,
        );
      case 'history':
        return HistoryScreen(history: historyList);
      case 'menu':
        return MenuScreen(
          onLogout: handleLogout,
          userName: _currentUser?.name ?? 'Pengguna',
          userEmail: _currentUser?.email ?? '',
          userPhoto: _currentUser?.photoUrl ?? '',
        );
      case 'adminUsers':
        return AdminUserScreen(
          users: usersList,
          onBack: () => setState(() => currentScreen = 'home'),
          onAdd: addUser,
          onDelete: deleteUser,
        );
      case 'adminAmbulances':
        return AdminAmbulanceScreen(
          ambulances: ambulancesList,
          onBack: () => setState(() => currentScreen = 'home'),
          onAdd: addAmbulance,
          onDelete: deleteAmbulance,
        );
      default:
        return const Center(child: Text("Screen not found"));
    }
  }
}