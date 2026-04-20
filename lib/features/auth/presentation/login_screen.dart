import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_providers.dart';
import '../../bootstrap/presentation/bootstrap_screen.dart';
import 'post_login_menu_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _dbController = TextEditingController(text: "aurora_db");
  final _loginController = TextEditingController(text: "parfait.sedogo@resolve-consulting.net");
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(cookieJarProvider).deleteAll();
      final authApi = ref.read(authApiProvider);

      await authApi.login(
        db: _dbController.text.trim(),
        login: _loginController.text.trim(),
        password: _passwordController.text,
      );
      
      await ensureReferenceData(ref);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PostLoginMenuScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _dbController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Padding(
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     children: [
      //       TextField(
      //         controller: _dbController,
      //         decoration: const InputDecoration(labelText: 'Base de donnees'),
      //       ),
      //       const SizedBox(height: 12),
      //       TextField(
      //         controller: _loginController,
      //         decoration: const InputDecoration(labelText: 'Login'),
      //       ),
      //       const SizedBox(height: 12),
      //       TextField(
      //         controller: _passwordController,
      //         obscureText: true,
      //         decoration: const InputDecoration(labelText: 'Mot de passe'),
      //       ),
      //       const SizedBox(height: 20),
      //       SizedBox(
      //         width: double.infinity,
      //         child: ElevatedButton(
      //           onPressed: _loading ? null : _login,
      //           child: _loading
      //               ? const CircularProgressIndicator()
      //               : const Text('Se connecter'),
      //         ),
      //       ),
      //       const SizedBox(height: 16),
      //       if (_error != null)
      //         Text(
      //           _error!,
      //           style: const TextStyle(color: Colors.red),
      //         ),
      //     ],
      //   ),
      // ),
   
        body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Dégradé de fond
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo (Remplacé par une icône pour l'exemple)
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15.0), // Ajoute un peu d'espace autour du logo
              child: Image.asset(
                'assets/images/aurora logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
              const Text(
                'Drilling App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF18E28), //
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Nice to see you Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              //Champ database selected
              _buildLabel("Database"),
              _buildTextField(
                controller: _dbController,
                hint: "",
                enable: false
              ),
              // Champ Email
              _buildLabel("Email"),
              _buildTextField(
                controller: _loginController,
                hint: "Email Address",
                icon: Icons.email_outlined
              ),
              const SizedBox(height: 20),

              // Champ Password
              _buildLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "Enter Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              // Bouton Log In
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF18E28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),

                  child: _loading
                     ? const CircularProgressIndicator()
                  : const Text(
                    'Log In',
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                
              
              ),
              const SizedBox(height: 30),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              // Footer Sign Up
              RichText(
                text: const TextSpan(
                  text: "©2026. AnisCORP.All Right Deserved",
                  style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}


 // Widget Helper pour les labels
  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ),
    );
  }


  // Widget Helper pour les champs de texte
  Widget _buildTextField({required TextEditingController controller ,bool enable = true, String? hint, IconData? icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled:enable,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Colors.grey) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
