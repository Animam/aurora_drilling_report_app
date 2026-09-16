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

  Future<void> _loadUserInfo() async {
    final scope = await ref.read(mobileScopeCacheProvider).readScope();
    if (!mounted || scope == null) {
      return;
    }
    setState(() {
      _employeeName = scope['employee_name']?.toString();
      _companyName = scope['company_name']?.toString();
    });
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
      appBar: AppBar(
        // title: const Text('Accueil'),
        actions: [
          // Chip profil : avatar + nom + prenom. Cliquable pour voir plus de details.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showUserInfo(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF13233F),
                      child: Icon(Icons.person_rounded, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        _employeeName?.isNotEmpty == true ? _employeeName! : 'Utilisateur',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF18243E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Se deconnecter',
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13233F),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rapport De Forage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ActionCard(
                    icon: Icons.note_add_outlined,
                    title: 'Creer une nouvelle feuille',
                    subtitle: 'Demarrer une nouvelle saisie locale.',
                    accent: const Color(0xFFF18E28),
                    onTap: () => _openCreateSheet(context, ref),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.sync_problem_outlined,
                    title: 'Voir les feuilles non synchronisees',
                    subtitle: 'Ouvrir la liste locale des feuilles en attente de synchronisation.',
                    accent: const Color(0xFF2457C5),
                    onTap: () => _openPendingSheets(context),
                  ),
                ],
              ),
            ),
          ),
        ),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18243E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF69758C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
