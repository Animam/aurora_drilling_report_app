import 'package:aurora_drilling_report/features/auth/presentation/feuille_list_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/login_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/registration_screen.dart';
import 'package:aurora_drilling_report/shared/providers/api_providers.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostLoginMenuScreen extends ConsumerStatefulWidget {
  const PostLoginMenuScreen({
    super.key,
    this.initialMessage,
    this.initialMessageIsError = false,
  });

  final String? initialMessage;
  final bool initialMessageIsError;

  @override
  ConsumerState<PostLoginMenuScreen> createState() => _PostLoginMenuScreenState();
}

class _PostLoginMenuScreenState extends ConsumerState<PostLoginMenuScreen> {
  bool _initialMessageShown = false;
  String? _employeeName;
  String? _companyName;
  int? _pendingCount;

  Future<void> _loadUserInfo() async {
    Map<String, dynamic>? scope;
    try {
      scope = await ref.read(mobileScopeCacheProvider).readScope();
    } catch (_) {
      scope = null;
    }

    int? pendingCount;
    try {
      final pending = await ref.read(appDatabaseProvider).getPendingFeuilles();
      pendingCount = pending.length;
    } catch (_) {
      pendingCount = null;
    }

    if (!mounted) return;
    setState(() {
      if (scope != null) {
        _employeeName = scope['employee_name']?.toString();
        _companyName = scope['company_name']?.toString();
      }
      _pendingCount = pendingCount;
    });
  }

  String get _displayName {
    final name = _employeeName?.trim();
    return name == null || name.isEmpty ? 'Utilisateur' : name;
  }

  String get _companyLabel {
    final name = _companyName?.trim();
    return name == null || name.isEmpty ? '' : name;
  }

  void _showUserInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF13233F),
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text(
                'Profil',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _employeeName?.isNotEmpty == true ? _employeeName! : 'Utilisateur',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (_companyName?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.business_rounded, size: 16, color: Color(0xFF69758C)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _companyName!,
                        style: const TextStyle(color: Color(0xFF69758C), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    ref.read(reportDraftProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }

  void _openPendingSheets(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FeuilleListScreen()),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Deconnexion',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Voulez-vous vraiment vous deconnecter ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Se deconnecter'),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _logout(context, ref);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authApiProvider).logout();
    } catch (_) {
      // Even if the server session is already gone, local cleanup must continue.
    }

    await ref.read(cookieJarProvider).deleteAll();
    ref.read(reportDraftProvider.notifier).reset();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_showInitialMessageIfNeeded);
    Future.microtask(_loadUserInfo);
  }

  void _showInitialMessageIfNeeded() {
    if (_initialMessageShown || !mounted) {
      return;
    }
    final message = widget.initialMessage?.trim();
    if (message == null || message.isEmpty) {
      return;
    }

    _initialMessageShown = true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: widget.initialMessageIsError
              ? Colors.redAccent
              : const Color(0xFF0F9D8A),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8E1),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E8F0)),
              ),
              child: Image.asset(
                'assets/images/aurora_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Accueil',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF18243E),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              tooltip: 'Se deconnecter',
              onPressed: () => _confirmLogout(context, ref),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF13233F),
                side: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: _buildGlow(
              300,
              const Color(0xFFF18E28).withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: _buildGlow(
              360,
              const Color(0xFF13233F).withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return isWide ? _buildWideLayout() : _buildPhoneLayout();
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
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
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
                  blurRadius: 40,
                  offset: Offset(0, 22),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 380, child: _buildIdentityPanel()),
                  Expanded(child: _buildActionsPanel(wide: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIdentityHero(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A13233F),
                        blurRadius: 32,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: _buildActionsPanel(wide: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Identity (user + company + pending sheets)
  // ---------------------------------------------------------------------------

  Widget _buildIdentityPanel() {
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
            top: -60,
            right: -70,
            child: _buildGlow(220, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _buildGlow(
              220,
              const Color(0xFFF18E28).withValues(alpha: 0.18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(size: 84),
                    const SizedBox(height: 26),
                    Text(
                      'BON RETOUR',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_companyLabel.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.58),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _companyLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: 52,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF18E28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildPendingStat(onDark: true),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Session active sur cette tablette',
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

  Widget _buildIdentityHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 58),
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
              _buildAvatar(size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BON RETOUR',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    if (_companyLabel.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.58),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _companyLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF18E28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          _buildPendingStat(onDark: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required double size}) {
    return InkWell(
      onTap: () => _showUserInfo(context),
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: size * 0.46,
        ),
      ),
    );
  }

  Widget _buildPendingStat({required bool onDark}) {
    final count = _pendingCount;
    final value = count == null ? '--' : '$count';
    final caption = count == null
        ? 'Etat indisponible'
        : count == 0
            ? 'Tout est synchronise'
            : 'a synchroniser';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFE5EBF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FEUILLES EN ATTENTE',
            style: TextStyle(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.52)
                  : const Color(0xFF69758C),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: onDark ? Colors.white : const Color(0xFF18243E),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onDark
                          ? Colors.white.withValues(alpha: 0.58)
                          : const Color(0xFF69758C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActionsPanel({required bool wide}) {
    final count = _pendingCount;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 24,
        vertical: wide ? 36 : 26,
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
                  color: Color(0xFFF18E28),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'MENU PRINCIPAL',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF18E28),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Que souhaitez-vous faire ?',
            style: TextStyle(
              color: Color(0xFF18243E),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Creez une nouvelle feuille de forage ou retrouvez celles en attente de synchronisation.',
            style: TextStyle(
              color: Color(0xFF69758C),
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _ActionCard(
            icon: Icons.note_add_outlined,
            title: 'Creer une nouvelle feuille',
            subtitle: 'Demarrer une nouvelle saisie pour le shift en cours.',
            accent: const Color(0xFFF18E28),
            primary: true,
            onTap: () => _openCreateSheet(context, ref),
          ),
          const SizedBox(height: 14),
          _ActionCard(
            icon: Icons.sync_problem_outlined,
            title: 'Voir les feuilles non synchronisees',
            subtitle: 'Ouvrir la liste locale des feuilles en attente de synchronisation.',
            accent: const Color(0xFF2457C5),
            badge: count == null || count == 0
                ? null
                : count == 1
                    ? '1 feuille en attente'
                    : '$count feuilles en attente',
            onTap: () => _openPendingSheets(context),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF8E1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0E4BC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 18,
                  color: Color(0xFFF18E28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos donnees restent enregistrees sur la tablette jusqu\'a la synchronisation.',
                    style: TextStyle(
                      color: const Color(0xFF69758C).withValues(alpha: 0.95),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.badge,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: primary ? Colors.white : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: primary ? 0.28 : 0.14),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: primary ? accent : accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: primary
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: primary ? const Color(0xFF13233F) : accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18243E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF69758C),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            color: accent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
