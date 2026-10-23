import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_providers.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/report_draft_provider.dart';
import '../../../shared/services/offline_auth_service.dart';
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

  final _dbController = TextEditingController(text: 'TRAINING');
  final _loginController = TextEditingController();
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
    final db = _dbController.text.trim();

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
      await _performOnlineLogin(db: db, login: login, password: password);
    } on DioException catch (_) {
      // Reseau injoignable / serveur down → tentative de login offline
      await _performOfflineLogin(db: db, login: login, password: password);
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

  Future<void> _performOnlineLogin({
    required String db,
    required String login,
    required String password,
  }) async {
    await ref.read(cookieJarProvider).deleteAll();
    final authApi = ref.read(authApiProvider);
    await authApi.login(
      db: db,
      login: login,
      password: password,
    );

    final bootstrapResult = await ref.read(bootstrapApiProvider).fetchBootstrap();
    final companyData = Map<String, dynamic>.from(bootstrapResult['company'] as Map? ?? const {});
    final employeeContext =
        Map<String, dynamic>.from(bootstrapResult['employee_context'] as Map? ?? const {});
    final companyId = (companyData['id'] as num?)?.toInt();
    final companyName = companyData['name']?.toString() ?? '';
    final employeeId = (employeeContext['employee_id'] as num?)?.toInt();
    final employeeName = employeeContext['employee_name']?.toString() ?? '';
    final mobileScopeCache = ref.read(mobileScopeCacheProvider);
    final companyLock = ref.read(tabletCompanyLockProvider);
    final database = ref.read(appDatabaseProvider);
    final cachedScope = await mobileScopeCache.readScope();
    final binding = await companyLock.readBinding();
    final cachedCompanyId =
        (cachedScope?['company_id'] as int?) ?? (binding?['company_id'] as int?);
    final hasUnsyncedData = await database.hasUnsyncedLocalFeuilles();

    if (companyId == null || companyName.isEmpty) {
      await authApi.logout();
      await ref.read(cookieJarProvider).deleteAll();
      throw Exception('Societe mobile introuvable dans le bootstrap');
    }

    if (employeeId == null || employeeName.isEmpty) {
      await authApi.logout();
      await ref.read(cookieJarProvider).deleteAll();
      throw Exception('Contexte employe mobile introuvable dans le bootstrap');
    }

    if (hasUnsyncedData && cachedCompanyId == null) {
      await authApi.logout();
      await ref.read(cookieJarProvider).deleteAll();
      throw Exception(
        'Des donnees non synchronisees existent sur cette tablette. Impossible de verifier le changement de societe tant que ces donnees ne sont pas synchronisees ou supprimees.',
      );
    }

    if (cachedCompanyId != null && cachedCompanyId != companyId) {
      if (hasUnsyncedData) {
        await authApi.logout();
        await ref.read(cookieJarProvider).deleteAll();
        throw Exception(
          'Des donnees non synchronisees existent sur cette tablette. Synchronisez ou supprimez-les avant de changer de societe.',
        );
      }

      await database.clearAllLocalData();
      await ref.read(projectDrillingTaskStoreProvider).clear();
      await ref.read(projectHoleProgressStoreProvider).clear();
      await ref.read(projectDrillingTypeStoreProvider).clear();
      await ref.read(materialTagStoreProvider).clear();
      await mobileScopeCache.clear();
      await companyLock.clearBinding();
      await ref.read(offlineAuthServiceProvider).clear();
      ref.read(reportDraftProvider.notifier).reset();
    }

    await ensureReferenceData(ref, bootstrapResult: bootstrapResult);

    // Login online complet et donnees en cache OK → on peut activer le login offline
    await ref.read(offlineAuthServiceProvider).saveCredentials(
          db: db,
          login: login,
          password: password,
        );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PostLoginMenuScreen(),
      ),
    );
  }

  Future<void> _performOfflineLogin({
    required String db,
    required String login,
    required String password,
  }) async {
    final offlineAuth = ref.read(offlineAuthServiceProvider);
    final result = await offlineAuth.validateOffline(
      db: db,
      login: login,
      password: password,
    );

    if (result == OfflineAuthResult.valid) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PostLoginMenuScreen(),
        ),
      );
      return;
    }

    String message;
    switch (result) {
      case OfflineAuthResult.noCredentialsStored:
      case OfflineAuthResult.credentialsMismatch:
        message =
            'Pas de reseau et aucun compte enregistre pour cet utilisateur sur cette tablette. Une premiere connexion avec internet est necessaire.';
        break;
      case OfflineAuthResult.wrongPassword:
        message = 'Mot de passe incorrect';
        break;
      case OfflineAuthResult.expired:
        message =
            'Session hors-ligne expiree (7 jours max sans reconnexion). Veuillez vous reconnecter avec internet.';
        break;
      case OfflineAuthResult.valid:
        return;
    }

    if (mounted) {
      await _showErrorDialog(message);
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: _buildGlow(320, _orange.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: _buildGlow(380, _navy.withValues(alpha: 0.05)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return isWide ? _buildWideLayout() : _buildCompactLayout();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _buildWideLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A13233F),
                  blurRadius: 44,
                  offset: Offset(0, 24),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 420, child: _buildBrandPanel()),
                  Expanded(child: _buildLoginCard(wide: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCompactHero(),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A13233F),
                        blurRadius: 34,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: _buildLoginCard(wide: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Brand side (wide screens)
  // ---------------------------------------------------------------------------

  Widget _buildBrandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13233F), Color(0xFF1E3A5F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: _buildGlow(240, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -90,
            left: -60,
            child: _buildGlow(230, _orange.withValues(alpha: 0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Image.asset(
                        'assets/images/aurora_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Rapport De Forage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aurora · Saisie des feuilles de forage',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: 52,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _orange,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildFeatureRow(
                      Icons.offline_bolt_outlined,
                      'Fonctionne hors-ligne',
                      'Saisie terrain sans connexion, synchronisation des que le reseau revient.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.tablet_android_outlined,
                      'Pense pour la tablette',
                      'Des zones de saisie larges, adaptees au travail en zone de forage.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.sync_alt_rounded,
                      'Synchronisation Odoo',
                      'Envoi des feuilles completes vers le serveur en une seule action.',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Session securisee · Aurora Drilling Report',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _orange, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Brand header (phones)
  // ---------------------------------------------------------------------------

  Widget _buildCompactHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13233F), Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(
                  'assets/images/aurora_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Rapport De Forage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aurora · Saisie des feuilles de forage',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Login form
  // ---------------------------------------------------------------------------

  Widget _buildLoginCard({required bool wide}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 44 : 24,
        vertical: wide ? 44 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CONNEXION',
                style: TextStyle(
                  color: _orange,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Bienvenue',
            style: TextStyle(
              color: _textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Connectez-vous pour acceder a vos feuilles de forage.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _buildLabel('Utilisateur'),
          _buildTextField(
            controller: _loginController,
            hint: 'Entrez votre nom utilisateur',
            icon: Icons.person_2_outlined,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 18),
          _buildLabel('Mot de passe'),
          _buildTextField(
            controller: _passwordController,
            hint: 'Entrez votre mot de passe',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            onTogglePassword: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) {
              if (!_loading) {
                _login();
              }
            },
          ),
          const SizedBox(height: 22),
          _buildOfflineNote(),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _login,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: _navy,
                disabledBackgroundColor: _orange.withValues(alpha: 0.55),
                disabledForegroundColor: _navy.withValues(alpha: 0.55),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
                        Icon(Icons.login_rounded, size: 20),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Se Connecter',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: _muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Connexion securisee · Aurora Drilling Report',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.9),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0E4BC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: _orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode hors-ligne disponible apres une premiere connexion avec internet.',
              style: TextStyle(
                color: _muted.withValues(alpha: 0.95),
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _muted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    Iterable<String>? autofillHints,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
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
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: _navy.withValues(alpha: 0.7), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                tooltip: obscureText
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _muted,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD7DFEA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD7DFEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _orange, width: 1.6),
        ),
      ),
    );
  }
}
