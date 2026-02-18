import 'package:flutter/material.dart';
import '../widgets/painters.dart';
import '../service/auth_service.dart';
import '../models/user_models.dart';

// --- Welcome Screen --- (TIDAK DIUBAH)
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
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
        ),
      ],
    );
  }
}

// --- Login Screen --- (EMAIL + GOOGLE)
class LoginScreen extends StatefulWidget {
  final Function(String role, {UserModel? user}) onLogin;
  final VoidCallback onToSignup;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Login dengan Email & Password
  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserModel? user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (user != null && mounted) {
        widget.onLogin(user.role, user: user);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password salah!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Login dengan Google
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final UserModel? user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        widget.onLogin(user.role, user: user);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Google dibatalkan.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Google Sign-In: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(Icons.airport_shuttle_rounded, size: 60, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text("Sign In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Email Input
              _buildInput("Email", Icons.person, controller: _emailController),
              const SizedBox(height: 15),

              // Password Input
              _buildInput("Password", Icons.lock, isObscure: true, controller: _passwordController),
              const SizedBox(height: 25),

              // Tombol LOGIN dengan Email
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.red)
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleEmailLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        const Text("— ATAU —", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 15),

                        // Tombol Google Sign-In
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Center(
                                child: Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                            label: const Text("Login dengan Google", style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.grey, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey)),
                            GestureDetector(
                              onTap: widget.onToSignup,
                              child: const Text("Daftar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isObscure = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFA6969),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          suffixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// --- Signup Screen ---
class SignupScreen extends StatefulWidget {
  final VoidCallback onToLogin;
  const SignupScreen({super.key, required this.onToLogin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserModel? user = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text,
      );
      
      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: Colors.green),
        );
        widget.onToLogin();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(Icons.airport_shuttle_rounded, size: 60, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _buildInput("Nama Lengkap", Icons.person, controller: _nameController),
              const SizedBox(height: 15),
              _buildInput("Email", Icons.email, controller: _emailController),
              const SizedBox(height: 15),
              _buildInput("Password", Icons.lock, isObscure: true, controller: _passwordController),
              const SizedBox(height: 25),

              _isLoading
                  ? const CircularProgressIndicator(color: Colors.red)
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("DAFTAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey)),
                            GestureDetector(
                              onTap: widget.onToLogin,
                              child: const Text("Login", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isObscure = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFA6969),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          suffixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}