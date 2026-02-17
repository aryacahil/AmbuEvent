import 'package:flutter/material.dart';
import '../widgets/painters.dart'; // Sesuaikan path jika berbeda

// --- Welcome Screen ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TopWavePainter(),
        const BottomCityPainter(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("WELCOME", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
              const SizedBox(height: 30),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                ),
                child: const Center(
                  child: Icon(Icons.airport_shuttle_rounded, size: 100, color: Colors.red),
                ),
              ),
              const SizedBox(height: 30),
              const Text("PSC 119", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 4)),
              const Text("EVENT MEDIC", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
            ],
          ),
        )
      ],
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TopWavePainter(),
        const BottomCityPainter(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: const Icon(Icons.airport_shuttle_rounded, size: 60, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text("Sign Your Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildInput("Email", Icons.person),
              const SizedBox(height: 15),
              _buildInput("Password", Icons.lock, isObscure: true),
              const SizedBox(height: 20),
              // Role Selector Mock
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRadio('User', 'user'),
                  const SizedBox(width: 20),
                  _buildRadio('Admin', 'admin'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onLogin(selectedRole),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRadio(String label, String val) {
    return GestureDetector(
      onTap: () => setState(() => selectedRole = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectedRole == val ? Colors.white : Colors.white60,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selectedRole == val ? Colors.red : Colors.transparent)
        ),
        child: Row(
          children: [
            Icon(selectedRole == val ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: Colors.red),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFA6969),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const SizedBox(), 
          suffixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// --- Signup Screen ---
class SignupScreen extends StatelessWidget {
  final VoidCallback onToLogin;
  const SignupScreen({super.key, required this.onToLogin});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TopWavePainter(),
        const BottomCityPainter(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed: onToLogin, 
                 child: const Text("Back to Login")
               )
            ],
          ),
        )
      ],
    );
  }
}