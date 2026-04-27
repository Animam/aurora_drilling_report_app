import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import 'recap_screen.dart';
import 'registration_screen.dart';

class FeuilleListScreen extends ConsumerStatefulWidget {
  const FeuilleListScreen({
    super.key,
    this.initialMessage,
    this.initialMessageIsError = false,
  });

  final String? initialMessage;
  final bool initialMessageIsError;

  @override
  ConsumerState<FeuilleListScreen> createState() => _FeuilleListScreenState();
}

class _FeuilleListScreenState extends ConsumerState<FeuilleListScreen> {
  bool _initialMessageShown = false;
  List<Feuille> _items = [];
  Map<int, String> _equipmentNames = {};
  Map<int, String> _locationNames = {};
  int? _openingFeuilleLocalId;

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final data = await db.getPendingFeuilles();
    // final projects = await db.getAllProjects();
    final equipments = await db.getAllEquipments();
    final locations = await db.getAllLocations();

    if (!mounted) {
      return;
    }

    setState(() {
      _items = data;
      // _projectNames = {for (final item in projects) item.odooId: item.name};
      _equipmentNames = {for (final item in equipments) item.odooId: item.name};
      _locationNames = {for (final item in locations) item.odooId: item.name};
    });
  }

  String _formatDate(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return trimmed;
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeuilleCard(Feuille item) {
    final foreuseName =
        item.foreuseOdooId != null ? (_equipmentNames[item.foreuseOdooId!] ?? '--') : '--';
    final locationName =
        item.locationOdooId != null ? (_locationNames[item.locationOdooId!] ?? '--') : '--';
    final isOpening = _openingFeuilleLocalId == item.localId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: isOpening
            ? null
            : () async {
                setState(() {
                  _openingFeuilleLocalId = item.localId;
                });

                try {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecapScreen(
                        feuilleLocalId: item.localId,
                        openedFromList: true,
                      ),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _openingFeuilleLocalId = null;
                    });
                    _load();
                  }
                }
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF27456F), Color(0xFF172D4D)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF13233F).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isOpening)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoChip(Icons.badge_outlined, item.quart),
                    _buildInfoChip(Icons.precision_manufacturing_outlined, foreuseName),
                    _buildInfoChip(Icons.location_on_outlined, locationName),
                    _buildInfoChip(Icons.calendar_today_outlined, _formatDate(item.dateForage)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _load();
      _showInitialMessageIfNeeded();
    });
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
        title: const Text('Feuilles non synchronisees'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF18E28),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ref.read(reportDraftProvider.notifier).reset();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegistrationScreen()),
          );
          _load();
        },
        backgroundColor: const Color(0xFFF18E28),
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
          ),
        ),
        child: _items.isEmpty
            ? const Center(child: Text('Aucune feuille non synchronisee'))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 6, bottom: 24),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildFeuilleCard(_items[index]),
              ),
      ),
    );
  }
}
