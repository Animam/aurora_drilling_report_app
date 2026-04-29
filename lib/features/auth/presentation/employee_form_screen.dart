import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final List<_StaffLogDraft> _staffLogs = [];
  List<Employee> _availableEmployees = [];
  bool _loading = true;
  static const Set<String> _allowedJobs = {
    'superviseur',
    'foreur',
    'aide-foreur',
    'apprenti aide foreur',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadEmployees);
  }

  @override
  void dispose() {
    _persistDraft();
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

    employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final reportDraft = ref.read(reportDraftProvider);

    setState(() {
      _availableEmployees = employees;
      _staffLogs.clear();
      if (reportDraft.staffLogs.isNotEmpty) {
        _staffLogs.addAll(reportDraft.staffLogs.map(_StaffLogDraft.fromReportDraft));
      }
      _loading = false;
    });
    _persistDraft();
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setStaffLogs(
          _staffLogs.map((log) => log.toReportDraft()).toList(growable: false),
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

  List<String> _buildAllowedTimes({required double minValue, required double maxValue}) {
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
    final maxValue = currentEnd == null ? _shiftEndValue() : _normalizeForShift(currentEnd);
    return _buildAllowedTimes(minValue: _shiftStartValue(), maxValue: maxValue);
  }

  List<String> _allowedEndTimesFor(_StaffLogDraft log) {
    final currentStart = _parseHour(log.hDebut.text);
    final minValue = currentStart == null ? _shiftStartValue() : _normalizeForShift(currentStart);
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
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: const Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler', style: TextStyle(color: Colors.red)),
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
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (value) {
                    selectedIndex = value;
                  },
                  children: allowedTimes
                      .map((time) => Center(child: Text(time, style: const TextStyle(fontSize: 20))))
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

  Future<void> _openAddEmployeeDialog() async {
    final selectedEmployee = await showDialog<Employee>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var filtered = _availableEmployees
            .where((employee) => !_isEmployeeAlreadyAdded(employee.odooId))
            .toList(growable: false);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applyFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                filtered = _availableEmployees.where((employee) {
                  if (_isEmployeeAlreadyAdded(employee.odooId)) {
                    return false;
                  }
                  if (normalized.isEmpty) {
                    return true;
                  }
                  final haystack = '${employee.name} ${employee.jobName ?? ''}'.toLowerCase();
                  return haystack.contains(normalized);
                }).toList(growable: false);
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Ajouter un employe',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      onChanged: applyFilter,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un employe',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Aucun employe disponible.'),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final employee = filtered[index];
                            return Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(employee.jobName ?? 'Fonction non renseignee'),
                                trailing: const Icon(Icons.add_circle_outline_rounded),
                                onTap: () => Navigator.pop(context, employee),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showTimeSpinner(context, controller, allowedTimes, afterChange),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7DFEA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.trim().isEmpty ? '--:--' : controller.text.trim(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
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
      decoration: InputDecoration(
        hintText: 'Ajouter une observation si necessaire',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                        log.employeNom.text.trim().isEmpty ? 'Employe sans nom' : log.employeNom.text.trim(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.fonction.text.trim().isEmpty ? 'Fonction non renseignee' : log.fonction.text.trim(),
                        style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Supprimer',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: log.isAbsent,
                        onChanged: (value) {
                          setState(() {
                            log.isAbsent = value ?? false;
                          });
                          _persistDraft();
                        },
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Absent',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log.obs.text.trim().isEmpty ? 'Ajouter une observation' : 'Observation renseignee',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      log.showObservation ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: const Color(0xFF475569),
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

  Widget _buildTopActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipe du shift',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_staffLogs.length} employe(s) selectionne(s) pour cette feuille. Horaires par defaut: ${_projectStartHour()} - ${_projectEndHour()}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddEmployeeDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Ajouter un employe'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(vertical: 23),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              label: const Text('Precedent'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 23)
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
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: const Text('Suivant'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(vertical: 23),
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
        title: const Text(
          'Personnel',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.groups_2_outlined, size: 42, color: Color(0xFF64748B)),
                                SizedBox(height: 12),
                                Text(
                                  'Aucun employe selectionne',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ajoute seulement les personnes presentes sur cette feuille.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF64748B)),
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

