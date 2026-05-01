import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/features/auth/presentation/employee_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/fuel_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/materiel_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/recap_screen.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class _ProductionTimeLogDraft {
  _ProductionTimeLogDraft({
    required this.category,
    this.selectedTaskOdooId,
    String heureDebut = '',
    String heureFin = '',
    String codeTache = '',
    String holeNo = '',
    String fromDe = '',
    String toA = '',
    String total = '',
    String commentaire = '',
    String distance = '',
    String duree = '',
  }) {
    this.heureDebut.text = heureDebut;
    this.heureFin.text = heureFin;
    this.codeTache.text = codeTache;
    this.holeNo.text = holeNo;
    this.fromDe.text = fromDe;
    this.toA.text = toA;
    this.total.text = total;
    this.commentaire.text = commentaire;
    this.distance.text = distance;
    this.duree.text = duree;
  }

  factory _ProductionTimeLogDraft.fromReportDraft(ReportTimeLogDraft draft, String category) {
    return _ProductionTimeLogDraft(
      category: category,
      selectedTaskOdooId: draft.selectedTaskOdooId,
      heureDebut: draft.heureDebut,
      heureFin: draft.heureFin,
      codeTache: draft.codeTache,
      holeNo: draft.holeNo,
      fromDe: draft.fromDe,
      toA: draft.toA,
      total: draft.total,
      commentaire: draft.commentaire,
      distance: draft.distance,
      duree: draft.duree,
    );
  }

  final String category;
  int? selectedTaskOdooId;
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

  ReportTimeLogDraft toReportDraft() {
    return ReportTimeLogDraft(
      heureDebut: heureDebut.text.trim(),
      heureFin: heureFin.text.trim(),
      codeTache: codeTache.text.trim(),
      holeNo: holeNo.text.trim(),
      fromDe: fromDe.text.trim(),
      toA: toA.text.trim(),
      total: total.text.trim(),
      commentaire: commentaire.text.trim(),
      distance: distance.text.trim(),
      duree: duree.text.trim(),
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

class ProductionScreen extends ConsumerStatefulWidget {
  const ProductionScreen({
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
  ConsumerState<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends ConsumerState<ProductionScreen> {
  static const List<String> _categories = ['NOH', 'DOWN', 'DELAY', 'STANDBY'];
  static const Map<String, String> _categoryCodes = {
    'NOH': '1',
    'DELAY': '2',
    'DOWN': '3',
    'STANDBY': '4',
  };
  static const String _drillingActivityCode = '3';

  final List<_ProductionTimeLogDraft> _timeLogs = [];
  List<Task> _tasks = [];
  List<MaterialReference> _materialReferences = const [];
  List<int> _projectDrillingTaskIds = const [];
  Project? _project;
  Equipment? _foreuse;
  Location? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_initialize);
  }

  @override
  void dispose() {
    _persistDraft();
    for (final log in _timeLogs) {
      log.dispose();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    final db = ref.read(appDatabaseProvider);
    final tasks = await db.getAllTasks();
    final projects = await db.getAllProjects();
    final equipments = await db.getAllEquipments();
    final locations = await db.getAllLocations();
    final materialReferences = await db.getAllMaterialReferences();
    materialReferences.sort((a, b) => a.description.toLowerCase().compareTo(b.description.toLowerCase()));
    final draft = ref.read(reportDraftProvider);
    final projectDrillingTaskIds = await ref
        .read(projectDrillingTaskStoreProvider)
        .getTaskIdsForProject(widget.projectOdooId);

    final sameContext =
        draft.projectOdooId == widget.projectOdooId &&
        draft.foreuseOdooId == widget.foreuseOdooId &&
        draft.locationOdooId == widget.locationOdooId &&
        draft.dateText == widget.dateText &&
        draft.quart == widget.quart;

    final restoredLogs = sameContext
        ? draft.timeLogs
              .map(
                (row) => _ProductionTimeLogDraft.fromReportDraft(
                  row,
                  _resolveTaskCategory(_findTaskById(tasks, row.selectedTaskOdooId), fallbackCode: row.codeTache),
                ),
              )
              .toList()
        : <_ProductionTimeLogDraft>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = tasks;
      _materialReferences = materialReferences;
      _projectDrillingTaskIds = projectDrillingTaskIds;
      _project = _findByOdooId<Project>(projects, widget.projectOdooId, (item) => item.odooId);
      _foreuse = _findByOdooId<Equipment>(equipments, widget.foreuseOdooId, (item) => item.odooId);
      _location = _findByOdooId<Location>(locations, widget.locationOdooId, (item) => item.odooId);
      _timeLogs
        ..clear()
        ..addAll(restoredLogs);
      _loading = false;
    });

    if (_timeLogs.isNotEmpty) {
      _rechainFrom(0);
      _persistDraft();
    }
  }

  T? _findByOdooId<T>(List<T> items, int? id, int Function(T) pickId) {
    if (id == null) {
      return null;
    }
    for (final item in items) {
      if (pickId(item) == id) {
        return item;
      }
    }
    return null;
  }

  Task? _findTaskById(List<Task> tasks, int? taskId) {
    if (taskId == null) {
      return null;
    }
    for (final task in tasks) {
      if (task.odooId == taskId) {
        return task;
      }
    }
    return null;
  }

  Task? _findTaskByLog(_ProductionTimeLogDraft log) {
    return _findTaskById(_tasks, log.selectedTaskOdooId);
  }

  String _resolveTaskCategory(Task? task, {String? fallbackCode}) {
    final categoryCode = (task?.categorie ?? '').trim();
    for (final entry in _categoryCodes.entries) {
      if (entry.value == categoryCode) {
        return entry.key;
      }
    }

    final directCategory = (task?.categorie ?? '').trim().toUpperCase();
    if (_categories.contains(directCategory)) {
      return directCategory;
    }

    final fallbackCategory = (task?.typeTache ?? '').trim().toUpperCase();
    if (_categories.contains(fallbackCategory)) {
      return fallbackCategory;
    }

    final values = <String>[
      task?.categorie ?? '',
      task?.typeTache ?? '',
      task?.categorieActivity ?? '',
      task?.typeActivite ?? '',
      task?.libelle ?? '',
      fallbackCode ?? '',
    ];

    for (final category in _categories) {
      final normalizedCategory = category.toUpperCase();
      for (final value in values) {
        if (value.toUpperCase().contains(normalizedCategory)) {
          return category;
        }
      }
    }
    return 'NOH';
  }

  List<Task> _tasksForCategory(String category, {String? nohType}) {
    return _tasks.where((task) {
      final categoryCode = _categoryCodes[category];
      final taskCategoryCode = (task.categorie ?? '').trim();

      if (categoryCode != null) {
        if (taskCategoryCode != categoryCode) {
          return false;
        }
      } else if (_resolveTaskCategory(task) != category) {
        return false;
      }

      if (category == 'NOH' && nohType != null) {
        final activityCode = (task.categorieActivity ?? '').trim();
        if (nohType == 'DRILLING') {
          if (activityCode != _drillingActivityCode) {
            return false;
          }
          return _projectDrillingTaskIds.contains(task.odooId);
        }
        return activityCode != _drillingActivityCode;
      }
      return true;
    }).toList(growable: false);
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setTimeLogs(
          _timeLogs.map((row) => row.toReportDraft()).toList(growable: false),
        );
  }

  bool _isMaterialAlreadyAdded(int materialOdooId) {
    final materielLogs = ref.read(reportDraftProvider).materielLogs;
    return materielLogs.any((item) => item.materialOdooId == materialOdooId);
  }

  Future<bool> _openQuickMaterialPicker() async {
    final selectedMaterial = await showDialog<MaterialReference>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var filtered = _materialReferences
            .where((material) => !_isMaterialAlreadyAdded(material.odooId))
            .toList(growable: false);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applyFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                filtered = _materialReferences.where((material) {
                  if (_isMaterialAlreadyAdded(material.odooId)) {
                    return false;
                  }
                  if (normalized.isEmpty) {
                    return true;
                  }
                  final haystack = '${material.reference ?? ''} ${material.description}'.toLowerCase();
                  return haystack.contains(normalized);
                }).toList(growable: false);
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Ajouter un materiel',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      onChanged: applyFilter,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par reference ou description',
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
                        child: Text('Aucun materiel disponible.'),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 360),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final material = filtered[index];
                            return Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                title: Text(
                                  material.reference?.isNotEmpty == true ? material.reference! : '--',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(material.description),
                                trailing: const Icon(Icons.add_circle_outline_rounded),
                                onTap: () => Navigator.pop(context, material),
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

    if (selectedMaterial == null) {
      return false;
    }

    final draft = ref.read(reportDraftProvider);
    if (_isMaterialAlreadyAdded(selectedMaterial.odooId)) {
      return false;
    }

    final updatedMaterielLogs = [
      ...draft.materielLogs,
      ReportMaterielDraft(
        materialOdooId: selectedMaterial.odooId,
        description: selectedMaterial.description,
        serie: selectedMaterial.reference ?? '',
      ),
    ];

    ref.read(reportDraftProvider.notifier).setMaterielLogs(updatedMaterielLogs);
    return true;
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

  String _formatHour(double value) {
    final totalMinutes = (value * 60).round();
    final hours = ((totalMinutes ~/ 60) % 24).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _formatDuration(double value) {
    final totalMinutes = (value * 60).round();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  double _shiftStart() {
    if (widget.quart == 'Night/Nuit') {
      return widget.projectDateDN ?? 0.0;
    }
    return widget.projectDateDJ ?? 0.0;
  }

  double _shiftEnd() {
    if (widget.quart == 'Night/Nuit') {
      final start = _shiftStart();
      final rawEnd = widget.projectDateDJ ?? start;
      return rawEnd <= start ? rawEnd + 24.0 : rawEnd;
    }
    return widget.projectDateDN ?? _shiftStart();
  }

  double _normalizeForShift(double value) {
    if (widget.quart != 'Night/Nuit') {
      return value;
    }
    final shiftStart = _shiftStart();
    return value < shiftStart ? value + 24.0 : value;
  }

  String _shiftStartText() => _formatHour(_shiftStart());

  String _shiftEndText() => _formatHour(_shiftEnd() % 24.0);

  String _nextStartText() {
    if (_timeLogs.isNotEmpty) {
      final previousEnd = _timeLogs.last.heureFin.text.trim();
      if (previousEnd.isNotEmpty) {
        return previousEnd;
      }
    }
    return _shiftStartText();
  }

  String _defaultEndText(String startText, {int minutesToAdd = 15}) {
    final start = _parseHour(startText);
    if (start == null) {
      return startText;
    }

    final startMinutes = (_normalizeForShift(start) * 60).round();
    final shiftEndMinutes = (_shiftEnd() * 60).round();
    final targetMinutes = startMinutes + minutesToAdd;
    final boundedMinutes = targetMinutes > shiftEndMinutes ? shiftEndMinutes : targetMinutes;
    return _formatHour(boundedMinutes / 60.0);
  }

  String _adjustEndText(String startText, String currentEndText, int minutesDelta) {
    final start = _parseHour(startText);
    if (start == null) {
      return currentEndText;
    }

    final currentEnd = _parseHour(currentEndText);
    final fallbackEnd = _parseHour(_defaultEndText(startText));
    final startMinutes = (_normalizeForShift(start) * 60).round();
    final shiftEndMinutes = (_shiftEnd() * 60).round();
    final baseMinutes = currentEnd != null
        ? (_normalizeForShift(currentEnd) * 60).round()
        : (fallbackEnd != null ? (_normalizeForShift(fallbackEnd) * 60).round() : startMinutes);
    final adjustedMinutes = baseMinutes + minutesDelta;
    final boundedMinutes = adjustedMinutes < startMinutes
        ? startMinutes
        : (adjustedMinutes > shiftEndMinutes ? shiftEndMinutes : adjustedMinutes);
    return _formatHour(boundedMinutes / 60.0);
  }

  String _nowWithinShiftText(String startText) {
    final start = _parseHour(startText);
    if (start == null) {
      return _defaultEndText(startText);
    }

    final now = DateTime.now();
    final nowValue = now.hour + (now.minute / 60.0);
    final normalizedNow = _normalizeForShift(nowValue);
    final startMinutes = (_normalizeForShift(start) * 60).round();
    final shiftEndMinutes = (_shiftEnd() * 60).round();
    final nowMinutes = (normalizedNow * 60).round();
    final boundedMinutes = nowMinutes < startMinutes
        ? startMinutes
        : (nowMinutes > shiftEndMinutes ? shiftEndMinutes : nowMinutes);
    return _formatHour(boundedMinutes / 60.0);
  }

  void _recomputeTotals(_ProductionTimeLogDraft log) {
    final fromValue = double.tryParse(log.fromDe.text.trim().replaceAll(',', '.'));
    final toValue = double.tryParse(log.toA.text.trim().replaceAll(',', '.'));
    if (fromValue == null || toValue == null) {
      log.total.text = '';
    } else {
      final delta = toValue - fromValue;
      log.total.text = delta == delta.roundToDouble() ? delta.toInt().toString() : delta.toStringAsFixed(2);
    }

    final start = _parseHour(log.heureDebut.text);
    final end = _parseHour(log.heureFin.text);
    if (start == null || end == null) {
      log.duree.text = '';
      return;
    }

    final normalizedStart = _normalizeForShift(start);
    final normalizedEnd = _normalizeForShift(end);
    if (normalizedEnd < normalizedStart) {
      log.duree.text = '';
      return;
    }
    log.duree.text = _formatDuration(normalizedEnd - normalizedStart);
  }

  bool _isEndAllowed(String startText, String endText) {
    final start = _parseHour(startText);
    final end = _parseHour(endText);
    if (start == null || end == null) {
      return false;
    }

    final normalizedStart = _normalizeForShift(start);
    final normalizedEnd = _normalizeForShift(end);
    if (normalizedEnd < normalizedStart) {
      return false;
    }
    return normalizedEnd <= _shiftEnd();
  }

  void _rechainFrom(int startIndex) {
    if (_timeLogs.isEmpty) {
      return;
    }

    final safeIndex = startIndex < 0 ? 0 : startIndex;
    for (var index = safeIndex; index < _timeLogs.length; index++) {
      final log = _timeLogs[index];
      log.heureDebut.text = index == 0 ? _shiftStartText() : _timeLogs[index - 1].heureFin.text.trim();

      if (log.heureFin.text.trim().isEmpty || !_isEndAllowed(log.heureDebut.text, log.heureFin.text)) {
        log.heureFin.text = log.heureDebut.text;
      }
      _recomputeTotals(log);
    }
  }

  List<String> _allowedEndTimes(String startText) {
    final start = _parseHour(startText);
    if (start == null) {
      return const [];
    }

    final startMinutes = (_normalizeForShift(start) * 60).round();
    final endMinutes = (_shiftEnd() * 60).round();
    if (endMinutes < startMinutes) {
      return const [];
    }

    final values = <String>[];
    final firstFive = ((startMinutes + 4) ~/ 5) * 5;

    if (firstFive > startMinutes) {
      values.add(_formatHour(startMinutes / 60.0));
    }

    for (var minute = firstFive; minute <= endMinutes; minute += 5) {
      values.add(_formatHour(minute / 60.0));
    }

    final endText = _formatHour(endMinutes / 60.0);
    if (values.isEmpty || values.last != endText) {
      values.add(endText);
    }
    return values;
  }

  void _showMessage(String message, {bool isError = true}) {
    if (isError) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F7A1F),
        ),
      );
  }

  Future<String?> _pickEndTime(String startText, {String? currentValue}) async {
    final allowedTimes = _allowedEndTimes(startText);
    if (allowedTimes.isEmpty) {
      return null;
    }

    var selectedIndex = allowedTimes.indexOf(currentValue ?? '');
    if (selectedIndex < 0) {
      selectedIndex = 0;
    }

    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
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
                      onPressed: () => Navigator.pop(context, allowedTimes[selectedIndex]),
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
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
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

  Future<void> _openTaskSelector(String category, {String? nohType}) async {
    final tasks = _tasksForCategory(category, nohType: nohType);
    if (tasks.isEmpty) {
      final label = nohType == null ? category : '$category - $nohType';
      _showMessage('Aucune activite disponible pour $label.');
      return;
    }

    final selectedTask = await _openTaskDialog(category: category, tasks: tasks, nohType: nohType);

    if (selectedTask == null || !mounted) {
      return;
    }

    await _openEventEditor(category: category, task: selectedTask, nohType: nohType);
  }

  Future<Task?> _openTaskDialog({
    required String category,
    required List<Task> tasks,
    String? nohType,
  }) {
    return showDialog<Task>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        var filtered = List<Task>.from(tasks);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void applyFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setDialogState(() {
                filtered = tasks.where((task) {
                  final haystack =
                      '${task.libelle} ${task.numItem ?? ''} ${task.typeTache ?? ''} ${task.categorieActivity ?? ''}'
                          .toLowerCase();
                  return haystack.contains(normalized);
                }).toList(growable: false);
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                nohType == null ? 'Activites $category' : 'Activites $category - $nohType',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      onChanged: applyFilter,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une activite ou un Code',
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
                        child: Text('Aucune activite disponible.'),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 360),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            return Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                title: Text(task.libelle, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(task.numItem?.isNotEmpty == true ? 'Code ${task.numItem}' : 'Sans Code'),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.pop(context, task),
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
  }


  Future<void> _openNohTypeSelector() async {
    final selectedType = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'NOH',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisis la sous-categorie.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildNohTypeButton(
                      label: 'Drilling',
                      color: const Color(0xFF0F9D8A),
                      onTap: () => Navigator.pop(context, 'DRILLING'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNohTypeButton(
                      label: 'Autres',
                      color: const Color(0xFF1E3A5F),
                      onTap: () => Navigator.pop(context, 'AUTRES'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (selectedType == null || !mounted) {
      return;
    }

    await _openTaskSelector('NOH', nohType: selectedType);
  }

  Widget _buildNohTypeButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEventEditor({
    required String category,
    required Task task,
    String? nohType,
    _ProductionTimeLogDraft? existingLog,
    int? existingIndex,
  }) async {
    final isEditing = existingLog != null;
    final log = existingLog ??
        _ProductionTimeLogDraft(
          category: category,
          selectedTaskOdooId: task.odooId,
          heureDebut: _nextStartText(),
          heureFin: _nextStartText(),
          codeTache: task.numItem ?? '',
        );

    log.selectedTaskOdooId = task.odooId;
    log.codeTache.text = task.numItem ?? '';
    if (log.heureDebut.text.trim().isEmpty) {
      log.heureDebut.text = _nextStartText();
    }
    if (log.heureFin.text.trim().isEmpty || !_isEndAllowed(log.heureDebut.text, log.heureFin.text)) {
      log.heureFin.text = log.heureDebut.text;
    }
    _recomputeTotals(log);

    final effectiveNohType = category == 'NOH'
        ? (nohType ?? (((task.categorieActivity ?? '').trim() == _drillingActivityCode) ? 'DRILLING' : 'AUTRES'))
        : null;
    final taskCode = (task.numItem ?? '').trim();
    final isNohAutres = category == 'NOH' && effectiveNohType == 'AUTRES';
    final isDown = category == 'DOWN';
    final isStandby = category == 'STANDBY';
    final isDelay = category == 'DELAY';
    final isDelayHoleFromToCode = isDelay && (taskCode == '40' || taskCode == '107');
    final isDelayDistanceCode = isDelay && (taskCode == '50' || taskCode == '51');
    final hideOperationalFields = isNohAutres || isDown || isStandby;

    final showHoleField =
        isDelay ? isDelayHoleFromToCode : !hideOperationalFields;
    final showFromToFields =
        isDelay ? isDelayHoleFromToCode : !hideOperationalFields;
    final showDistanceField = isDelay
        ? isDelayDistanceCode
        : category != 'NOH' && !hideOperationalFields;
    final useDialogEditor = const {'NOH', 'DOWN', 'DELAY', 'STANDBY'}.contains(category);

    bool isStepEnabled(String field) {
      final hasEnd = log.heureFin.text.trim().isNotEmpty && log.heureFin.text.trim() != log.heureDebut.text.trim();
      final hasHole = log.holeNo.text.trim().isNotEmpty;
      final hasFrom = log.fromDe.text.trim().isNotEmpty;
      final hasTo = log.toA.text.trim().isNotEmpty;
      switch (field) {
        case 'end':
          return true;
        case 'hole':
          return hasEnd;
        case 'from':
          return hasEnd && (!showHoleField || hasHole);
        case 'to':
          return hasEnd && (!showHoleField || hasHole) && (!showFromToFields || hasFrom);
        case 'comment':
          return hasEnd && (!showHoleField || hasHole) && (!showFromToFields || (hasFrom && hasTo));
        default:
          return true;
      }
    }

    final shouldSave = await (useDialogEditor
        ? showDialog<bool>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> pickEndTime() async {
                    final picked = await _pickEndTime(
                      log.heureDebut.text.trim(),
                      currentValue: log.heureFin.text.trim(),
                    );
                    if (picked == null) {
                      return;
                    }
                    setModalState(() {
                      log.heureFin.text = picked;
                      _recomputeTotals(log);
                    });
                  }

                  void applyQuickEnd(String value) {
                    setModalState(() {
                      log.heureFin.text = value;
                      _recomputeTotals(log);
                    });
                  }

                  Future<void> openMateriel() async {
                    final added = await _openQuickMaterialPicker();
                    if (!mounted || !added) {
                      return;
                    }
                    setModalState(() {});
                  }

                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    content: SizedBox(
                      width: 620,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _categoryColor(category).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: _categoryColor(category),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            Text(
                              task.libelle,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task.numItem?.isNotEmpty == true ? 'Code ${task.numItem}' : 'Sans Code',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildReadonlyField(
                                    'Heure debut',
                                    log.heureDebut.text.trim(),
                                    inlineLabel: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTapField(
                                    label: 'Heure fin',
                                    value: log.heureFin.text.trim().isEmpty ? '--:--' : log.heureFin.text.trim(),
                                    onTap: pickEndTime,
                                    inlineLabel: true,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildQuickTimeButton('+5', () => applyQuickEnd(_adjustEndText(log.heureDebut.text.trim(), log.heureFin.text.trim(), 5))),
                                _buildQuickTimeButton('+10', () => applyQuickEnd(_adjustEndText(log.heureDebut.text.trim(), log.heureFin.text.trim(), 10))),
                                _buildQuickTimeButton('+15', () => applyQuickEnd(_adjustEndText(log.heureDebut.text.trim(), log.heureFin.text.trim(), 15))),
                                _buildQuickTimeButton('+30', () => applyQuickEnd(_adjustEndText(log.heureDebut.text.trim(), log.heureFin.text.trim(), 30))),
                                _buildQuickTimeButton('Maintenant', () => applyQuickEnd(_nowWithinShiftText(log.heureDebut.text.trim()))),
                                _buildQuickTimeButton('Fin shift', () => applyQuickEnd(_shiftEndText())),
                                _buildQuickTimeButton(
                                  'Materiel',
                                  openMateriel,
                                  backgroundColor: const Color(0xFF1E3A5F),
                                  foregroundColor: Colors.white,
                                  borderColor: const Color(0xFF1E3A5F),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (showHoleField)
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.holeNo,
                                      label: 'Hole No.',
                                      onChanged: (_) => setModalState(() {}),
                                      inlineLabel: true,
                                      enabled: isStepEnabled('hole'),
                                    ),
                                  ),
                                if (showHoleField && showDistanceField) const SizedBox(width: 12),
                                if (showDistanceField)
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.distance,
                                      label: 'Distance',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      inlineLabel: true,
                                    ),
                                  ),
                              ],
                            ),
                            if (showHoleField || showDistanceField) const SizedBox(height: 16),
                            if (showFromToFields)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.fromDe,
                                      label: 'De',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      onChanged: (_) => setModalState(() => _recomputeTotals(log)),
                                      inlineLabel: true,
                                      enabled: isStepEnabled('from'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.toA,
                                      label: 'A',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      onChanged: (_) => setModalState(() => _recomputeTotals(log)),
                                      inlineLabel: true,
                                      enabled: isStepEnabled('to'),
                                    ),
                                  ),
                                ],
                              ),
                            if (showFromToFields) const SizedBox(height: 16),
                            _buildTextField(
                              controller: log.commentaire,
                              label: 'Commentaire',
                              maxLines: 1,
                              inlineLabel: true,
                              enabled: isStepEnabled('comment'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 23)
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      if (showHoleField && log.holeNo.text.trim().isEmpty) {
                                        _showMessage('Hole No. est obligatoire.');
                                        return;
                                      }
                                      if (showFromToFields && log.fromDe.text.trim().isEmpty) {
                                        _showMessage('De est obligatoire.');
                                        return;
                                      }
                                      if (showFromToFields && log.toA.text.trim().isEmpty) {
                                        _showMessage('A est obligatoire.');
                                        return;
                                      }
                                      if (showDistanceField && log.distance.text.trim().isEmpty) {
                                        _showMessage('Distance est obligatoire.');
                                        return;
                                      }
                                      if (showFromToFields) {
                                        final fromValue = double.tryParse(log.fromDe.text.trim().replaceAll(',', '.'));
                                        final toValue = double.tryParse(log.toA.text.trim().replaceAll(',', '.'));
                                        if (fromValue == null || toValue == null) {
                                          _showMessage('De et A doivent etre numeriques.');
                                          return;
                                        }
                                        if (toValue <= fromValue) {
                                          _showMessage('A doit etre strictement superieur a De.');
                                          return;
                                        }
                                      }
                                      if (log.heureDebut.text.trim() == log.heureFin.text.trim()) {
                                        _showMessage("Heure fin doit etre differente de l'heure debut.");
                                        return;
                                      }
                                      if (!_isEndAllowed(log.heureDebut.text.trim(), log.heureFin.text.trim())) {
                                        _showMessage(
                                          'Heure fin hors plage du shift. Reste entre ${_shiftStartText()} et ${_shiftEndText()}.',
                                        );
                                        return;
                                      }
                                      Navigator.pop(context, true);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _categoryColor(category),
                                      padding: const EdgeInsets.symmetric(vertical: 23)
                                    ),
                                    child: Text(isEditing ? 'Mettre a jour' : 'Valider'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )
        : showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> pickEndTime() async {
                    final picked = await _pickEndTime(
                      log.heureDebut.text.trim(),
                      currentValue: log.heureFin.text.trim(),
                    );
                    if (picked == null) {
                      return;
                    }
                    setModalState(() {
                      log.heureFin.text = picked;
                      _recomputeTotals(log);
                    });
                  }

                  return Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _categoryColor(category).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: _categoryColor(category),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            Text(
                              task.libelle,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task.numItem?.isNotEmpty == true ? 'Code ${task.numItem}' : 'Sans Code',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildReadonlyField('Heure debut', log.heureDebut.text.trim())),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTapField(
                                    label: 'Heure fin',
                                    value: log.heureFin.text.trim().isEmpty ? '--:--' : log.heureFin.text.trim(),
                                    onTap: pickEndTime,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (showHoleField)
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.holeNo,
                                      label: 'Hole No.',
                                    ),
                                  ),
                                if (showHoleField && showDistanceField) const SizedBox(width: 12),
                                if (showDistanceField)
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.distance,
                                      label: 'Distance',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                    ),
                                  ),
                              ],
                            ),
                            if (showHoleField || showDistanceField) const SizedBox(height: 16),
                            if (showFromToFields)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.fromDe,
                                      label: 'De',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      onChanged: (_) => setModalState(() => _recomputeTotals(log)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: log.toA,
                                      label: 'A',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                      onChanged: (_) => setModalState(() => _recomputeTotals(log)),
                                    ),
                                  ),
                                ],
                              ),
                            if (showFromToFields) const SizedBox(height: 16),
                            _buildTextField(
                              controller: log.commentaire,
                              label: 'Commentaire',
                              maxLines: 1,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      if (!_isEndAllowed(log.heureDebut.text.trim(), log.heureFin.text.trim())) {
                                        _showMessage(
                                          'Heure fin hors plage du shift. Reste entre ${_shiftStartText()} et ${_shiftEndText()}.',
                                        );
                                        return;
                                      }
                                      Navigator.pop(context, true);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _categoryColor(category),
                                    ),
                                    child: Text(isEditing ? 'Mettre a jour' : 'Valider'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ));

    if (shouldSave != true || !mounted) {
      if (!isEditing) {
        log.dispose();
      }
      return;
    }

    setState(() {
      if (isEditing && existingIndex != null) {
        _timeLogs[existingIndex] = log;
        _rechainFrom(existingIndex);
      } else {
        _timeLogs.add(log);
        _rechainFrom(_timeLogs.length - 1);
      }
    });
    _persistDraft();
  }

  void _editLog(int index) {
    final log = _timeLogs[index];
    final task = _findTaskByLog(log);
    if (task == null) {
      _showMessage('Tache introuvable pour cette ligne.');
      return;
    }
    _openEventEditor(
      category: log.category,
      task: task,
      nohType: log.category == 'NOH' && (task.categorieActivity ?? '').trim() == _drillingActivityCode
          ? 'DRILLING'
          : 'AUTRES',
      existingLog: log,
      existingIndex: index,
    );
  }

  void _removeLog(int index) {
    setState(() {
      final removed = _timeLogs.removeAt(index);
      removed.dispose();
      if (_timeLogs.isNotEmpty) {
        _rechainFrom(index == 0 ? 0 : index - 1);
      }
    });
    _persistDraft();
  }

  void _goToPersonnel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DrillingStaffForm()),
    );
  }

  void _goToMateriel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DrillingConsumableForm()),
    );
  }

  void _goToFuel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DrillingFuelForm()),
    );
  }

  void _goToRecap() {
    if (_timeLogs.isEmpty) {
      _showMessage('Ajoute au moins une activite avant le recapitulatif.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecapScreen()),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'DOWN':
        return const Color(0xFFD64545);
      case 'DELAY':
        return const Color(0xFFE58A1F);
      case 'STANDBY':
        return const Color.fromARGB(255, 216, 203, 28);
      case 'NOH':
      default:
        return const Color(0xFF0F9D8A);
    }
  }

  Widget _buildReadonlyField(String label, String value, {bool inlineLabel = false}) {
    if (inlineLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTapField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool inlineLabel = false,
    bool enabled = true,
  }) {
    if (inlineLabel) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5DCE6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.black87 : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.schedule_rounded, color: enabled ? null : const Color(0xFF9CA3AF)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD5DCE6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.schedule_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTimeButton(
    String label,
    VoidCallback onTap, {
    Color backgroundColor = const Color(0xFFF3F6FB),
    Color foregroundColor = const Color(0xFF1F2937),
    Color borderColor = const Color(0xFFD5DCE6),
  }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
      onPressed: onTap,
      backgroundColor: backgroundColor,
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
    bool inlineLabel = false,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    if (inlineLabel) {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: enabled ? onChanged : null,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFE5E7EB),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: enabled ? onChanged : null,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFE5E7EB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF203A63), Color(0xFF162A46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feuille de production',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(Icons.nightlight_round, widget.quart),
              _buildInfoChip(Icons.precision_manufacturing_outlined, _foreuse?.name ?? '-'),
              _buildInfoChip(Icons.place_outlined, _location?.name ?? '-'),
              _buildInfoChip(Icons.calendar_today_outlined, widget.dateText),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildShiftMetric('Projet', _project?.name ?? '-'),
                ),
                Expanded(
                  child: _buildShiftMetric('Shift', '${_shiftStartText()} -> ${_shiftEndText()}'),
                ),
                Expanded(
                  child: _buildShiftMetric(
                    'Heure courante',
                    _timeLogs.isEmpty ? _shiftStartText() : _timeLogs.last.heureFin.text.trim(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Row(
      children: List.generate(_categories.length, (index) {
        final category = _categories[index];
        final count = _timeLogs.where((row) => row.category == category).length;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 10),
            child: InkWell(
              onTap: () {
                if (category == 'NOH') {
                  _openNohTypeSelector();
                  return;
                }
                _openTaskSelector(category);
              },
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  color: _categoryColor(category),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _categoryColor(category).withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                          ),
                          const Spacer(),
                          Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimelineList() {
    if (_timeLogs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: const [
            Icon(Icons.timeline_outlined, size: 36, color: Color(0xFF64748B)),
            SizedBox(height: 12),
            Text(
              'Aucune activite saisie',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Choisis une categorie pour ajouter la premiere activite du shift.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_timeLogs.length, (index) {
        final log = _timeLogs[index];
        final task = _findTaskByLog(log);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _categoryColor(log.category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      log.category,
                      style: TextStyle(
                        color: _categoryColor(log.category),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${log.heureDebut.text.trim()} - ${log.heureFin.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _editLog(index),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _removeLog(index),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task?.libelle ?? 'Activite introuvable',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (log.codeTache.text.trim().isNotEmpty) _smallMeta('Code ${log.codeTache.text.trim()}'),
                  if (log.holeNo.text.trim().isNotEmpty) _smallMeta('Hole NO : ${log.holeNo.text.trim()}'),
                  if (log.duree.text.trim().isNotEmpty) _smallMeta('Duree : ${log.duree.text.trim()}'),
                  if (log.total.text.trim().isNotEmpty) _smallMeta('Total : ${log.total.text.trim()}'),
                  if (log.distance.text.trim().isNotEmpty) _smallMeta('Dist.: ${log.distance.text.trim()}'),
                ],
              ),
              if (log.commentaire.text.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  log.commentaire.text.trim(),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _smallMeta(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Contexte'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 23),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _goToPersonnel,
                icon: const Icon(Icons.groups_2_outlined),
                label: const Text('Personnel'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  padding: const EdgeInsets.symmetric(vertical: 23),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToMateriel,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Materiel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 23),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToFuel,
                icon: const Icon(Icons.local_gas_station_outlined),
                label: const Text('Equipement Auxilliere'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 23),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _goToRecap,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Recapitulatif'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE58A1F),
              padding: const EdgeInsets.symmetric(vertical: 25),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Production',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContextCard(),
                        const SizedBox(height: 24),
                        const Text(
                          'Categories d\'activite',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        _buildCategoryButtons(),
                        const SizedBox(height: 24),
                        const Text(
                          'Evenements saisis',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        _buildTimelineList(),
                        const SizedBox(height: 20),
                        _buildFooterActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}









