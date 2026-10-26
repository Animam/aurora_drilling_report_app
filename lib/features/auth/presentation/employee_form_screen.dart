import 'dart:math' as math;

import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'materiel_form_screen.dart';

class _StaffLogDraft {
  _StaffLogDraft({
    required this.employeeOdooId,
    required this.isAbsent,
    required this.showObservation,
    required String employeeName,
    required String functionName,
    required String startHour,
    required String endHour,
    String observation = '',
  }) {
    employeNom.text = employeeName;
    fonction.text = functionName;
    hDebut.text = startHour;
    hFin.text = endHour;
    obs.text = observation;
  }

  _StaffLogDraft.fromReportDraft(ReportStaffLogDraft draft) {
    employeNom.text = draft.employeNom;
    employeeOdooId = draft.employeeOdooId;
    fonction.text = draft.fonction;
    hDebut.text = draft.hDebut;
    hFin.text = draft.hFin;
    obs.text = draft.obs;
    isAbsent = draft.isAbsent;
    showObservation = draft.obs.trim().isNotEmpty;
  }

  final TextEditingController employeNom = TextEditingController();
  final TextEditingController fonction = TextEditingController();
  final TextEditingController hDebut = TextEditingController();
  final TextEditingController hFin = TextEditingController();
  final TextEditingController obs = TextEditingController();
  int? employeeOdooId;
  bool isAbsent = false;
  bool showObservation = false;

  ReportStaffLogDraft toReportDraft() {
    return ReportStaffLogDraft(
      employeNom: employeNom.text.trim(),
      employeeOdooId: employeeOdooId,
      fonction: fonction.text.trim(),
      hDebut: hDebut.text.trim(),
      hFin: hFin.text.trim(),
      total: '',
      obs: obs.text.trim(),
      isAbsent: isAbsent,
    );
  }

  void dispose() {
    employeNom.dispose();
    fonction.dispose();
    hDebut.dispose();
    hFin.dispose();
    obs.dispose();
  }
}

class DrillingStaffForm extends ConsumerStatefulWidget {
  const DrillingStaffForm({super.key});

  @override
  ConsumerState<DrillingStaffForm> createState() => _DrillingStaffFormState();
}

class _DrillingStaffFormState extends ConsumerState<DrillingStaffForm> {
  static const Color _accentOrange = Color(0xFFF18E28);
  static const Color _designNavy = Color(0xFF13233F);
  static const Color _designNavyLight = Color(0xFF1E3A5F);
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

  final List<_StaffLogDraft> _staffLogs = [];
  List<Employee> _availableEmployees = [];
  bool _loading = true;
  static const Map<String, Set<String>> _roleFilters = {
    'Superviseur': {'superviseur'},
    'Foreur': {'foreur'},
    'Aide Foreur': {'aide-foreur', 'aide foreur'},
    'Aprenti aide foreur': {'apprenti aide foreur', 'apprenti aide-foreur'},
    'Directeur': {'directeur de site'},
  };

  static const Set<String> _allowedJobs = {
    'superviseur',
    'foreur',
    'aide-foreur',
    'aide foreur',
    'apprenti aide foreur',
    'apprenti aide-foreur',
    'directeur de site',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadEmployees);
  }

  @override
  void dispose() {
    // Ne pas appeler _persistDraft() ici : il fait ref.read(...notifier), et ref
    // est deja invalide pendant finalizeTree -> StateError "Cannot use ref after
    // the widget was disposed". Le draft est deja persiste a chaque onChanged.
    for (final log in _staffLogs) {
      log.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final db = ref.read(appDatabaseProvider);
    final employees = (await db.getAllEmployees()).where((employee) {
      final jobName = (employee.jobName ?? '').trim().toLowerCase();
      return _allowedJobs.contains(jobName);
    }).toList();
    if (!mounted) {
      return;
    }

    employees.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    final reportDraft = ref.read(reportDraftProvider);

    setState(() {
      _availableEmployees = employees;
      _staffLogs.clear();
      if (reportDraft.staffLogs.isNotEmpty) {
        _staffLogs.addAll(
          reportDraft.staffLogs.map(_StaffLogDraft.fromReportDraft),
        );
      }
      _loading = false;
    });
    _persistDraft();
  }

  void _persistDraft() {
    if (!mounted) {
      return;
    }
    ref
        .read(reportDraftProvider.notifier)
        .setStaffLogs(
          _staffLogs.map((log) => log.toReportDraft()).toList(growable: false),
        );
    Future.microtask(_autoSaveStaffLogs);
  }

  Future<void> _autoSaveStaffLogs() async {
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
    final rows = _staffLogs
        .where((log) => log.employeeOdooId != null)
        .map(
          (log) => <String, dynamic>{
            'mobile_uuid': uuid.v4(),
            'employee_odoo_id': log.employeeOdooId!,
            'fonction': log.fonction.text.trim().isEmpty
                ? null
                : log.fonction.text.trim(),
            'observation': log.obs.text.trim().isEmpty
                ? null
                : log.obs.text.trim(),
            'date_emp': draft.dateText,
            'date_debut': log.hDebut.text.trim().isEmpty
                ? null
                : log.hDebut.text.trim(),
            'date_fin': log.hFin.text.trim().isEmpty
                ? null
                : log.hFin.text.trim(),
            'difference': null,
            'absent': log.isAbsent,
          },
        )
        .toList(growable: false);

    await ref
        .read(appDatabaseProvider)
        .replaceFeuilleEmployesDraft(
          feuilleLocalId: feuilleLocalId,
          rows: rows,
        );
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

  String _formatDecimalHour(double? value) {
    if (value == null) {
      return '';
    }
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

  String _formatMinutes(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hours = (normalized ~/ 60).toString().padLeft(2, '0');
    final minutes = (normalized % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  List<String> _buildAllowedTimes({
    required double minValue,
    required double maxValue,
  }) {
    final minMinutes = (_normalizeForShift(minValue) * 60).round();
    final maxMinutes = (_normalizeForShift(maxValue) * 60).round();
    if (maxMinutes < minMinutes) {
      return const [];
    }

    final values = <String>[];
    final firstAllowedMinute = ((minMinutes + 4) ~/ 5) * 5;

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

  List<String> _allowedStartTimesFor(_StaffLogDraft log) {
    final currentEnd = _parseHour(log.hFin.text);
    final maxValue = currentEnd == null
        ? _shiftEndValue()
        : _normalizeForShift(currentEnd);
    return _buildAllowedTimes(minValue: _shiftStartValue(), maxValue: maxValue);
  }

  List<String> _allowedEndTimesFor(_StaffLogDraft log) {
    final currentStart = _parseHour(log.hDebut.text);
    final minValue = currentStart == null
        ? _shiftStartValue()
        : _normalizeForShift(currentStart);
    return _buildAllowedTimes(minValue: minValue, maxValue: _shiftEndValue());
  }

  void _showTimeSpinner(
    BuildContext context,
    TextEditingController controller,
    List<String> allowedTimes,
    VoidCallback afterChange,
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
                          afterChange();
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

  bool _isEmployeeAlreadyAdded(int employeeOdooId) {
    return _staffLogs.any((log) => log.employeeOdooId == employeeOdooId);
  }

  Future<void> _openAddEmployeeDialog({String? roleLabel}) async {
    final roleFilter = roleLabel == null ? null : _roleFilters[roleLabel];
    final selectedEmployee = await showDialog<Employee>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var filtered = _availableEmployees
            .where((employee) {
              if (_isEmployeeAlreadyAdded(employee.odooId)) {
                return false;
              }
              if (roleFilter == null) {
                return true;
              }
              final jobName = (employee.jobName ?? '').trim().toLowerCase();
              return roleFilter.contains(jobName);
            })
            .toList(growable: false);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applyFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                filtered = _availableEmployees
                    .where((employee) {
                      if (_isEmployeeAlreadyAdded(employee.odooId)) {
                        return false;
                      }
                      final jobName = (employee.jobName ?? '')
                          .trim()
                          .toLowerCase();
                      if (roleFilter != null && !roleFilter.contains(jobName)) {
                        return false;
                      }
                      if (normalized.isEmpty) {
                        return true;
                      }
                      final haystack =
                          '${employee.name} ${employee.jobName ?? ''}'
                              .toLowerCase();
                      return haystack.contains(normalized);
                    })
                    .toList(growable: false);
              });
            }

            // Dialog bulletproof responsive : SingleChildScrollView englobe
            // TOUT (titre + search + liste + fermer). La liste a une hauteur
            // bornee et virtualisee (jamais de freeze meme avec 1000+ employes).
            // Si l'espace est trop petit → tout scrolle → aucun overflow.
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
                constraints: const BoxConstraints(maxWidth: 520),
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
                                Icons.person_add_alt_1_outlined,
                                size: 20,
                                color: _accentOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                roleLabel == null
                                    ? 'Ajouter un employe'
                                    : 'Ajouter un employe - $roleLabel',
                                style: const TextStyle(
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
                            hintText: 'Rechercher un employe',
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
                                'Aucun employe disponible.',
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
                                final employee = filtered[index];
                                return Material(
                                  color: _fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                  child: ListTile(
                                    dense: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      employee.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    subtitle: Text(
                                      employee.jobName ??
                                          'Fonction non renseignee',
                                      style: const TextStyle(color: _muted),
                                    ),
                                    trailing: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: _accentOrange,
                                    ),
                                    onTap: () =>
                                        Navigator.pop(context, employee),
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

    if (selectedEmployee == null) {
      return;
    }

    setState(() {
      _staffLogs.add(
        _StaffLogDraft(
          employeeOdooId: selectedEmployee.odooId,
          isAbsent: false,
          showObservation: false,
          employeeName: selectedEmployee.name,
          functionName: selectedEmployee.jobName ?? '',
          startHour: _projectStartHour(),
          endHour: _projectEndHour(),
        ),
      );
    });
    _persistDraft();
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required List<String> allowedTimes,
    required VoidCallback afterChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () =>
              _showTimeSpinner(context, controller, allowedTimes, afterChange),
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

  Widget _buildObservationField(_StaffLogDraft log) {
    return TextField(
      controller: log.obs,
      onChanged: (_) => _persistDraft(),
      minLines: 2,
      maxLines: 3,
      style: const TextStyle(color: _textDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Ajouter une observation si necessaire',
        hintStyle: const TextStyle(color: _muted),
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accentOrange, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildStaffCard(int index) {
    final log = _staffLogs[index];
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
                        log.employeNom.text.trim().isEmpty
                            ? 'Employe sans nom'
                            : log.employeNom.text.trim(),
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
                            Icons.badge_outlined,
                            size: 15,
                            color: _accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              log.fonction.text.trim().isEmpty
                                  ? 'Fonction non renseignee'
                                  : log.fonction.text.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final removed = _staffLogs.removeAt(index);
                      removed.dispose();
                    });
                    _persistDraft();
                  },
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _fieldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: log.isAbsent,
                        activeColor: _accentOrange,
                        checkColor: _designNavy,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (value) {
                          setState(() {
                            log.isAbsent = value ?? false;
                          });
                          _persistDraft();
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Absent',
                        style: TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'H. Debut',
                    controller: log.hDebut,
                    allowedTimes: _allowedStartTimesFor(log),
                    afterChange: () => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    label: 'H. Fin',
                    controller: log.hFin,
                    allowedTimes: _allowedEndTimesFor(log),
                    afterChange: () => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () {
                setState(() {
                  log.showObservation = !log.showObservation;
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
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: _accentOrange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log.obs.text.trim().isEmpty
                            ? 'Ajouter une observation'
                            : 'Observation renseignee',
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      log.showObservation
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _muted,
                    ),
                  ],
                ),
              ),
            ),
            if (log.showObservation) ...[
              const SizedBox(height: 12),
              _buildObservationField(log),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterButtons() {
    final roles = _roleFilters.keys.toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        // 5 roles repartis sur 2 lignes : 3 en haut, 2 en bas.
        const columns = 3;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: roles
              .map(
                (roleLabel) => SizedBox(
                  width: itemWidth,
                  child: FilledButton(
                    onPressed: () =>
                        _openAddEmployeeDialog(roleLabel: roleLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentOrange,
                      foregroundColor: _designNavy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      roleLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildTopActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_designNavy, _designNavyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
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
                  color: _accentOrange,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Equipe / Personnel du shift',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_staffLogs.length} employe(s) selectionne(s) pour cette feuille.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Horaires par defaut : ${_projectStartHour()} - ${_projectEndHour()}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'AJOUT RAPIDE PAR ROLE',
            style: TextStyle(
              color: _accentOrange,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleFilterButtons(),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DrillingConsumableForm(),
                  ),
                );
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
                'Personnel',
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
                      Icons.groups_2_outlined,
                      size: 14,
                      color: _designNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_staffLogs.length}',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accentOrange))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopActions(),
                        const SizedBox(height: 18),
                        if (_staffLogs.isEmpty)
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
                                    color: _accentOrange.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.groups_2_outlined,
                                    size: 30,
                                    color: _accentOrange,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun employe selectionne',
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Ajoute seulement les personnes presentes sur cette feuille.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: _muted),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_staffLogs.length, _buildStaffCard),
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
