import 'package:flutter/material.dart';
import 'dart:async';

// Import Screen dan Widget yang sudah dipisah
import 'widgets/bottom_nav.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/user_screens.dart';
import 'screens/admin_screens.dart';

void main() {
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
      home: const MainAppController(),
    );
  }
}

class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  String currentScreen = 'welcome';
  String userRole = 'user'; 
  String bookingState = 'idle';
  
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
    Future.delayed(const Duration(seconds: 3), () {
      if (currentScreen == 'welcome') {
        setState(() => currentScreen = 'login');
      }
    });
  }

  // --- Actions ---
  void handleLogin(String role) {
    setState(() {
      userRole = role;
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
      setState(() {
        bookingState = 'booked';
        historyList.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'date': _eventDateController.text.isEmpty ? 'Hari Ini' : _eventDateController.text,
          'eventName': _eventNameController.text.isEmpty ? 'Event Baru' : _eventNameController.text,
          'type': eventType,
          'status': 'Menunggu Konfirmasi',
          'driver': '-',
          'plate': '-'
        });
      });
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
        return LoginScreen(onLogin: handleLogin);
      case 'signup':
        return SignupScreen(onToLogin: () => setState(() => currentScreen = 'login'));
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
        return MenuScreen(onLogout: () => setState(() {
          currentScreen = 'welcome';
          bookingState = 'idle';
        }));
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