import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'employee_form_screen.dart';

class _TimeLogDraft {
  _TimeLogDraft({String initialStart = '00:00'}) {
    heureDebut.text = initialStart;
  }

  _TimeLogDraft.fromReportDraft(ReportTimeLogDraft draft) {
    heureDebut.text = draft.heureDebut;
    heureFin.text = draft.heureFin;
    codeTache.text = draft.codeTache;
    holeNo.text = draft.holeNo;
    fromDe.text = draft.fromDe;
    toA.text = draft.toA;
    total.text = draft.total;
    commentaire.text = draft.commentaire;
    distance.text = draft.distance;
    duree.text = draft.duree;
    selectedTaskOdooId = draft.selectedTaskOdooId;
  }

  final TextEditingController heureDebut = TextEditingController();
  final TextEditingController heureFin = TextEditingController();
  final TextEditingController codeTache = TextEditingController();
  final TextEditingController holeNo = TextEditingController();
  final TextEditingController fromDe = TextEditingController();
  final TextEditingController toA = TextEditingController();
  final TextEditingController total = TextEditingController();
  final TextEditingController commentaire = TextEditingController();
  final TextEditingController distance = TextEditingController();
  final TextEditingController duree = TextEditingController();
  int? selectedTaskOdooId;

  ReportTimeLogDraft toReportDraft() {
    return ReportTimeLogDraft(
      heureDebut: heureDebut.text,
      heureFin: heureFin.text,
      codeTache: codeTache.text,
      holeNo: holeNo.text,
      fromDe: fromDe.text,
      toA: toA.text,
      total: total.text,
      commentaire: commentaire.text,
      distance: distance.text,
      duree: duree.text,
      selectedTaskOdooId: selectedTaskOdooId,
    );
  }

  void dispose() {
    heureDebut.dispose();
    heureFin.dispose();
    codeTache.dispose();
    holeNo.dispose();
    fromDe.dispose();
    toA.dispose();
    total.dispose();
    commentaire.dispose();
    distance.dispose();
    duree.dispose();
  }
}

class LigneTempsScreen extends ConsumerStatefulWidget {
  const LigneTempsScreen({
    super.key,
    required this.quart,
    required this.dateText,
    required this.projectOdooId,
    required this.projectDateDJ,
    required this.projectDateDN,
    required this.foreuseOdooId,
    required this.locationOdooId,
  });

  final String quart;
  final String dateText;
  final int projectOdooId;
  final double? projectDateDJ;
  final double? projectDateDN;
  final int foreuseOdooId;
  final int locationOdooId;

  @override
  ConsumerState<LigneTempsScreen> createState() => _LigneTempsScreenState();
}

class _LigneTempsScreenState extends ConsumerState<LigneTempsScreen> {
  final List<_TimeLogDraft> _timeLogs = [];
  final ScrollController _scrollController = ScrollController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTasks);
  }

  @override
  void dispose() {
    _persistDraft();
    _scrollController.dispose();
    for (final log in _timeLogs) {
      log.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final db = ref.read(appDatabaseProvider);
    final tasks = await db.getAllTasks();
    if (!mounted) {
      return;
    }

    final reportDraft = ref.read(reportDraftProvider);
    final sameContext =
        reportDraft.projectOdooId == widget.projectOdooId &&
        reportDraft.foreuseOdooId == widget.foreuseOdooId &&
        reportDraft.locationOdooId == widget.locationOdooId &&
        reportDraft.dateText == widget.dateText &&
        reportDraft.quart == widget.quart;

    setState(() {
      _tasks = tasks;
      if (_timeLogs.isEmpty) {
        if (sameContext && reportDraft.timeLogs.isNotEmpty) {
          _timeLogs.addAll(
            reportDraft.timeLogs.map(_TimeLogDraft.fromReportDraft),
          );
        } else {
          _timeLogs.add(_createTimeLog());
        }
      }
      _rechainTimeLogs();
    });
    _persistDraft();
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setTimeLogs(
          _timeLogs.map((log) => log.toReportDraft()).toList(),
        );
  }

  String _formatDecimalHour(double? value) {
    if (value == null) {
      return '00:00';
    }
    final totalMinutes = (value * 60).round();
    final hours = (totalMinutes ~/ 60) % 24;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
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

  double _shiftStartValue() {
    if (widget.quart == 'Day/Jour') {
      return widget.projectDateDJ ?? 0.0;
    }
    if (widget.quart == 'Night/Nuit') {
      return widget.projectDateDN ?? 0.0;
    }
    return 0.0;
  }

  double _shiftEndValue() {
    if (widget.quart == 'Day/Jour') {
      return widget.projectDateDN ?? _shiftStartValue();
    }
    if (widget.quart == 'Night/Nuit') {
      final start = _shiftStartValue();
      final rawEnd = widget.projectDateDJ ?? start;
      return rawEnd <= start ? rawEnd + 24.0 : rawEnd;
    }
    return _shiftStartValue();
  }

  double _normalizeForShift(double value) {
    if (widget.quart != 'Night/Nuit') {
      return value;
    }
    final shiftStart = _shiftStartValue();
    return value < shiftStart ? value + 24.0 : value;
  }

  String _quartStartHour() {
    return _formatDecimalHour(_shiftStartValue());
  }

  String _quartEndHour() {
    final end = _shiftEndValue() % 24.0;
    return _formatDecimalHour(end);
  }

  String _initialStartForNewLog() {
    if (_timeLogs.isNotEmpty) {
      final previousEnd = _timeLogs.last.heureFin.text.trim();
      if (previousEnd.isNotEmpty) {
        return previousEnd;
      }
    }
    return _quartStartHour();
  }

  _TimeLogDraft _createTimeLog() {
    return _TimeLogDraft(initialStart: _initialStartForNewLog());
  }

  void _rechainTimeLogs({int startIndex = 0}) {
    if (_timeLogs.isEmpty) {
      return;
    }

    final safeStartIndex = startIndex < 0 ? 0 : startIndex;
    for (var index = safeStartIndex; index < _timeLogs.length; index++) {
      final log = _timeLogs[index];
      if (index == 0) {
        log.heureDebut.text = _quartStartHour();
      } else {
        log.heureDebut.text = _timeLogs[index - 1].heureFin.text.trim();
      }
      _recomputeDuration(log);
    }
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
    if (!_validateAllTimeLogs()) {
      return;
    }

    setState(() {
      _timeLogs.add(_createTimeLog());
      _rechainTimeLogs(startIndex: _timeLogs.length - 1);
    });
    _persistDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _removeLog(int index) {
    setState(() {
      final removed = _timeLogs.removeAt(index);
      removed.dispose();
      if (_timeLogs.isEmpty) {
        _timeLogs.add(_createTimeLog());
      }
      final recomputeFrom = index == 0 ? 0 : index - 1;
      _rechainTimeLogs(startIndex: recomputeFrom);
    });
    _persistDraft();
  }

  Task? _findTaskByItem(String item) {
    final normalized = item.trim();
    if (normalized.isEmpty) {
      return null;
    }
    for (final task in _tasks) {
      if ((task.numItem ?? '').trim() == normalized) {
        return task;
      }
    }
    return null;
  }

  Task? _findTaskById(int? taskId) {
    if (taskId == null) {
      return null;
    }
    for (final task in _tasks) {
      if (task.odooId == taskId) {
        return task;
      }
    }
    return null;
  }

  void _syncTaskFromItem(_TimeLogDraft log) {
    final task = _findTaskByItem(log.codeTache.text);
    log.selectedTaskOdooId = task?.odooId;
  }

  void _syncItemFromTask(_TimeLogDraft log) {
    final task = _findTaskById(log.selectedTaskOdooId);
    log.codeTache.text = task?.numItem ?? '';
  }

  void _recomputeTotal(_TimeLogDraft log) {
    final fromValue = int.tryParse(log.fromDe.text.trim());
    final toValue = int.tryParse(log.toA.text.trim());
    if (fromValue == null || toValue == null) {
      log.total.text = '';
      return;
    }
    log.total.text = (toValue - fromValue).toString();
  }

  void _recomputeDuration(_TimeLogDraft log) {
    final start = _parseHour(log.heureDebut.text);
    final end = _parseHour(log.heureFin.text);
    if (start == null || end == null) {
      log.duree.text = '';
      return;
    }
    final duration = end >= start ? end - start : (end + 24.0) - start;
    log.duree.text = _formatDuration(duration);
  }

  void _showShiftMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
  }

  bool _validateTimeLogAt(int index, {bool showMessage = true}) {
    final log = _timeLogs[index];
    final start = _parseHour(log.heureDebut.text);
    final end = _parseHour(log.heureFin.text);

    if (start == null || end == null) {
      if (showMessage) {
        _showShiftMessage('Renseignez une heure fin valide pour la ligne ${index + 1}.');
      }
      return false;
    }

    final normalizedStart = _normalizeForShift(start);
    final normalizedEnd = _normalizeForShift(end);
    final shiftEnd = _shiftEndValue();

    if (normalizedEnd < normalizedStart) {
      if (showMessage) {
        _showShiftMessage(
          'La ligne ${index + 1} depasse la plage du shift (${_quartStartHour()} - ${_quartEndHour()}).',
        );
      }
      return false;
    }

    if (normalizedEnd > shiftEnd) {
      if (showMessage) {
        _showShiftMessage(
          'Heure fin hors plage du shift. La ligne ${index + 1} doit rester entre ${_quartStartHour()} et ${_quartEndHour()}.',
        );
      }
      return false;
    }

    return true;
  }

  bool _validateAllTimeLogs() {
    for (var index = 0; index < _timeLogs.length; index++) {
      if (!_validateTimeLogAt(index)) {
        return false;
      }
    }
    return true;
  }

  String _formatMinutes(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hours = (normalized ~/ 60).toString().padLeft(2, '0');
    final minutes = (normalized % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  List<String> _allowedEndTimesFor(int index) {
    final log = _timeLogs[index];
    final start = _parseHour(log.heureDebut.text);
    if (start == null) {
      return const [];
    }

    final startMinutes = (_normalizeForShift(start) * 60).round();
    final endMinutes = (_shiftEndValue() * 60).round();
    if (endMinutes < startMinutes) {
      return const [];
    }

    final firstAllowedMinute = ((startMinutes + 4) ~/ 5) * 5;

    final values = <String>[];
    if (firstAllowedMinute > startMinutes) {
      values.add(_formatMinutes(startMinutes));
    }

    for (var minute = firstAllowedMinute; minute <= endMinutes; minute += 5) {
      values.add(_formatMinutes(minute));
    }

    if (values.isEmpty || values.last != _formatMinutes(endMinutes)) {
      values.add(_formatMinutes(endMinutes));
    }

    return values;
  }

  void _showTimeSpinner(
    BuildContext context,
    TextEditingController controller,
    VoidCallback afterChange,
    int index,
  ) {
    final allowedTimes = _allowedEndTimesFor(index);
    if (allowedTimes.isEmpty) {
      _showShiftMessage('Aucune heure fin disponible pour cette ligne.');
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

  Widget _buildStandardInput(
    String label,
    TextEditingController controller, {
    bool isReadOnly = false,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? const Color(0xFFF3F4F6) : Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: isReadOnly,
                    onChanged: onChanged,
                    keyboardType: keyboardType,
                    style: TextStyle(
                      fontSize: 13,
                      color: isReadOnly ? Colors.grey : const Color(0xFFF18E28),
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

  Widget _buildSpinnerInput(
    String label,
    TextEditingController controller,
    VoidCallback afterChange,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showTimeSpinner(context, controller, afterChange, index),
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, color: Colors.red),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFF18E28)),
                        decoration: const InputDecoration(
                          hintText: '--:--',
                          suffixIcon: Icon(Icons.unfold_more, size: 16, color: Colors.grey),
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

  Widget _buildTaskDropdown(_TimeLogDraft log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tache',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: log.selectedTaskOdooId,
                    isExpanded: true,
                    items: _tasks
                        .map(
                          (task) => DropdownMenuItem<int>(
                            value: task.odooId,
                            child: Text(
                              task.libelle,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        log.selectedTaskOdooId = value;
                        _syncItemFromTask(log);
                      });
                      _persistDraft();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
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

  Widget _buildVerticalCard(int index) {
    final log = _timeLogs[index];
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LIGNE DE TEMPS #${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.blueGrey,
                  ),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildStandardInput(
                        'Heure debut',
                        log.heureDebut,
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSpinnerInput(
                        'Heure fin',
                        log.heureFin,
                        () {
                          _recomputeDuration(log);
                          if (_validateTimeLogAt(index, showMessage: false)) {
                            _rechainTimeLogs(startIndex: index + 1);
                          }
                        },
                        index,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStandardInput(
                        'Code Tache',
                        log.codeTache,
                        onChanged: (_) {
                          setState(() {
                            _syncTaskFromItem(log);
                          });
                          _persistDraft();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStandardInput(
                        'Hole No.',
                        log.holeNo,
                        onChanged: (_) => _persistDraft(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStandardInput(
                        'From / De',
                        log.fromDe,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {
                            _recomputeTotal(log);
                          });
                          _persistDraft();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStandardInput(
                        'To / A',
                        log.toA,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {
                            _recomputeTotal(log);
                          });
                          _persistDraft();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTaskDropdown(log),
                const SizedBox(height: 16),
                _buildStandardInput(
                  'Commentaire',
                  log.commentaire,
                  onChanged: (_) => _persistDraft(),
                ),
                const SizedBox(height: 16),
                _buildStandardInput(
                  'Distance',
                  log.distance,
                  onChanged: (_) => _persistDraft(),
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
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back_ios, color: Colors.white, size: 14),
                    Text(
                      'Precedent',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                      'Ajouter',
                      style: TextStyle(
                        color: Color(0xFF00C7C9),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (!_validateAllTimeLogs()) {
                  return;
                }
                _persistDraft();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DrillingStaffForm(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Suivant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'LIGNE DE TEMPS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _timeLogs.length + 1,
        itemBuilder: (context, index) {
          if (index == _timeLogs.length) {
            return _buildActionButtons();
          }
          return _buildVerticalCard(index);
        },
      ),
    );
  }
}
