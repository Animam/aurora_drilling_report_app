import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/features/auth/presentation/employee_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/fuel_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/materiel_form_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/post_login_menu_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/production_screen.dart';
import 'package:aurora_drilling_report/features/auth/presentation/registration_screen.dart';
import 'package:aurora_drilling_report/shared/providers/api_providers.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({
    super.key,
    this.feuilleLocalId,
    this.openedFromList = false,
  });

  final int? feuilleLocalId;
  final bool openedFromList;

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  Project? _project;
  Equipment? _foreuse;
  Location? _location;
  bool _loading = true;
  bool _saving = false;
  bool _syncing = false;
  int? _currentFeuilleLocalId;
  String? _existingMobileUuid;
  int? _existingOdooId;
  String? _existingForageSignature;
  String? _existingClientSignature;
  final List<Offset?> _clientSignaturePoints = <Offset?>[];
  final List<Offset?> _companySignaturePoints = <Offset?>[];
  final TextEditingController _hourMeterController = TextEditingController();
  final TextEditingController _fuelMeterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeScreen);
  }

  @override
  void dispose() {
    _persistMeterFields();
    _hourMeterController.dispose();
    _fuelMeterController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (widget.feuilleLocalId != null) {
      await _loadDraftFromLocalFeuille(widget.feuilleLocalId!);
    }

    final draft = ref.read(reportDraftProvider);
    _clientSignaturePoints
      ..clear()
      ..addAll(_fromDraftSignature(draft.clientSignature));
    _companySignaturePoints
      ..clear()
      ..addAll(_fromDraftSignature(draft.companySignature));
    _hourMeterController.text = draft.hourMeter;
    _fuelMeterController.text = draft.fuelMeter;

    await _loadReferences();
  }

  Future<void> _loadReferences() async {
    final draft = ref.read(reportDraftProvider);
    final db = ref.read(appDatabaseProvider);
    final projects = await db.getAllProjects();
    final equipments = await db.getAllEquipments();
    final locations = await db.getAllLocations();

    if (!mounted) {
      return;
    }

    setState(() {
      _project = _findByOdooId<Project>(projects, draft.projectOdooId, (item) => item.odooId);
      _foreuse = _findByOdooId<Equipment>(equipments, draft.foreuseOdooId, (item) => item.odooId);
      _location = _findByOdooId<Location>(locations, draft.locationOdooId, (item) => item.odooId);
      _loading = false;
    });
  }

  Future<void> _loadDraftFromLocalFeuille(int feuilleLocalId) async {
    final db = ref.read(appDatabaseProvider);
    final notifier = ref.read(reportDraftProvider.notifier);

    final feuille =
        await (db.select(db.feuilles)
              ..where((tbl) => tbl.localId.equals(feuilleLocalId)))
            .getSingle();
    final lignes = await db.getLignesByFeuille(feuilleLocalId);
    final fuels = await db.getFuelsByFeuille(feuilleLocalId);
    final employes = await db.getEmployesByFeuille(feuilleLocalId);
    final materiels = await db.getMaterielsByFeuille(feuilleLocalId);
    final projects = await db.getAllProjects();
    final employees = await db.getAllEmployees();
    final equipments = await db.getAllEquipments();

    final project = _findByOdooId<Project>(
      projects,
      feuille.nomProjetOdooId,
      (item) => item.odooId,
    );

    notifier.reset();
    notifier.setQuart(feuille.quart);
    notifier.setForeuseOdooId(feuille.foreuseOdooId);
    notifier.setLocationOdooId(feuille.locationOdooId);
    notifier.setDateText(feuille.dateForage);
    notifier.setProjectData(
      projectOdooId: feuille.nomProjetOdooId,
      projectDateDJ: project?.dateDJ,
      projectDateDN: project?.dateDN,
    );
    notifier.setHourMeter(feuille.hourMeter?.toString() ?? '');
    notifier.setFuelMeter(feuille.fuelMeter ?? '');
    notifier.setTimeLogs(
      lignes
          .map(
            (row) => ReportTimeLogDraft(
              heureDebut: _formatDecimalHour(row.dateD),
              heureFin: _formatDecimalHour(row.dateF),
              codeTache: row.item,
              holeNo: row.holeNo ?? '',
              fromDe: row.fromDim?.toString() ?? '',
              toA: row.toDim?.toString() ?? '',
              total: row.totalDim?.toString() ?? '',
              commentaire: row.note ?? '',
              distance: row.distance?.toString() ?? '',
              duree: _formatDecimalHour(row.rr),
              selectedTaskOdooId: row.tacheOdooId,
            ),
          )
          .toList(growable: false),
    );
    notifier.setStaffLogs(
      employes
          .map(
            (row) => ReportStaffLogDraft(
              employeNom: _findByOdooId<Employee>(
                    employees,
                    row.employeeOdooId,
                    (item) => item.odooId,
                  )?.name ??
                  '',
              employeeOdooId: row.employeeOdooId,
              fonction: row.fonction ?? '',
              hDebut: row.dateDebut ?? '',
              hFin: row.dateFin ?? '',
              total: _formatDecimalHour(row.difference),
              obs: row.observation ?? '',
              isAbsent: row.absent,
            ),
          )
          .toList(growable: false),
    );
    notifier.setMaterielLogs(
      materiels
          .map(
            (row) => ReportMaterielDraft(
              description: row.description ?? '',
              serie: row.serialNumber ?? '',
              quantite: row.quantity?.toString() ?? '0',
              observation: row.observation ?? '',
              status: row.status ?? '',
            ),
          )
          .toList(growable: false),
    );
    notifier.setFuelLogs(
      fuels
          .map(
            (row) => ReportFuelLogDraft(
              equipmentOdooId: row.compresseurOdooId,
              equipement: _findByOdooId<Equipment>(
                    equipments,
                    row.compresseurOdooId,
                    (item) => item.odooId,
                  )?.name ??
                  '',
              qtyFuel: _formatNumericValue(row.qytFuel),
              hDebut: _formatDecimalHour(row.dateDEqui),
              hFin: _formatDecimalHour(row.dateFEqui),
              hDebutRavi: _formatDecimalHour(row.dateDRavi),
              hFinRavi: _formatDecimalHour(row.dateFRavi),
            ),
          )
          .toList(growable: false),
    );
    notifier.setClientSignature(const []);
    notifier.setCompanySignature(const []);

    _currentFeuilleLocalId = feuille.localId;
    _existingMobileUuid = feuille.mobileUuid;
    _existingOdooId = feuille.odooId;
    _existingForageSignature = feuille.forageSignature;
    _existingClientSignature = feuille.clientSignature;
  }

  List<Offset?> _fromDraftSignature(List<ReportSignaturePointDraft> signature) {
    return signature
        .map((point) => point.isBreak ? null : Offset(point.dx, point.dy))
        .toList(growable: true);
  }

  List<ReportSignaturePointDraft> _toDraftSignature(List<Offset?> points) {
    return points
        .map((point) => point == null
            ? const ReportSignaturePointDraft(dx: 0, dy: 0, isBreak: true)
            : ReportSignaturePointDraft(dx: point.dx, dy: point.dy))
        .toList(growable: false);
  }

  void _saveClientSignature() {
    ref.read(reportDraftProvider.notifier).setClientSignature(_toDraftSignature(_clientSignaturePoints));
  }

  void _saveCompanySignature() {
    ref.read(reportDraftProvider.notifier).setCompanySignature(_toDraftSignature(_companySignaturePoints));
  }

  void _persistMeterFields() {
    final notifier = ref.read(reportDraftProvider.notifier);
    notifier.setHourMeter(_hourMeterController.text.trim());
    notifier.setFuelMeter(_fuelMeterController.text.trim());
  }

  T? _findByOdooId<T>(List<T> items, int? odooId, int Function(T item) getId) {
    if (odooId == null) {
      return null;
    }
    for (final item in items) {
      if (getId(item) == odooId) {
        return item;
      }
    }
    return null;
  }

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  double _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0.0;
  }

  int? _tryParseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }

  double? _tryParseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed.replaceAll(',', '.'));
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

  double? _parseDurationToHours(String value) {
    return _parseHour(value);
  }

  String _formatDecimalHour(double? value) {
    if (value == null) {
      return '';
    }
    final normalized = value < 0 ? 0.0 : value;
    final totalMinutes = (normalized * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatNumericValue(double? value) {
    if (value == null) {
      return '0';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  Future<String?> _signatureToBase64(List<Offset?> points) async {
    final segments = points.where((point) => point != null).length;
    if (segments == 0) {
      return null;
    }

    const width = 900.0;
    const height = 320.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF13233F)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, strokePaint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return null;
    }
    final bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  }

  bool _hasTimeRowData(ReportTimeLogDraft row) {
    return row.heureDebut.trim().isNotEmpty ||
        row.heureFin.trim().isNotEmpty ||
        row.codeTache.trim().isNotEmpty ||
        row.holeNo.trim().isNotEmpty ||
        row.fromDe.trim().isNotEmpty ||
        row.toA.trim().isNotEmpty ||
        row.total.trim().isNotEmpty ||
        row.commentaire.trim().isNotEmpty ||
        row.distance.trim().isNotEmpty ||
        row.duree.trim().isNotEmpty;
  }

  bool _hasStaffRowData(ReportStaffLogDraft row) {
    return row.employeNom.trim().isNotEmpty ||
        row.fonction.trim().isNotEmpty ||
        row.hDebut.trim().isNotEmpty ||
        row.hFin.trim().isNotEmpty ||
        row.total.trim().isNotEmpty ||
        row.obs.trim().isNotEmpty ||
        row.isAbsent;
  }

  bool _hasMaterielRowData(ReportMaterielDraft row) {
    return row.description.trim().isNotEmpty ||
        row.serie.trim().isNotEmpty ||
        row.quantite.trim().isNotEmpty ||
        row.observation.trim().isNotEmpty ||
        row.status.trim().isNotEmpty;
  }

  bool _hasFuelRowData(ReportFuelLogDraft row) {
    return row.equipement.trim().isNotEmpty ||
        row.qtyFuel.trim().isNotEmpty ||
        row.hDebut.trim().isNotEmpty ||
        row.hFin.trim().isNotEmpty ||
        row.hDebutRavi.trim().isNotEmpty ||
        row.hFinRavi.trim().isNotEmpty;
  }

  Future<int> _saveAllLocallyInternal() async {
    _persistMeterFields();
    final draft = ref.read(reportDraftProvider);
    final db = ref.read(appDatabaseProvider);

    final projectId = draft.projectOdooId;
    final quart = draft.quart?.trim() ?? '';
    final dateForage = draft.dateText?.trim() ?? '';

    if (projectId == null) {
      throw Exception('Projet non selectionne');
    }
    if (quart.isEmpty) {
      throw Exception('Quart non renseigne');
    }
    if (dateForage.isEmpty) {
      throw Exception('Date de forage non renseignee');
    }

    final filledTimeRows = draft.timeLogs.where(_hasTimeRowData).toList(growable: false);
    final filledStaffRows = draft.staffLogs.where(_hasStaffRowData).toList(growable: false);
    final filledMaterielRows = draft.materielLogs.where(_hasMaterielRowData).toList(growable: false);
    final filledFuelRows = draft.fuelLogs.where(_hasFuelRowData).toList(growable: false);

    for (final row in filledTimeRows) {
      if (row.codeTache.trim().isEmpty) {
        throw Exception('Chaque ligne de temps doit avoir un item');
      }
    }

    for (final row in filledStaffRows) {
      if (row.employeeOdooId == null) {
        throw Exception('Chaque ligne personnel doit avoir un employe selectionne');
      }
    }

    for (final row in filledMaterielRows) {
      if (row.description.trim().isEmpty) {
        throw Exception('Chaque ligne materiel doit avoir une description');
      }
    }

    for (final row in filledFuelRows) {
      if (row.equipmentOdooId == null) {
        throw Exception('Chaque ligne equipement auxiliaire doit avoir un equipement selectionne');
      }
    }

    final uuid = const Uuid();
    final forageSignature =
        (await _signatureToBase64(_companySignaturePoints)) ?? _existingForageSignature;
    final clientSignature =
        (await _signatureToBase64(_clientSignaturePoints)) ?? _existingClientSignature;

    late final int feuilleLocalId;
    await db.transaction(() async {
      final now = DateTime.now().toIso8601String();

      if (_currentFeuilleLocalId != null) {
        feuilleLocalId = _currentFeuilleLocalId!;
        await (db.update(db.feuilles)
              ..where((tbl) => tbl.localId.equals(feuilleLocalId)))
            .write(
          FeuillesCompanion(
            mobileUuid: Value(_existingMobileUuid ?? uuid.v4()),
            odooId: Value(_existingOdooId),
            nomProjetOdooId: Value(projectId),
            quart: Value(quart),
            dateForage: Value(dateForage),
            foreuseOdooId: Value(draft.foreuseOdooId),
            locationOdooId: Value(draft.locationOdooId),
            hourMeter: Value(_tryParseInt(draft.hourMeter)),
            fuelMeter: Value(
              draft.fuelMeter.trim().isEmpty ? null : draft.fuelMeter.trim(),
            ),
            forageSignature: Value(forageSignature),
            clientSignature: Value(clientSignature),
            remarks: const Value(null),
            syncStatus: const Value('pending'),
            updatedAt: Value(now),
          ),
        );

        await (db.delete(db.feuilleLignes)
              ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
            .go();
        await (db.delete(db.feuilleFuels)
              ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
            .go();
        await (db.delete(db.feuilleEmployes)
              ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
            .go();
        await (db.delete(db.feuilleMateriels)
              ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
            .go();
      } else {
        feuilleLocalId = await db.saveLocalFeuille(
          mobileUuid: uuid.v4(),
          nomProjetOdooId: projectId,
          quart: quart,
          dateForage: dateForage,
          foreuseOdooId: draft.foreuseOdooId,
          locationOdooId: draft.locationOdooId,
          hourMeter: _tryParseInt(draft.hourMeter),
          fuelMeter: draft.fuelMeter.trim().isEmpty ? null : draft.fuelMeter.trim(),
          forageSignature: forageSignature,
          clientSignature: clientSignature,
          remarks: null,
        );
        _currentFeuilleLocalId = feuilleLocalId;
      }

      var sequence = 10;
      for (final row in filledTimeRows) {
        await db.saveLocalFeuilleLigne(
          feuilleLocalId: feuilleLocalId,
          mobileUuid: uuid.v4(),
          item: row.codeTache.trim(),
          tacheOdooId: row.selectedTaskOdooId,
          holeNo: row.holeNo.trim().isEmpty ? null : row.holeNo.trim(),
          note: row.commentaire.trim().isEmpty ? null : row.commentaire.trim(),
          dateD: _parseHour(row.heureDebut),
          dateF: _parseHour(row.heureFin),
          rr: _parseDurationToHours(row.duree),
          distance: _tryParseInt(row.distance),
          fromDim: _tryParseInt(row.fromDe),
          toDim: _tryParseInt(row.toA),
          totalDim: _tryParseInt(row.total),
          sequence: sequence,
        );
        sequence += 10;
      }

      for (final row in filledFuelRows) {
        await db.saveLocalFeuilleFuel(
          feuilleLocalId: feuilleLocalId,
          mobileUuid: uuid.v4(),
          compresseurOdooId: row.equipmentOdooId,
          qytFuel: _tryParseDouble(row.qtyFuel) ?? 0.0,
          dateDEqui: _parseHour(row.hDebut),
          dateFEqui: _parseHour(row.hFin),
          dateDRavi: _parseHour(row.hDebutRavi),
          dateFRavi: _parseHour(row.hFinRavi),
        );
      }

      for (final row in filledStaffRows) {
        await db.saveLocalFeuilleEmploye(
          feuilleLocalId: feuilleLocalId,
          mobileUuid: uuid.v4(),
          employeeOdooId: row.employeeOdooId!,
          fonction: row.fonction.trim().isEmpty ? null : row.fonction.trim(),
          observation: row.obs.trim().isEmpty ? null : row.obs.trim(),
          dateEmp: dateForage,
          dateDebut: row.hDebut.trim().isEmpty ? null : row.hDebut.trim(),
          dateFin: row.hFin.trim().isEmpty ? null : row.hFin.trim(),
          difference: _parseDurationToHours(row.total),
          absent: row.isAbsent,
        );
      }

      for (final row in filledMaterielRows) {
        await db.saveLocalFeuilleMateriel(
          feuilleLocalId: feuilleLocalId,
          mobileUuid: uuid.v4(),
          description: row.description.trim().isEmpty ? null : row.description.trim(),
          serialNumber: row.serie.trim().isEmpty ? null : row.serie.trim(),
          quantity: _tryParseDouble(row.quantite),
          observation: row.observation.trim().isEmpty ? null : row.observation.trim(),
          status: row.status.trim().isEmpty ? null : row.status.trim(),
        );
      }
    });

    return feuilleLocalId;
  }


  Future<void> _showSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Succes',
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
  }

  Future<void> _saveAllLocally() async {
    setState(() {
      _saving = true;
    });

    try {
      await _saveAllLocallyInternal();

      if (!mounted) {
        return;
      }

      await _showSuccessDialog(
        widget.openedFromList
            ? 'Feuille locale mise a jour'
            : 'Feuille enregistree localement',
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PostLoginMenuScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final message = _cleanErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _normalizeQuartForSync(String quart) {
    final normalized = quart.trim().toLowerCase();
    if (normalized == 'day/jour' || normalized == 'day' || normalized == 'jour') {
      return 'jour';
    }
    if (normalized == 'night/nuit' || normalized == 'night' || normalized == 'nuit') {
      return 'nuit';
    }
    return quart;
  }

  DateTime? _parseDateOnly(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final isoParts = trimmed.split('-');
    if (isoParts.length == 3) {
      final year = int.tryParse(isoParts[0]);
      final month = int.tryParse(isoParts[1]);
      final day = int.tryParse(isoParts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    final frParts = trimmed.split('/');
    if (frParts.length == 3) {
      final day = int.tryParse(frParts[0]);
      final month = int.tryParse(frParts[1]);
      final year = int.tryParse(frParts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  String? _combineDateAndTime(
    String dateValue,
    String? timeValue, {
    DateTime? startReference,
  }) {
    final baseDate = _parseDateOnly(dateValue);
    final time = (timeValue ?? '').trim();
    if (baseDate == null || time.isEmpty) {
      return null;
    }

    final parts = time.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) {
      return null;
    }

    var dateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hours,
      minutes,
    );

    if (startReference != null && dateTime.isBefore(startReference)) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute:00';
  }

  int? _resolveMaterialOdooId(
    FeuilleMateriel row,
    List<MaterialReference> references,
  ) {
    final reference = (row.serialNumber ?? '').trim().toLowerCase();
    final description = (row.description ?? '').trim().toLowerCase();

    for (final item in references) {
      if (reference.isNotEmpty && (item.reference ?? '').trim().toLowerCase() == reference) {
        return item.odooId;
      }
    }

    for (final item in references) {
      if (description.isNotEmpty && item.description.trim().toLowerCase() == description) {
        return item.odooId;
      }
    }

    return null;
  }

  Future<void> _syncCurrentFeuille() async {
    if (_syncing) {
      return;
    }

    setState(() {
      _syncing = true;
    });

    try {
      final feuilleLocalId = await _saveAllLocallyInternal();
      final db = ref.read(appDatabaseProvider);
      final syncApi = ref.read(syncApiProvider);

      final feuille = await db.getFeuilleByLocalId(feuilleLocalId);
      if (feuille == null) {
        throw Exception('Feuille locale introuvable');
      }

      final lignes = await db.getLignesByFeuille(feuilleLocalId);
      final employes = await db.getEmployesByFeuille(feuilleLocalId);
      final fuels = await db.getFuelsByFeuille(feuilleLocalId);
      final materiels = await db.getMaterielsByFeuille(feuilleLocalId);
      final materialReferences = await db.getAllMaterialReferences();

      final result = await syncApi.syncFullFeuille(
        feuille: {
          'mobile_uuid': feuille.mobileUuid,
          'odoo_id': feuille.odooId,
          'nom_projet_odoo_id': feuille.nomProjetOdooId,
          'quart': _normalizeQuartForSync(feuille.quart),
          'date_forage': feuille.dateForage,
          'foreuse_odoo_id': feuille.foreuseOdooId,
          'location_odoo_id': feuille.locationOdooId,
          'hour_meter': feuille.hourMeter,
          'fuel_meter': feuille.fuelMeter,
          'forage_signature': feuille.forageSignature,
          'client_signature': feuille.clientSignature,
          'remarks': feuille.remarks,
        },
        lignes: lignes
            .map(
              (row) => <String, dynamic>{
                'mobile_uuid': row.mobileUuid,
                'item': row.item,
                'tache_odoo_id': row.tacheOdooId,
                'note': row.note,
                'distance': row.distance,
                'hole_no': row.holeNo,
                'from_dim': row.fromDim,
                'to_dim': row.toDim,
                'date_d': row.dateD,
                'date_f': row.dateF,
                'rr': row.rr,
                'sequence': row.sequence,
              },
            )
            .toList(growable: false),
        employes: employes
            .map((row) {
              final startDateTime = _combineDateAndTime(
                feuille.dateForage,
                row.dateDebut,
              );
              final startReference = startDateTime != null ? DateTime.tryParse(startDateTime) : null;
              final endDateTime = _combineDateAndTime(
                feuille.dateForage,
                row.dateFin,
                startReference: startReference,
              );
              return <String, dynamic>{
                'mobile_uuid': row.mobileUuid,
                'employee_odoo_id': row.employeeOdooId,
                'date_emp': feuille.dateForage,
                'date_debut': startDateTime,
                'date_fin': endDateTime,
                'observation': row.observation,
                'absent': row.absent,
              };
            }).toList(growable: false),
        fuels: fuels
            .map(
              (row) => <String, dynamic>{
                'mobile_uuid': row.mobileUuid,
                'compresseur_odoo_id': row.compresseurOdooId,
                'qyt_fuel': row.qytFuel,
                'date_d_equi': row.dateDEqui,
                'date_f_equi': row.dateFEqui,
                'date_d_ravi': row.dateDRavi,
                'date_f_ravi': row.dateFRavi,
              },
            )
            .toList(growable: false),
        materiels: materiels
            .map((row) {
              final materialOdooId = _resolveMaterialOdooId(row, materialReferences);
              if (materialOdooId == null) {
                throw Exception(
                  'Impossible de retrouver le materiel pour la reference "${row.serialNumber ?? row.description ?? ''}"',
                );
              }
              return <String, dynamic>{
                'mobile_uuid': row.mobileUuid,
                'description_odoo_id': materialOdooId,
                'date_mat': feuille.dateForage,
                'quantite': row.quantity?.round(),
                'observation': row.observation,
                'status': row.status,
              };
            }).toList(growable: false),
      );

      final feuilleOdooId = (result['odoo_id'] as num?)?.toInt();
      if (feuilleOdooId == null) {
        throw Exception('La synchronisation n\'a pas retourne de feuille Odoo');
      }

      await db.markFeuilleSynced(
        feuilleLocalId: feuilleLocalId,
        feuilleOdooId: feuilleOdooId,
      );

      _existingOdooId = feuilleOdooId;

      if (!mounted) {
        return;
      }

      await _showSuccessDialog('Synchronisation reussie');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const PostLoginMenuScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final message = _cleanErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  String _formatFuel(double value) {
    final hasDecimals = value != value.roundToDouble();
    return hasDecimals ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
  }

  int get _totalMetersDrill {
    final draft = ref.read(reportDraftProvider);
    return draft.timeLogs.fold<int>(0, (sum, row) => sum + _parseInt(row.total));
  }

  double get _totalFuel {
    final draft = ref.read(reportDraftProvider);
    return draft.fuelLogs.fold<double>(0, (sum, row) => sum + _parseDouble(row.qtyFuel));
  }

  String get _totalHours {
    final draft = ref.read(reportDraftProvider);
    var totalMinutes = 0;
    for (final row in draft.timeLogs) {
      final parts = row.duree.split(':');
      if (parts.length != 2) {
        continue;
      }
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      totalMinutes += (hours * 60) + minutes;
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  bool _isSupervisorRole(String fonction) {
    final normalized = fonction.trim().toLowerCase();
    return normalized.contains('superviseur') || normalized.contains('supervisor');
  }

  String get _superviseurName {
    final draft = ref.read(reportDraftProvider);
    for (final row in draft.staffLogs) {
      if (_isSupervisorRole(row.fonction) && row.employeNom.trim().isNotEmpty) {
        return row.employeNom.trim();
      }
    }
    return '--';
  }

  String get _operateurNames {
    final draft = ref.read(reportDraftProvider);
    final names = <String>[];
    for (final row in draft.staffLogs) {
      final name = row.employeNom.trim();
      if (name.isEmpty) {
        continue;
      }
      if (_isSupervisorRole(row.fonction)) {
        continue;
      }
      names.add(name);
    }
    if (names.isEmpty) {
      return '--';
    }
    return names.join(', ');
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accent,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderField(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
                color: emphasize ? const Color(0xFF18243E) : const Color(0xFF69758C),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.isEmpty ? '--' : value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2740),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.07)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18243E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF66738A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6F7A8F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              left,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2940),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              right,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF526077),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLogsSection() {
    final draft = ref.watch(reportDraftProvider);
    if (draft.timeLogs.isEmpty) {
      return _buildEmptyState('Aucune ligne de temps ajoutee.');
    }

    return Column(
      children: draft.timeLogs.map((row) {
        final taskLabel = row.codeTache.isEmpty ? '--' : row.codeTache;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EBF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEBFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${row.heureDebut} - ${row.heureFin.isEmpty ? '--:--' : row.heureFin}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF144A8A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Duree ${row.duree.isEmpty ? '--:--' : row.duree}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF536177),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Item / Code', taskLabel),
              _buildInfoRow('Hole No.', row.holeNo.isEmpty ? '--' : row.holeNo),
              _buildInfoRow('De / A', '${row.fromDe.isEmpty ? '0' : row.fromDe} -> ${row.toA.isEmpty ? '0' : row.toA}'),
              _buildInfoRow('Total metres', row.total.isEmpty ? '0' : row.total),
              _buildInfoRow('Commentaire', row.commentaire.isEmpty ? '--' : row.commentaire),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStaffSection() {
    final draft = ref.watch(reportDraftProvider);
    if (draft.staffLogs.isEmpty) {
      return _buildEmptyState('Aucun employe ajoute.');
    }

    return Column(
      children: draft.staffLogs.map((row) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EBF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.employeNom.isEmpty ? '--' : row.employeNom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18243E),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (row.isAbsent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE2E2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Absent',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Fonction', row.fonction.isEmpty ? '--' : row.fonction),
              _buildInfoRow('Horaire', '${row.hDebut.isEmpty ? '--:--' : row.hDebut} -> ${row.hFin.isEmpty ? '--:--' : row.hFin}'),
              _buildInfoRow('Total', row.total.isEmpty ? '--:--' : row.total),
              _buildInfoRow('Observation', row.obs.isEmpty ? '--' : row.obs),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaterielSection() {
    final draft = ref.watch(reportDraftProvider);
    if (draft.materielLogs.isEmpty) {
      return _buildEmptyState('Aucun materiel ajoute.');
    }

    return Column(
      children: draft.materielLogs.map((row) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EBF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.description.isEmpty ? '--' : row.description,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF18243E)),
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Serie', row.serie.isEmpty ? '--' : row.serie),
              _buildInfoRow('Quantite', row.quantite.isEmpty ? '0' : row.quantite),
              _buildInfoRow('Observation', row.observation.isEmpty ? '--' : row.observation),
              _buildInfoRow('Status', row.status.isEmpty ? '--' : row.status),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFuelSection() {
    final draft = ref.watch(reportDraftProvider);
    if (draft.fuelLogs.isEmpty) {
      return _buildEmptyState('Aucune ligne fuel ajoutee.');
    }

    return Column(
      children: draft.fuelLogs.map((row) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EBF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.equipement.isEmpty ? '--' : row.equipement,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF18243E)),
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Qty Fuel', row.qtyFuel.isEmpty ? '0' : row.qtyFuel),
              _buildInfoRow('Horaire equip.', '${row.hDebut.isEmpty ? '--:--' : row.hDebut} -> ${row.hFin.isEmpty ? '--:--' : row.hFin}'),
              _buildInfoRow('Horaire ravi.', '${row.hDebutRavi.isEmpty ? '--:--' : row.hDebutRavi} -> ${row.hFinRavi.isEmpty ? '--:--' : row.hFinRavi}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _addSignaturePoint(List<Offset?> points, Offset point, VoidCallback onChanged) {
    setState(() {
      points.add(point);
    });
    onChanged();
  }

  void _endSignatureStroke(List<Offset?> points, VoidCallback onChanged) {
    var didChange = false;
    setState(() {
      if (points.isNotEmpty && points.last != null) {
        points.add(null);
        didChange = true;
      }
    });
    if (didChange) {
      onChanged();
    }
  }

  void _clearSignature(List<Offset?> points, VoidCallback onChanged) {
    setState(() {
      points.clear();
    });
    onChanged();
  }

  Uint8List? _decodeSignatureImage(String? base64Value) {
    final value = base64Value?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  Widget _buildSignaturePanel({
    required String title,
    // required String subtitle,
    required List<Offset?> points,
    String? existingSignatureBase64,
    required VoidCallback onClear,
    required VoidCallback onChanged,
  }) {
    final hasSignature = points.any((point) => point != null);
    final existingSignatureBytes =
        !hasSignature ? _decodeSignatureImage(existingSignatureBase64) : null;
    final showExistingSignature = existingSignatureBytes != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EBF4)),
      ),
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18243E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    /* Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6D7990),
                      ),
                    ), */
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.restart_alt_outlined, size: 18),
                label: const Text('Effacer'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2457C5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD7E0ED)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFDFEFF),
                            const Color(0xFFF6F9FD),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: showExistingSignature
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.memory(
                              existingSignatureBytes,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SignaturePainter(points),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) => _addSignaturePoint(points, details.localPosition, onChanged),
                      onPanUpdate: (details) => _addSignaturePoint(points, details.localPosition, onChanged),
                      onPanEnd: (_) => _endSignatureStroke(points, onChanged),
                    ),
                  ),
                  if (!hasSignature)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: showExistingSignature
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFD7E0ED),
                                    ),
                                  ),
                                  child: const Text(
                                    'Signature locale chargee',
                                    style: TextStyle(
                                      color: Color(0xFF51627D),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.draw_outlined,
                                      color: Color(0xFF8A97AD),
                                      size: 30,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Signer ici avec le doigt ou le stylet',
                                      style: TextStyle(
                                        color: Color(0xFF7A879D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Column(
            children: [
              _buildSignaturePanel(
                title: 'Signature Superviseur Client',
                // subtitle: 'Le representant client signe directement sur la tablette.',
                points: _clientSignaturePoints,
                existingSignatureBase64: _existingClientSignature,
                onClear: () {
                  _existingClientSignature = null;
                  _clearSignature(_clientSignaturePoints, _saveClientSignature);
                },
                onChanged: _saveClientSignature,
              ),
              const SizedBox(height: 14),
              _buildSignaturePanel(
                title: 'Signature Superviseur Aurora',
                // subtitle: "Le representant de l'entreprise signe sur la meme feuille.",
                points: _companySignaturePoints,
                existingSignatureBase64: _existingForageSignature,
                onClear: () {
                  _existingForageSignature = null;
                  _clearSignature(_companySignaturePoints, _saveCompanySignature);
                },
                onChanged: _saveCompanySignature,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSignaturePanel(
                title: 'Signature Superviseur Client',
                // subtitle: 'Le representant client signe directement sur la tablette.',
                points: _clientSignaturePoints,
                existingSignatureBase64: _existingClientSignature,
                onClear: () {
                  _existingClientSignature = null;
                  _clearSignature(_clientSignaturePoints, _saveClientSignature);
                },
                onChanged: _saveClientSignature,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSignaturePanel(
                title: 'Signature Superviseur Aurora',
                // subtitle: "Le representant de l'entreprise signe sur la meme feuille.",
                points: _companySignaturePoints,
                existingSignatureBase64: _existingForageSignature,
                onClear: () {
                  _existingForageSignature = null;
                  _clearSignature(_companySignaturePoints, _saveCompanySignature);
                },
                onChanged: _saveCompanySignature,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(reportDraftProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'RECAPITULATIF FINAL',
          style: TextStyle(
            color: Color(0xFF19243A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3F6FB), Color(0xFFEAF0F8)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10213C), Color(0xFF274D7E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumé du Rapport de Forage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verification complete avant enregistrement local',
                          style: TextStyle(
                            color: Color(0xFFD9E6F7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildHeroChip(Icons.approval_outlined, draft.quart ?? '--'),
                            _buildHeroChip(Icons.precision_manufacturing_outlined, _foreuse?.name ?? '--'),
                            _buildHeroChip(Icons.location_on_outlined, _location?.name ?? '--'),
                            _buildHeroChip(Icons.calendar_today_outlined, draft.dateText ?? '--'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    title: 'Entete feuille',
                    icon: Icons.description_outlined,
                    accent: const Color(0xFF2457C5),
                    onEdit: () => _openScreen(const RegistrationScreen()),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 760;
                        if (isNarrow) {
                          return Column(
                            children: [
                              _buildHeaderColumn(leftColumn: true),
                              const SizedBox(height: 8),
                              _buildHeaderColumn(leftColumn: false),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildHeaderColumn(leftColumn: true)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildHeaderColumn(leftColumn: false)),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildSectionCard(
                    title: 'Resume global',
                    icon: Icons.insights_outlined,
                    accent: const Color(0xFF0F9D8A),
                    child: GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _buildSummaryTile('Lignes temps', '${draft.timeLogs.length}', const Color(0xFF2457C5)),
                        _buildSummaryTile('Employes', '${draft.staffLogs.length}', const Color(0xFFE2802E)),
                        _buildSummaryTile('Materiels', '${draft.materielLogs.length}', const Color(0xFF0F9D8A)),
                        _buildSummaryTile('Equip Aux/Fuel', '${draft.fuelLogs.length}', const Color(0xFF8A3FFC)),
                        _buildSummaryTile('Metres drill', '$_totalMetersDrill', const Color(0xFFDB4437)),
                        _buildSummaryTile('Heures', _totalHours, const Color(0xFF1F7A8C)),
                        _buildSummaryTile('Fuel total', _formatFuel(_totalFuel), const Color(0xFF6C9A1F)),
                        _buildSummaryTile(
                          'Absents',
                          '${draft.staffLogs.where((row) => row.isAbsent).length}',
                          const Color(0xFFB3261E),
                        ),
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    title: 'Ligne de temps',
                    icon: Icons.timeline_outlined,
                    accent: const Color(0xFF2457C5),
                    onEdit: () => _openScreen(
                      ProductionScreen(
                        quart: draft.quart ?? 'Day/Jour',
                        dateText: draft.dateText ?? '',
                        projectOdooId: draft.projectOdooId ?? 0,
                        projectDateDJ: draft.projectDateDJ,
                        projectDateDN: draft.projectDateDN,
                        foreuseOdooId: draft.foreuseOdooId ?? 0,
                        locationOdooId: draft.locationOdooId ?? 0,
                      ),
                    ),
                    child: _buildTimeLogsSection(),
                  ),
                  _buildSectionCard(
                    title: 'Personnel',
                    icon: Icons.groups_2_outlined,
                    accent: const Color(0xFFE2802E),
                    onEdit: () => _openScreen(const DrillingStaffForm()),
                    child: _buildStaffSection(),
                  ),
                  _buildSectionCard(
                    title: 'Materiels',
                    icon: Icons.inventory_2_outlined,
                    accent: const Color(0xFF0F9D8A),
                    onEdit: () => _openScreen(const DrillingConsumableForm()),
                    child: _buildMaterielSection(),
                  ),
                  _buildSectionCard(
                    title: 'Equipement auxiliaire / Fuel',
                    icon: Icons.local_gas_station_outlined,
                    accent: const Color(0xFF8A3FFC),
                    onEdit: () => _openScreen(const DrillingFuelForm()),
                    child: _buildFuelSection(),
                  ),
                  _buildSectionCard(
                    title: 'Signatures',
                    icon: Icons.border_color_outlined,
                    accent: const Color(0xFF1F7A8C),
                    child: _buildSignatureSection(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                          label: const Text('Precedent'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF23324D),
                            side: const BorderSide(color: Color(0xFFCBD6E5)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.openedFromList) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_saving || _syncing) ? null : _syncCurrentFeuille,
                            icon: _syncing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.sync_outlined),
                            label: Text(_syncing ? 'Synchronisation...' : 'Synchroniser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F9D8A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: (_saving || _syncing) ? null : _saveAllLocally,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _saving
                                ? 'Enregistrement...'
                                : widget.openedFromList
                                ? 'Mettre a jour localement'
                                : 'Enregistrer localement',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF13233F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn({required bool leftColumn}) {
    final draft = ref.watch(reportDraftProvider);
    if (leftColumn) {
      return Column(
        children: [
          _buildHeaderField('Projet', _project?.name ?? '--', emphasize: true),
          _buildHeaderField('Client', _project?.partnerName ?? '--'),
          _buildHeaderField('Quart', draft.quart ?? '--', emphasize: true),
          _buildHeaderField('Foreuse / Drill', _foreuse?.name ?? '--', emphasize: true),
          _buildHeaderField('Superviseur', _superviseurName),
          _buildHeaderField('Operateur', _operateurNames),
          _buildHeaderField(
            'Fuel meter / Compteur carburant',
            _fuelMeterController.text.trim().isEmpty ? '--' : _fuelMeterController.text.trim(),
            emphasize: true,
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHeaderField('Date de forage', draft.dateText ?? '--', emphasize: true),
        _buildHeaderField('Location', _location?.name ?? '--', emphasize: true),
        _buildHeaderField('Total meters drill', '$_totalMetersDrill'),
        _buildHeaderField(
          'Hour meter / Compteur horaire',
          _hourMeterController.text.trim().isEmpty ? '--' : _hourMeterController.text.trim(),
          emphasize: true,
        ),
        _buildHeaderField('Compteur d\'horaires de forage', _totalHours),
        _buildHeaderField('Fuel supplied / Carburant approvisionne', _formatFuel(_totalFuel)),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF13233F)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
