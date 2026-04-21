import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'materiel_form_screen.dart';

class _StaffLogDraft {
  _StaffLogDraft({String initialStart = '00:00', String initialEnd = ''}) {
    hDebut.text = initialStart;
    hFin.text = initialEnd;
  }

  _StaffLogDraft.fromReportDraft(ReportStaffLogDraft draft) {
    employeNom.text = draft.employeNom;
    employeeOdooId = draft.employeeOdooId;
    fonction.text = draft.fonction;
    hDebut.text = draft.hDebut;
    hFin.text = draft.hFin;
    total.text = draft.total;
    obs.text = draft.obs;
    isAbsent = draft.isAbsent;
  }

  final TextEditingController employeNom = TextEditingController();
  final TextEditingController fonction = TextEditingController();
  final TextEditingController hDebut = TextEditingController();
  final TextEditingController hFin = TextEditingController();
  final TextEditingController total = TextEditingController();
  final TextEditingController obs = TextEditingController();
  int? employeeOdooId;
  bool isAbsent = false;

  ReportStaffLogDraft toReportDraft() {
    return ReportStaffLogDraft(
      employeNom: employeNom.text,
      employeeOdooId: employeeOdooId,
      fonction: fonction.text,
      hDebut: hDebut.text,
      hFin: hFin.text,
      total: total.text,
      obs: obs.text,
      isAbsent: isAbsent,
    );
  }

  void dispose() {
    employeNom.dispose();
    fonction.dispose();
    hDebut.dispose();
    hFin.dispose();
    total.dispose();
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
  final ScrollController _scrollController = ScrollController();
  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadEmployees);
  }

  @override
  void dispose() {
    _persistDraft();
    _scrollController.dispose();
    for (final log in _staffLogs) {
      log.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final db = ref.read(appDatabaseProvider);
    final employees = await db.getAllEmployees();
    if (!mounted) {
      return;
    }

    employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final reportDraft = ref.read(reportDraftProvider);

    setState(() {
      _employees = employees;
      if (_staffLogs.isEmpty && reportDraft.staffLogs.isNotEmpty) {
        _staffLogs.addAll(reportDraft.staffLogs.map(_StaffLogDraft.fromReportDraft));
      }
    });
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setStaffLogs(
          _staffLogs.map((log) => log.toReportDraft()).toList(),
        );
  }

  Employee? _findEmployeeByName(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final employee in _employees) {
      if (employee.name.trim().toLowerCase() == normalized) {
        return employee;
      }
    }
    return null;
  }

  void _syncEmployeeFromName(_StaffLogDraft log) {
    final employee = _findEmployeeByName(log.employeNom.text);
    log.employeeOdooId = employee?.odooId;
    log.fonction.text = employee?.jobName ?? '';
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

  String _formatDuration(double? value) {
    if (value == null) {
      return '';
    }

    final totalMinutes = (value * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _recomputeTotal(_StaffLogDraft log) {
    final start = _parseHour(log.hDebut.text);
    final end = _parseHour(log.hFin.text);
    if (start == null || end == null) {
      log.total.text = '';
      return;
    }

    final duration = end >= start ? end - start : (end + 24.0) - start;
    log.total.text = _formatDuration(duration);
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

  String _projectStartHour() {
    return _formatDecimalHour(_shiftStartValue());
  }

  String _projectEndHour() {
    return _formatDecimalHour(_shiftEndValue() % 24.0);
  }

  _StaffLogDraft _createStaffLog() {
    final log = _StaffLogDraft(
      initialStart: _projectStartHour(),
      initialEnd: _projectEndHour(),
    );
    _recomputeTotal(log);
    return log;
  }

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


  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _addLog() {
    setState(() {
      _staffLogs.add(_createStaffLog());
    });
    _persistDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _removeLog(int index) {
    setState(() {
      final removed = _staffLogs.removeAt(index);
      removed.dispose();
    });
    _persistDraft();
  }

  void _showTimeSpinner(
    BuildContext context,
    TextEditingController controller,
    VoidCallback afterChange,
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
                      .map(
                        (time) => Center(
                          child: Text(
                            time,
                            style: const TextStyle(fontSize: 20),
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

  BoxDecoration _fieldDecoration({required bool isReadOnly}) {
    return BoxDecoration(
      color: isReadOnly ? const Color(0xFFF3F4F6) : Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildStandardInput(
    String label,
    TextEditingController controller, {
    bool isReadOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(isReadOnly: isReadOnly),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: isReadOnly,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontSize: 13,
                      color: isReadOnly ? Colors.grey : const Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeAutocomplete(_StaffLogDraft log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nom',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Autocomplete<Employee>(
          displayStringForOption: (option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<Employee>.empty();
            }
            return _employees.where((employee) {
              final name = employee.name.toLowerCase();
              return name.contains(query);
            });
          },
          onSelected: (employee) {
            setState(() {
              log.employeNom.text = employee.name;
              log.employeeOdooId = employee.odooId;
              log.fonction.text = employee.jobName ?? '';
            });
            _persistDraft();
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            if (textEditingController.text != log.employeNom.text) {
              textEditingController.value = log.employeNom.value;
            }

            return Container(
              decoration: _fieldDecoration(isReadOnly: false),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, color: Colors.red),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onSubmitted: (_) => onFieldSubmitted(),
                        onChanged: (_) {
                          log.employeNom.value = textEditingController.value;
                          setState(() {
                            _syncEmployeeFromName(log);
                          });
                          _persistDraft();
                        },
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un employe',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220, minWidth: 280),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final employee = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(employee.name),
                        subtitle: employee.jobName == null || employee.jobName!.trim().isEmpty
                            ? null
                            : Text(employee.jobName!),
                        onTap: () => onSelected(employee),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpinnerInput(
    String label,
    TextEditingController controller,
    VoidCallback afterChange,
    List<String> allowedTimes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showTimeSpinner(context, controller, afterChange, allowedTimes),
          child: AbsorbPointer(
            child: Container(
              decoration: _fieldDecoration(isReadOnly: false),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, color: Colors.red),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                        decoration: const InputDecoration(
                          hintText: '--:--',
                          suffixIcon: Icon(Icons.access_time, size: 16, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, Color color, IconData icon, {required bool isLeading, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLeading) Icon(icon, color: Colors.white, size: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            if (!isLeading) ...[
              const SizedBox(width: 4),
              Icon(icon, color: Colors.white, size: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(int index) {
    final log = _staffLogs[index];
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EMPLOYE #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 22),
                  onPressed: () => _removeLog(index),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEmployeeAutocomplete(log),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpinnerInput(
                        'H. Debut',
                        log.hDebut,
                        () => _recomputeTotal(log),
                        _allowedStartTimesFor(log),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSpinnerInput(
                        'H. Fin',
                        log.hFin,
                        () => _recomputeTotal(log),
                        _allowedEndTimesFor(log),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildStandardInput(
                        'Observations (Obs)',
                        log.obs,
                        onChanged: (_) => _persistDraft(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: log.isAbsent,
                            onChanged: (val) {
                              setState(() {
                                log.isAbsent = val ?? false;
                              });
                              _persistDraft();
                            },
                          ),
                          const Text(
                            'Absent',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
            flex: 1,
            child: _buildNavButton(
              'Precedent',
              const Color(0xFF374151),
              Icons.arrow_back_ios,
              isLeading: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: _addLog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C7C9).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFF00C7C9), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle, color: Color(0xFF00C7C9), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter une ligne',
                      style: TextStyle(color: Color(0xFF00C7C9), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _buildNavButton(
              'Suivant',
              const Color(0xFF374151),
              Icons.arrow_forward_ios,
              isLeading: false,
              onTap: () {
                _persistDraft();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DrillingConsumableForm(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'PERSONNEL',
          style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _staffLogs.length + 1,
        itemBuilder: (context, index) {
          if (index == _staffLogs.length) {
            return _buildActionButtons();
          }
          return _buildStaffCard(index);
        },
      ),
    );
  }
}
