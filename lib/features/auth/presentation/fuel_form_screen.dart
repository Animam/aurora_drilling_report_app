import 'dart:math' as math;

import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'recap_screen.dart';

class _FuelLogDraft {
  _FuelLogDraft({
    required this.showRavitaillement,
    this.equipmentOdooId,
    String equipement = '',
    String qtyFuel = '0',
    String hDebut = '',
    String hFin = '',
    String hDebutRavi = '',
    String hFinRavi = '',
  }) {
    equipementId.text = equipement;
    this.qtyFuel.text = qtyFuel;
    this.hDebut.text = hDebut;
    this.hFin.text = hFin;
    this.hDebutRavi.text = hDebutRavi;
    this.hFinRavi.text = hFinRavi;
  }

  _FuelLogDraft.fromReportDraft(ReportFuelLogDraft draft)
    : equipmentOdooId = draft.equipmentOdooId,
      showRavitaillement =
          draft.hDebutRavi.trim().isNotEmpty ||
          draft.hFinRavi.trim().isNotEmpty {
    equipementId.text = draft.equipement;
    qtyFuel.text = draft.qtyFuel;
    hDebut.text = draft.hDebut;
    hFin.text = draft.hFin;
    hDebutRavi.text = draft.hDebutRavi;
    hFinRavi.text = draft.hFinRavi;
  }

  int? equipmentOdooId;
  bool showRavitaillement;
  final TextEditingController equipementId = TextEditingController();
  final TextEditingController qtyFuel = TextEditingController(text: '0');
  final TextEditingController hDebut = TextEditingController();
  final TextEditingController hFin = TextEditingController();
  final TextEditingController hDebutRavi = TextEditingController();
  final TextEditingController hFinRavi = TextEditingController();

  ReportFuelLogDraft toReportDraft() {
    return ReportFuelLogDraft(
      equipmentOdooId: equipmentOdooId,
      equipement: equipementId.text.trim(),
      qtyFuel: qtyFuel.text.trim(),
      hDebut: hDebut.text.trim(),
      hFin: hFin.text.trim(),
      hDebutRavi: hDebutRavi.text.trim(),
      hFinRavi: hFinRavi.text.trim(),
    );
  }

  void applyEquipment(Equipment equipment) {
    equipmentOdooId = equipment.odooId;
    equipementId.text = equipment.name;
  }

  void dispose() {
    equipementId.dispose();
    qtyFuel.dispose();
    hDebut.dispose();
    hFin.dispose();
    hDebutRavi.dispose();
    hFinRavi.dispose();
  }
}

class DrillingFuelForm extends ConsumerStatefulWidget {
  const DrillingFuelForm({super.key});

  @override
  ConsumerState<DrillingFuelForm> createState() => _DrillingFuelFormState();
}

class _DrillingFuelFormState extends ConsumerState<DrillingFuelForm> {
  static const Color _accentOrange = Color(0xFFF18E28);
  static const Color _designNavy = Color(0xFF13233F);
  static const Color _textDark = Color(0xFF18243E);
  static const Color _muted = Color(0xFF69758C);
  static const Color _border = Color(0xFFD7DFEA);
  static const Color _softBg = Color(0xFFFDF8E1);
  static const Color _fieldBg = Color(0xFFF3F6FB);

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  final List<_FuelLogDraft> _items = [];
  List<Equipment> _availableEquipments = [];
  bool _loadingReferences = true;
  String? _referenceError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    if (draft.fuelLogs.isNotEmpty) {
      _items.addAll(draft.fuelLogs.map(_FuelLogDraft.fromReportDraft));
    }
    Future.microtask(_loadEquipmentReferences);
  }

  @override
  void dispose() {
    // Ne pas appeler _persistDraft() ici : il fait ref.read(...notifier), et ref
    // est deja invalide pendant finalizeTree -> StateError "Cannot use ref after
    // the widget was disposed". Le draft est deja persiste a chaque onChanged.
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEquipmentReferences() async {
    setState(() {
      _loadingReferences = true;
      _referenceError = null;
    });

    try {
      final draft = ref.read(reportDraftProvider);
      final db = ref.read(appDatabaseProvider);
      final allEquipments = await db.getAllEquipments();
      final projectId = draft.projectOdooId;
      final filtered =
          allEquipments.where((equipment) {
            final equipmentProjectId = equipment.projectOdooId;
            return equipmentProjectId == null ||
                equipmentProjectId == projectId;
          }).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _availableEquipments = filtered;
        _loadingReferences = false;
      });
      _ensureSelectedForeuseRow();
      _refreshDraftRowsFromReferences();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingReferences = false;
        _referenceError = e.toString();
      });
    }
  }

  void _ensureSelectedForeuseRow() {
    final draft = ref.read(reportDraftProvider);
    final foreuseId = draft.foreuseOdooId;
    if (foreuseId == null) {
      return;
    }

    Equipment? foreuse;
    for (final equipment in _availableEquipments) {
      if (equipment.odooId == foreuseId) {
        foreuse = equipment;
        break;
      }
    }
    if (foreuse == null) {
      return;
    }

    for (final item in _items) {
      if (item.equipmentOdooId == foreuse.odooId) {
        item.applyEquipment(foreuse);
        return;
      }
    }

    final row = _FuelLogDraft(
      showRavitaillement: false,
      equipmentOdooId: foreuse.odooId,
      equipement: foreuse.name,
      hDebut: _projectStartHour(),
      hFin: _projectEndHour(),
    );
    if (_items.isEmpty) {
      _items.add(row);
    } else {
      _items.insert(0, row);
    }
    _persistDraft();
  }

  void _refreshDraftRowsFromReferences() {
    var changed = false;
    for (final item in _items) {
      final match = _findEquipmentMatch(
        equipmentOdooId: item.equipmentOdooId,
        name: item.equipementId.text,
      );
      if (match == null) {
        continue;
      }
      if (item.equipmentOdooId != match.odooId ||
          item.equipementId.text != match.name) {
        item.applyEquipment(match);
        changed = true;
      }
    }
    if (changed) {
      _persistDraft();
    }
  }

  Equipment? _findEquipmentMatch({int? equipmentOdooId, String? name}) {
    if (equipmentOdooId != null) {
      for (final equipment in _availableEquipments) {
        if (equipment.odooId == equipmentOdooId) {
          return equipment;
        }
      }
    }

    final normalized = (name ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final equipment in _availableEquipments) {
      if (equipment.name.trim().toLowerCase() == normalized) {
        return equipment;
      }
    }
    return null;
  }

  void _persistDraft() {
    if (!mounted) {
      return;
    }
    ref
        .read(reportDraftProvider.notifier)
        .setFuelLogs(
          _items.map((item) => item.toReportDraft()).toList(growable: false),
        );
    Future.microtask(_autoSaveFuelLogs);
  }

  Future<void> _autoSaveFuelLogs() async {
    // Le microtask planifie par _persistDraft peut s'executer apres la
    // destruction de l'ecran : ref n'est plus utilisable a ce moment-la.
    if (!mounted) {
      return;
    }
    final draft = ref.read(reportDraftProvider);
    final feuilleLocalId = draft.currentFeuilleLocalId;
    if (feuilleLocalId == null) {
      return;
    }

    final uuid = const Uuid();
    final rows = _items
        .where((item) => item.equipmentOdooId != null)
        .map(
          (item) => <String, dynamic>{
            'mobile_uuid': uuid.v4(),
            'compresseur_odoo_id': item.equipmentOdooId,
            'qyt_fuel': double.tryParse(item.qtyFuel.text.trim()) ?? 0.0,
            'date_d_equi': _parseHour(item.hDebut.text.trim()),
            'date_f_equi': _parseHour(item.hFin.text.trim()),
            'date_d_ravi': _parseHour(item.hDebutRavi.text.trim()),
            'date_f_ravi': _parseHour(item.hFinRavi.text.trim()),
          },
        )
        .toList(growable: false);

    await ref
        .read(appDatabaseProvider)
        .replaceFeuilleFuelsDraft(feuilleLocalId: feuilleLocalId, rows: rows);
  }

  bool _isEquipmentAlreadyAdded(int equipmentOdooId) {
    return _items.any((item) => item.equipmentOdooId == equipmentOdooId);
  }

  double? _parseHour(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parts = trimmed.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return hour + (minute / 60.0);
  }

  String _formatMinutes(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hours = (normalized ~/ 60).toString().padLeft(2, '0');
    final minutes = (normalized % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _formatDecimalHour(double value) {
    final totalMinutes = (value * 60).round();
    final hours = (totalMinutes ~/ 60) % 24;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  double _shiftStartValue() {
    final draft = ref.read(reportDraftProvider);
    if (draft.quart == 'Night/Nuit') {
      return draft.projectDateDN ?? 0.0;
    }
    return draft.projectDateDJ ?? 0.0;
  }

  double _shiftEndValue() {
    final draft = ref.read(reportDraftProvider);
    if (draft.quart == 'Night/Nuit') {
      final start = _shiftStartValue();
      final rawEnd = draft.projectDateDJ ?? start;
      return rawEnd <= start ? rawEnd + 24.0 : rawEnd;
    }
    return draft.projectDateDN ?? _shiftStartValue();
  }

  double _normalizeForShift(double value) {
    final draft = ref.read(reportDraftProvider);
    if (draft.quart != 'Night/Nuit') {
      return value;
    }
    final shiftStart = _shiftStartValue();
    return value < shiftStart ? value + 24.0 : value;
  }

  String _projectStartHour() => _formatDecimalHour(_shiftStartValue());

  String _projectEndHour() => _formatDecimalHour(_shiftEndValue() % 24.0);

  List<String> _buildAllowedTimes({
    required double minValue,
    required double maxValue,
  }) {
    final minMinutes = (_normalizeForShift(minValue) * 60).round();
    final maxMinutes = (_normalizeForShift(maxValue) * 60).round();
    if (maxMinutes < minMinutes) {
      return const [];
    }

    final firstAllowedMinute = ((minMinutes + 4) ~/ 5) * 5;
    final values = <String>[];

    if (firstAllowedMinute > minMinutes) {
      values.add(_formatMinutes(minMinutes));
    }
    for (var minute = firstAllowedMinute; minute <= maxMinutes; minute += 5) {
      values.add(_formatMinutes(minute));
    }

    final maxFormatted = _formatMinutes(maxMinutes);
    if (values.isEmpty || values.last != maxFormatted) {
      values.add(maxFormatted);
    }
    return values;
  }

  List<String> _allowedStartTimesFor(_FuelLogDraft item) {
    final currentEnd = _parseHour(item.hFin.text);
    final maxValue = currentEnd == null
        ? _shiftEndValue()
        : _normalizeForShift(currentEnd);
    return _buildAllowedTimes(minValue: _shiftStartValue(), maxValue: maxValue);
  }

  List<String> _allowedEndTimesFor(_FuelLogDraft item) {
    final currentStart = _parseHour(item.hDebut.text);
    final minValue = currentStart == null
        ? _shiftStartValue()
        : _normalizeForShift(currentStart);
    return _buildAllowedTimes(minValue: minValue, maxValue: _shiftEndValue());
  }

  List<String> _allowedFreeTimes() {
    return [
      for (var minute = 0; minute < 24 * 60; minute += 5)
        _formatMinutes(minute),
    ];
  }

  void _showTimeSpinner(
    BuildContext context,
    TextEditingController controller,
    List<String> allowedTimes,
  ) {
    if (allowedTimes.isEmpty) {
      return;
    }

    var selectedIndex = allowedTimes.indexOf(controller.text.trim());
    if (selectedIndex < 0) {
      selectedIndex = 0;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        final mq = MediaQuery.of(builder);
        // Hauteur adaptative : max 1/3 en portrait, clampe entre 240 et 380
        // pour rester utilisable en landscape.
        final targetHeight = (mq.size.height - mq.viewInsets.bottom) / 3;
        return Container(
          height: targetHeight.clamp(240.0, 380.0),
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: _fieldBg,
                  border: Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: _muted),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          controller.text = allowedTimes[selectedIndex];
                        });
                        _persistDraft();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _accentOrange,
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (value) {
                    selectedIndex = value;
                  },
                  children: allowedTimes
                      .map(
                        (time) => Center(
                          child: Text(
                            time,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddEquipmentDialog() async {
    final selectedEquipment = await showDialog<Equipment>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var filtered = _availableEquipments
            .where((equipment) => !_isEquipmentAlreadyAdded(equipment.odooId))
            .toList(growable: false);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applyFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                filtered = _availableEquipments
                    .where((equipment) {
                      if (_isEquipmentAlreadyAdded(equipment.odooId)) {
                        return false;
                      }
                      if (normalized.isEmpty) {
                        return true;
                      }
                      final haystack =
                          '${equipment.name} ${equipment.categoryName ?? ''}'
                              .toLowerCase();
                      return haystack.contains(normalized);
                    })
                    .toList(growable: false);
              });
            }

            // Dialog bulletproof responsive : SingleChildScrollView englobe
            // TOUT. La liste a une hauteur bornee et virtualisee → jamais
            // de freeze meme avec beaucoup d'equipements. En rotation paysage
            // + clavier ouvert, le tout devient scrollable → aucun overflow.
            final mq = MediaQuery.of(context);
            final keyboardOpen = mq.viewInsets.bottom > 0;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: keyboardOpen ? 8 : 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: mq.viewInsets.bottom.clamp(0.0, 32.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _accentOrange.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_box_outlined,
                                size: 20,
                                color: _accentOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Ajouter un equipement',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller,
                          onChanged: applyFilter,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un equipement',
                            hintStyle: const TextStyle(color: _muted),
                            prefixIcon: const Icon(Icons.search, color: _muted),
                            isDense: true,
                            filled: true,
                            fillColor: _fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _accentOrange,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Aucun equipement disponible.',
                                style: TextStyle(color: _muted),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: math.min(filtered.length * 72.0, 300.0),
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final equipment = filtered[index];
                                return Material(
                                  color: _fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                  child: ListTile(
                                    dense: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      equipment.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    subtitle: Text(
                                      equipment.categoryName?.isNotEmpty == true
                                          ? equipment.categoryName!
                                          : '--',
                                      style: const TextStyle(color: _muted),
                                    ),
                                    trailing: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: _accentOrange,
                                    ),
                                    onTap: () =>
                                        Navigator.pop(context, equipment),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: _designNavy,
                            ),
                            child: const Text('Fermer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedEquipment == null) {
      return;
    }

    setState(() {
      _items.add(
        _FuelLogDraft(
          showRavitaillement: false,
          equipmentOdooId: selectedEquipment.odooId,
          equipement: selectedEquipment.name,
          hDebut: _projectStartHour(),
          hFin: _projectEndHour(),
        ),
      );
    });
    _persistDraft();
  }

  void _removeItem(int index) {
    setState(() {
      final removed = _items.removeAt(index);
      removed.dispose();
    });
    _persistDraft();
  }

  void _updateQuantity(TextEditingController controller, int delta) {
    final currentVal = int.tryParse(controller.text) ?? 0;
    final newVal = currentVal + delta;
    if (newVal >= 0) {
      setState(() {
        controller.text = newVal.toString();
      });
      _persistDraft();
    }
  }

  void _addQuantityValue(TextEditingController controller, int value) {
    final currentVal = int.tryParse(controller.text) ?? 0;
    setState(() {
      controller.text = (currentVal + value).toString();
    });
    _persistDraft();
  }

  Widget _buildQuantityPresetButtons(_FuelLogDraft item) {
    const values = [5, 10, 100, 1000];
    return Row(
      children: values
          .map((value) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: value == values.last ? 0 : 8),
                child: OutlinedButton(
                  onPressed: () => _addQuantityValue(item.qtyFuel, value),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _accentOrange.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: _accentOrange.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: _designNavy,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: Text('$value'),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildReferenceStatus() {
    if (_loadingReferences) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LinearProgressIndicator(
          color: _accentOrange,
          backgroundColor: Color(0xFFF0E4BC),
        ),
      );
    }
    if (_referenceError != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          _referenceError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_availableEquipments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Aucun equipement auxiliaire charge pour ce projet. Rechargez le bootstrap.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuantityField(_FuelLogDraft item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.qtyFuel, -1),
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: _accentOrange,
            ),
            tooltip: 'Diminuer',
          ),
          Expanded(
            child: TextField(
              controller: item.qtyFuel,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _persistDraft(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.qtyFuel, 1),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: _accentOrange,
            ),
            tooltip: 'Augmenter',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required List<String> allowedTimes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showTimeSpinner(context, controller, allowedTimes),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.trim().isEmpty
                        ? '--:--'
                        : controller.text.trim(),
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: _accentOrange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelCard(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.equipementId.text.trim().isEmpty
                            ? 'Equipement non renseigne'
                            : item.equipementId.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station_outlined,
                            size: 15,
                            color: _accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.qtyFuel.text.trim().isEmpty ? '0' : item.qtyFuel.text.trim()} L',
                            style: const TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Supprimer',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _fieldBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Qty Fuel'),
            const SizedBox(height: 8),
            _buildQuantityPresetButtons(item),
            const SizedBox(height: 8),
            _buildQuantityField(item),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Heure. D',
                    controller: item.hDebut,
                    allowedTimes: _allowedStartTimesFor(item),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    label: 'Heure. F',
                    controller: item.hFin,
                    allowedTimes: _allowedEndTimesFor(item),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () {
                setState(() {
                  item.showRavitaillement = !item.showRavitaillement;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: _accentOrange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (item.hDebutRavi.text.trim().isEmpty &&
                                item.hFinRavi.text.trim().isEmpty)
                            ? 'Ajouter les heures de ravitaillement'
                            : 'Ravitaillement renseigne',
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      item.showRavitaillement
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _muted,
                    ),
                  ],
                ),
              ),
            ),
            if (item.showRavitaillement) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'H. Debut Ravi',
                      controller: item.hDebutRavi,
                      allowedTimes: _allowedFreeTimes(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      label: 'H. Fin Ravi',
                      controller: item.hFinRavi,
                      allowedTimes: _allowedFreeTimes(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2213233F),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SHIFT EN COURS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Equipement / Fuel du shift',
            style: TextStyle(
              color: _designNavy,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_items.length} equipement(s) selectionne(s) pour cette feuille.',
            style: TextStyle(color: _muted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _availableEquipments.isEmpty
                  ? null
                  : _openAddEquipmentDialog,
              icon: const Icon(Icons.add_box_outlined, size: 20),
              label: const Text('Ajouter un equipement'),
              style: FilledButton.styleFrom(
                backgroundColor: _accentOrange,
                foregroundColor: _designNavy,
                disabledBackgroundColor: _border,
                disabledForegroundColor: _muted,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Precedent'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _designNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                _persistDraft();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const RecapScreen()));
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Suivant'),
              style: FilledButton.styleFrom(
                backgroundColor: _accentOrange,
                foregroundColor: _designNavy,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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
                'Equipement',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _accentOrange,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_gas_station_outlined,
                      size: 14,
                      color: _designNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_items.length}',
                      style: const TextStyle(
                        color: _designNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReferenceStatus(),
                  _buildTopActions(),
                  const SizedBox(height: 18),
                  if (_items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _accentOrange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_gas_station_outlined,
                              size: 30,
                              color: _accentOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun equipement selectionne',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ajoute les equipements utilises sur cette feuille.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_items.length, _buildFuelCard),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
