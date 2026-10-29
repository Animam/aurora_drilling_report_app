import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import 'recap_screen.dart';
import 'registration_screen.dart';

/// Nature geologique deduite du libelle de la tache de forage.
enum DrillingMaterialType { sapro, rock, other }

/// Metrage d'une ligne : total_dim en priorite, sinon l'ecart from/to.
double ligneMeters(FeuilleLigne ligne) {
  final total = ligne.totalDim;
  if (total != null) {
    return total.toDouble();
  }
  final from = ligne.fromDim;
  final to = ligne.toDim;
  if (from != null && to != null) {
    return (to - from).abs().toDouble();
  }
  return 0;
}

/// Classe une ligne de forage en SAPRO / ROCK a partir de la tache associee.
/// Si la tache n'est pas retrouvee par son id, on tente par son numero d'item,
/// puis on retombe sur le texte de la ligne.
DrillingMaterialType drillingMaterialTypeForLine({
  required FeuilleLigne ligne,
  required Map<int, Task> tasksById,
  required Map<String, Task> tasksByNumber,
}) {
  final task =
      (ligne.tacheOdooId != null ? tasksById[ligne.tacheOdooId!] : null) ??
      tasksByNumber[ligne.item.trim().toLowerCase()];

  final haystack = [
    task?.libelle ?? '',
    task?.numItem ?? '',
    task?.typeActivite ?? '',
    ligne.item,
  ].join(' ').toUpperCase();

  if (haystack.contains('SAPRO') || haystack.contains('SAPROLITE')) {
    return DrillingMaterialType.sapro;
  }
  if (haystack.contains('ROCK') ||
      haystack.contains('ROCHE') ||
      haystack.contains('ROCHER')) {
    return DrillingMaterialType.rock;
  }
  return DrillingMaterialType.other;
}

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
  static const Color _accentOrange = Color(0xFFF18E28);
  static const Color _designNavy = Color(0xFF13233F);
  static const Color _textDark = Color(0xFF18243E);
  static const Color _muted = Color(0xFF69758C);
  static const Color _border = Color(0xFFD7DFEA);
  static const Color _softBg = Color(0xFFFDF8E1);

  bool _initialMessageShown = false;
  List<Feuille> _items = [];
  Map<int, String> _equipmentNames = {};
  Map<int, String> _locationNames = {};
  Map<int, double> _meterTotals = {};
  Map<int, double> _saproTotals = {};
  Map<int, double> _rockTotals = {};
  int? _openingFeuilleLocalId;

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final data = await db.getPendingFeuilles();
    // final projects = await db.getAllProjects();
    final equipments = await db.getAllEquipments();
    final locations = await db.getAllLocations();
    final tasks = await db.getAllTasks();
    final tasksById = <int, Task>{for (final task in tasks) task.odooId: task};
    final tasksByNumber = <String, Task>{
      for (final task in tasks)
        if ((task.numItem ?? '').trim().isNotEmpty)
          task.numItem!.trim().toLowerCase(): task,
    };
    final meterTotals = <int, double>{};
    final saproTotals = <int, double>{};
    final rockTotals = <int, double>{};

    for (final feuille in data) {
      final lignes = await db.getLignesByFeuille(feuille.localId);
      var total = 0.0;
      var sapro = 0.0;
      var rock = 0.0;
      for (final ligne in lignes) {
        final meters = ligneMeters(ligne);
        total += meters;
        final type = drillingMaterialTypeForLine(
          ligne: ligne,
          tasksById: tasksById,
          tasksByNumber: tasksByNumber,
        );
        if (type == DrillingMaterialType.sapro) {
          sapro += meters;
        } else if (type == DrillingMaterialType.rock) {
          rock += meters;
        }
      }
      meterTotals[feuille.localId] = total;
      saproTotals[feuille.localId] = sapro;
      rockTotals[feuille.localId] = rock;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _items = data;
      // _projectNames = {for (final item in projects) item.odooId: item.name};
      _equipmentNames = {for (final item in equipments) item.odooId: item.name};
      _locationNames = {for (final item in locations) item.odooId: item.name};
      _meterTotals = meterTotals;
      _saproTotals = saproTotals;
      _rockTotals = rockTotals;
    });
  }

  String _formatMeters(double value) {
    final rounded = value.roundToDouble();
    return value == rounded ? value.toInt().toString() : value.toString();
  }

  String _formatDate(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return trimmed;
  }

  Widget _buildInfoChip(IconData icon, String label, {required bool isDraft}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDraft
            ? const Color(0xFFB3261E).withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDraft
              ? const Color(0xFFB3261E).withValues(alpha: 0.35)
              : _border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDraft ? const Color(0xFFB3261E) : _accentOrange,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDraft ? const Color(0xFF7C1C13) : _textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterStat({
    required String label,
    required double meters,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${_formatMeters(meters)} m',
                maxLines: 1,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFeuille(int feuilleLocalId) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteFeuilleCascade(feuilleLocalId);
    await _load();
  }

  Future<void> _confirmDeleteFeuille(Feuille item) async {
    final isDraft = item.syncStatus == 'draft';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Supprimer la feuille',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isDraft
                ? 'Ce brouillon sera definitivement supprime de cet appareil. '
                      'Cette action est irreversible.'
                : 'Cette feuille en attente de synchronisation sera definitivement '
                      'supprimee de cet appareil et ne sera jamais synchronisee. '
                      'Cette action est irreversible.',
            style: const TextStyle(color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: _designNavy),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Supprimer'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _deleteFeuille(item.localId);
    }
  }

  Widget _buildFeuilleCard(Feuille item) {
    final foreuseName = item.foreuseOdooId != null
        ? (_equipmentNames[item.foreuseOdooId!] ?? '--')
        : '--';
    final locationName = item.locationOdooId != null
        ? (_locationNames[item.locationOdooId!] ?? '--')
        : '--';
    final isOpening = _openingFeuilleLocalId == item.localId;
    final isDraft = item.syncStatus == 'draft';
    final totalMeters = _meterTotals[item.localId] ?? 0.0;
    final saproMeters = _saproTotals[item.localId] ?? 0.0;
    final rockMeters = _rockTotals[item.localId] ?? 0.0;

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
            color: isDraft ? null : const Color(0xFFF1F3F5),
            gradient: isDraft
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF4F3), Colors.white],
                  )
                : null,
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F13233F),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDraft
                                ? const Color(
                                    0xFFB3261E,
                                  ).withValues(alpha: 0.12)
                                : _accentOrange.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: isDraft
                                ? const Color(0xFFB3261E)
                                : _accentOrange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDraft ? 'Brouillon' : 'Feuille en attente',
                              style: const TextStyle(
                                color: _textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.mobileUuid.isEmpty ? '--' : item.mobileUuid,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOpening)
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: _designNavy,
                            ),
                          )
                        else
                          Icon(Icons.chevron_right_rounded, color: _muted),
                        IconButton(
                          onPressed: isOpening
                              ? null
                              : () => _confirmDeleteFeuille(item),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: isDraft ? const Color(0xFFB3261E) : _muted,
                          ),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildInfoChip(
                      Icons.badge_outlined,
                      item.quart,
                      isDraft: isDraft,
                    ),
                    _buildInfoChip(
                      Icons.precision_manufacturing_outlined,
                      foreuseName,
                      isDraft: isDraft,
                    ),
                    _buildInfoChip(
                      Icons.location_on_outlined,
                      locationName,
                      isDraft: isDraft,
                    ),
                    _buildInfoChip(
                      Icons.calendar_today_outlined,
                      _formatDate(item.dateForage),
                      isDraft: isDraft,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildMeterStat(
                      label: 'TOTAL',
                      meters: totalMeters,
                      accent: _accentOrange,
                    ),
                    const SizedBox(width: 8),
                    _buildMeterStat(
                      label: 'SAPRO',
                      meters: saproMeters,
                      accent: const Color(0xFF0F9D8A),
                    ),
                    const SizedBox(width: 8),
                    _buildMeterStat(
                      label: 'ROCK',
                      meters: rockMeters,
                      accent: const Color(0xFF8B9BB4),
                    ),
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
        backgroundColor: _softBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 6,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Retour',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _designNavy,
              side: const BorderSide(color: Color(0xFFE3E8F0)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
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
                'Feuilles à synchroniser',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ref.read(reportDraftProvider.notifier).reset();
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const RegistrationScreen()));
          _load();
        },
        backgroundColor: _accentOrange,
        foregroundColor: _designNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FB), Color(0xFFF4F7FB)],
          ),
        ),
        child: _items.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _accentOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          size: 30,
                          color: _accentOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune feuille disponible',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crée une nouvelle feuille avec le bouton +',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _items.length,
                itemBuilder: (context, index) =>
                    _buildFeuilleCard(_items[index]),
              ),
      ),
    );
  }
}
