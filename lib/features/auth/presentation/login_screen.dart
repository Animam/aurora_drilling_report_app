import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_providers.dart';
import '../../../shared/providers/app_providers.dart';
import '../../bootstrap/presentation/bootstrap_screen.dart';
import 'post_login_menu_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _navy = Color(0xFF13233F);
  static const _orange = Color(0xFFF18E28);
  static const _textDark = Color(0xFF18243E);
  static const _muted = Color(0xFF69758C);

  final _dbController = TextEditingController(text: 'aurora_db');
  final _loginController = TextEditingController(
    text: 'aurora@drilling.com',
  );
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _showErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Erreur',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty) {
      await _showErrorDialog('Email obligatoire');
      return;
    }

    if (password.isEmpty) {
      await _showErrorDialog('Mot de passe obligatoire');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ref.read(cookieJarProvider).deleteAll();
      final authApi = ref.read(authApiProvider);
      final loginResult = await authApi.login(
        db: _dbController.text.trim(),
        login: login,
        password: password,
      );

      final companyId = loginResult['company_id'] as int?;
      final companyName = loginResult['company_name']?.toString() ?? '';
      final companyLock = ref.read(tabletCompanyLockProvider);
      final binding = await companyLock.readBinding();

      if (binding != null) {
        final boundCompanyId = binding['company_id'] as int?;
        final boundCompanyName = binding['company_name']?.toString() ?? '';

        if (companyId == null || boundCompanyId != companyId) {
          await authApi.logout();
          await ref.read(cookieJarProvider).deleteAll();
          throw Exception('Cette tablette est dedier au $boundCompanyName');
        }
      } else {
        if (companyId == null || companyName.isEmpty) {
          await authApi.logout();
          await ref.read(cookieJarProvider).deleteAll();
          throw Exception('Societe utilisateur introuvable');
        }

        await companyLock.bindCompany(
          companyId: companyId,
          companyName: companyName,
        );
      }

      await ensureReferenceData(ref);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PostLoginMenuScreen(),
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        await _showErrorDialog(message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _navy,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Image.asset(
                              'assets/images/aurora logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Rapport De Forage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          _buildLabel('Utilisateur'),
                          _buildTextField(
                            controller: _loginController,
                            hint: 'Entrez nom utilisateur',
                            icon: Icons.person_2,
                          ),
                          const SizedBox(height: 18),
                          _buildLabel('Mot de Passe'),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Entrez Mot de Passe',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: _orange.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor: AlwaysStoppedAnimation<Color>(_navy),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Se Connecter',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                   
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: _textDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String? hint,
    required IconData icon,
    bool enable = true,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enable ? const Color(0xFFF8FAFD) : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enable ? const Color(0xFFD7DFEA) : const Color(0xFFE5EAF1),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enable,
        obscureText: isPassword ? obscureText : false,
        style: const TextStyle(
          color: _textDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: _navy.withValues(alpha: 0.75)),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _muted,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
