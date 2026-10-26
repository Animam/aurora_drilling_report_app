import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'production_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const List<String> _quartOptions = ['Day/Jour', 'Night/Nuit'];

  static const Color _navy = Color(0xFF13233F);
  static const Color _navyLight = Color(0xFF1E3A5F);
  static const Color _orange = Color(0xFFF18E28);
  static const Color _textDark = Color(0xFF18243E);
  static const Color _muted = Color(0xFF69758C);
  static const Color _fieldFill = Color(0xFFF8FAFD);
  static const Color _border = Color(0xFFD7DFEA);
  static const Color _softBg = Color(0xFFFDF8E1);
  static const Color _softBorder = Color(0xFFF0E4BC);
  static const Color _chipText = Color(0xFF374151);

  String? _selectedQuart;
  int? _selectedForeuseOdooId;
  int? _selectedLocationOdooId;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fuelMeterController = TextEditingController();
  final TextEditingController _hourMeterController = TextEditingController();

  bool _hourMeterEnabled = false;

  List<Project> _projects = [];
  List<Equipment> _foreuses = [];
  List<Location> _locations = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _selectedQuart = draft.quart;
    _selectedForeuseOdooId = draft.foreuseOdooId;
    _selectedLocationOdooId = draft.locationOdooId;
    _dateController.text =
        draft.dateText ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
    _fuelMeterController.text = draft.fuelMeter;
    _hourMeterController.text = draft.hourMeter;
    _hourMeterEnabled = _hourMeterController.text.trim().isNotEmpty || true;
    Future.microtask(_loadReferenceData);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fuelMeterController.dispose();
    _hourMeterController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final projects = await db.getAllProjects();
      final equipments = await db.getAllEquipments();
      final locations = await db.getAllLocations();

      final foreuses = equipments.where((equipment) {
        final category = (equipment.categoryName ?? '').toLowerCase();
        return category.contains('foreuse');
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _projects = projects;
        _foreuses = foreuses;
        _locations = locations;
      });
      _applyAutoQuartFromSelection();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _orange,
              onPrimary: _navy,
              secondary: _navy,
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _dateController.text = formatted;
      });
      ref.read(reportDraftProvider.notifier).setDateText(formatted);
    }
  }

  Equipment? _selectedForeuse() {
    for (final equipment in _foreuses) {
      if (equipment.odooId == _selectedForeuseOdooId) {
        return equipment;
      }
    }
    return null;
  }

  String? _selectedLocationName() {
    for (final location in _locations) {
      if (location.odooId == _selectedLocationOdooId) {
        return location.name;
      }
    }
    return null;
  }

  String? get _quartLabel {
    final quart = _selectedQuart?.trim();
    if (quart == null || quart.isEmpty) {
      return null;
    }
    return quart == 'Day/Jour' ? 'Jour' : 'Nuit';
  }

  int get _completedSteps {
    final steps = <bool>[
      _selectedForeuseOdooId != null,
      _quartLabel != null,
      _selectedLocationOdooId != null,
      _dateController.text.trim().isNotEmpty,
      _hourMeterController.text.trim().isNotEmpty,
      _fuelMeterController.text.trim().isNotEmpty,
    ];
    return steps.where((done) => done).length;
  }

  Project? _resolveProjectForSelection() {
    final foreuse = _selectedForeuse();
    final projectOdooId = foreuse?.projectOdooId;
    if (projectOdooId != null) {
      for (final project in _projects) {
        if (project.odooId == projectOdooId) {
          return project;
        }
      }
    }
    if (_projects.length == 1) {
      return _projects.first;
    }
    return null;
  }

  void _resetLocationIfOutOfScope() {
    if (_selectedLocationOdooId == null) {
      return;
    }
    final visible = _visibleLocations();
    final stillVisible = visible.any(
      (loc) => loc.odooId == _selectedLocationOdooId,
    );
    if (!stillVisible) {
      setState(() => _selectedLocationOdooId = null);
      ref.read(reportDraftProvider.notifier).setLocationOdooId(null);
    }
  }

  List<Location> _visibleLocations() {
    final project = _resolveProjectForSelection();
    if (project == null) {
      return _locations.where((loc) => loc.projectOdooId == null).toList();
    }
    return _locations
        .where(
          (loc) =>
              loc.projectOdooId == null || loc.projectOdooId == project.odooId,
        )
        .toList();
  }

  double _currentHourAsDecimal() {
    final now = DateTime.now();
    return now.hour + (now.minute / 60.0);
  }

  String? _inferQuartFromProject(Project? project) {
    if (project == null || project.dateDJ == null || project.dateDN == null) {
      return null;
    }

    final currentHour = _currentHourAsDecimal();
    final dayStart = project.dateDJ!;
    final nightStart = project.dateDN!;

    if (dayStart == nightStart) {
      return 'Day/Jour';
    }

    if (dayStart < nightStart) {
      if (currentHour >= dayStart && currentHour < nightStart) {
        return 'Day/Jour';
      }
      return 'Night/Nuit';
    }

    final isDay = currentHour >= dayStart || currentHour < nightStart;
    return isDay ? 'Day/Jour' : 'Night/Nuit';
  }

  void _applyAutoQuartFromSelection({bool force = false}) {
    final inferredQuart = _inferQuartFromProject(_resolveProjectForSelection());
    if (inferredQuart == null) {
      return;
    }

    if (!force && _selectedQuart != null && _selectedQuart!.trim().isNotEmpty) {
      return;
    }

    setState(() {
      _selectedQuart = inferredQuart;
    });
    ref.read(reportDraftProvider.notifier).setQuart(inferredQuart);
  }

  Future<void> _goNext() async {
    if (_selectedQuart == null ||
        _selectedForeuseOdooId == null ||
        _selectedLocationOdooId == null ||
        _dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez Quart, Foreuse, Location et Date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hourMeterEnabled && _hourMeterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le compteur horaire est obligatoire.'),backgroundColor: Colors.red),)
      ;
      return;
    }

    final project = _resolveProjectForSelection();
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projet introuvable pour la foreuse selectionnee.'),
        ),
      );
      return;
    }

    final draftNotifier = ref.read(reportDraftProvider.notifier);
    draftNotifier.setQuart(_selectedQuart);
    draftNotifier.setForeuseOdooId(_selectedForeuseOdooId);
    draftNotifier.setLocationOdooId(_selectedLocationOdooId);
    draftNotifier.setDateText(_dateController.text.trim());
    draftNotifier.setFuelMeter(_fuelMeterController.text.trim());
    draftNotifier.setHourMeter(
      _hourMeterEnabled ? _hourMeterController.text.trim() : '',
    );
    draftNotifier.setProjectData(
      projectOdooId: project.odooId,
      projectDateDJ: project.dateDJ,
      projectDateDN: project.dateDN,
    );

    final draft = ref.read(reportDraftProvider);
    final db = ref.read(appDatabaseProvider);
    final mobileUuid = draft.currentMobileUuid ?? const Uuid().v4();
    final feuilleLocalId = await db.saveLocalFeuilleDraft(
      mobileUuid: mobileUuid,
      nomProjetOdooId: project.odooId,
      quart: _selectedQuart!,
      dateForage: _dateController.text.trim(),
      foreuseOdooId: _selectedForeuseOdooId,
      locationOdooId: _selectedLocationOdooId,
      hourMeter: _hourMeterEnabled
          ? double.tryParse(
              _hourMeterController.text.trim().replaceAll(',', '.'),
            )
          : null,
      fuelMeter: _fuelMeterController.text.trim().isEmpty
          ? null
          : _fuelMeterController.text.trim(),
      syncStatus: 'draft',
      existingFeuilleLocalId: draft.currentFeuilleLocalId,
    );
    draftNotifier.setCurrentFeuille(
      feuilleLocalId: feuilleLocalId,
      mobileUuid: mobileUuid,
      syncStatus: 'draft',
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductionScreen(
          quart: _selectedQuart!,
          dateText: _dateController.text.trim(),
          projectOdooId: project.odooId,
          projectDateDJ: project.dateDJ,
          projectDateDN: project.dateDN,
          foreuseOdooId: _selectedForeuseOdooId!,
          locationOdooId: _selectedLocationOdooId!,
          currentFeuilleLocalId: null,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFDF8E1), Color(0xFFF5F5F5)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: _buildGlow(300, _orange.withValues(alpha: 0.07)),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: _buildGlow(360, _navy.withValues(alpha: 0.05)),
          ),
          SafeArea(
            top: false,
            child: _loading
                ? _buildLoadingState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      return isWide
                          ? _buildWideLayout()
                          : _buildCompactLayout();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _softBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 6,
      leadingWidth: 68,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).maybePop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _navy,
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
              'Nouvelle feuille',
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A13233F),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(_orange),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des référentiels…',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A13233F),
                  blurRadius: 44,
                  offset: Offset(0, 24),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 400, child: _buildContextPanel()),
                  Expanded(child: _buildFormPanel(wide: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildContextHero(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A13233F),
                        blurRadius: 32,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: _buildFormPanel(wide: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Contexte (panneau sombre / hero)
  // ---------------------------------------------------------------------------

  Widget _buildContextPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navyLight],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: _buildGlow(240, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -90,
            left: -60,
            child: _buildGlow(230, _orange.withValues(alpha: 0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPanelBadge(size: 80),
                    const SizedBox(height: 26),
                    _buildEyebrow('NOUVELLE FEUILLE'),
                    const SizedBox(height: 8),
                    const Text(
                      'Contexte de forage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Renseignez le shift avant la saisie de la production.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: 52,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _orange,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildSummaryCard(),
                    const SizedBox(height: 22),
                    _buildProgressPanel(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Données enregistrées sur cette tablette',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 58),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navyLight],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPanelBadge(size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEyebrow('NOUVELLE FEUILLE', compact: true),
                    const SizedBox(height: 4),
                    const Text(
                      'Contexte de forage',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Renseignez le shift avant la saisie production.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressPanel(),
        ],
      ),
    );
  }

  Widget _buildPanelBadge({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Icon(Icons.assignment_outlined, color: _orange, size: size * 0.46),
    );
  }

  Widget _buildEyebrow(String text, {bool compact = false}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.48),
        fontSize: compact ? 10.5 : 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: compact ? 1.3 : 1.5,
      ),
    );
  }

  Widget _buildSummaryCard() {
    final foreuseName = _selectedForeuse()?.name;
    final locationName = _selectedLocationName();
    final dateText = _dateController.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            icon: Icons.precision_manufacturing_outlined,
            label: 'Foreuse',
            value: foreuseName,
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            icon: _quartLabel == 'Nuit'
                ? Icons.nightlight_round
                : Icons.wb_sunny_outlined,
            label: 'Quart',
            value: _quartLabel,
            highlight: true,
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            icon: Icons.place_outlined,
            label: 'Location',
            value: locationName,
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            icon: Icons.calendar_month_outlined,
            label: 'Date',
            value: dateText.isEmpty ? null : dateText,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String? value,
    bool highlight = false,
  }) {
    final filled = value != null && value.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 15,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                filled ? value : 'À définir',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled
                      ? (highlight ? _orange : Colors.white)
                      : Colors.white.withValues(alpha: 0.38),
                  fontSize: 13,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPanel() {
    final done = _completedSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PROGRESSION',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Text(
              '$done/6',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < 6; index++) ...[
              if (index > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: 5,
                  decoration: BoxDecoration(
                    color: index < done
                        ? _orange
                        : Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Formulaire
  // ---------------------------------------------------------------------------

  Widget _buildFormPanel({required bool wide}) {
    final quartEnabled = _selectedForeuseOdooId != null;
    final locationEnabled = quartEnabled && (_quartLabel != null);
    final dateEnabled = locationEnabled && _selectedLocationOdooId != null;
    final meterEnabled = dateEnabled;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 24,
        vertical: wide ? 40 : 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'ÉTAPE 1 · CONTEXTE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _orange,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Contexte feuille',
            style: TextStyle(
              color: _textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Renseignez les informations du shift avant la saisie de la production.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            _buildErrorBanner(),
            const SizedBox(height: 20),
          ],
          _buildSection(
            number: '1',
            title: 'Équipement',
            subtitle: 'Sélectionnez la foreuse utilisée sur ce shift.',
            child: _buildForeuseButtons(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            number: '2',
            title: 'Quart / Shift',
            subtitle: quartEnabled
                ? 'Le quart est proposé automatiquement'
                : 'Sélectionnez d\'abord une foreuse.',
            locked: !quartEnabled,
            child: _buildShiftButtons(enabled: quartEnabled),
          ),
          const SizedBox(height: 24),
          _buildSection(
            number: '3',
            title: 'Location',
            subtitle: locationEnabled
                ? 'Zone de forage'
                : 'Sélectionnez d\'abord le quart.',
            locked: !locationEnabled,
            child: _buildLocationButtons(enabled: locationEnabled),
          ),
          const SizedBox(height: 24),
          _buildSection(
            number: '4',
            title: 'Date',
            subtitle: dateEnabled
                ? 'Date de la feuille de forage.'
                : 'Sélectionnez d\'abord une location.',
            locked: !dateEnabled,
            child: Opacity(
              opacity: dateEnabled ? 1 : 0.55,
              child: AbsorbPointer(
                absorbing: !dateEnabled,
                child: _buildDateField(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            number: '5',
            title: 'Compteurs',
            subtitle: meterEnabled
                ? 'Relevés machine du shift.'
                : 'Complétez la date pour activer les compteurs.',
            locked: !meterEnabled,
            child: Opacity(
              opacity: meterEnabled ? 1 : 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildFieldLabel('Hour meter / Compteur horaire'),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Avec compteur',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch.adaptive(
                            value: _hourMeterEnabled,
                            activeColor: _orange,
                            onChanged: meterEnabled
                                ? (value) {
                                    setState(() {
                                      _hourMeterEnabled = value;
                                      if (!value) {
                                        _hourMeterController.clear();
                                      }
                                    });
                                    ref
                                        .read(reportDraftProvider.notifier)
                                        .setHourMeter(
                                          value
                                              ? _hourMeterController.text.trim()
                                              : '',
                                        );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildOptionalTextField(
                    controller: _hourMeterController,
                    hint: meterEnabled
                        ? (_hourMeterEnabled ? 'Obligatoire' : 'Non requis')
                        : 'Complétez d\'abord la date',
                    icon: Icons.timer_outlined,
                    enabled: meterEnabled && _hourMeterEnabled,
                    onChanged: (value) {
                      ref
                          .read(reportDraftProvider.notifier)
                          .setHourMeter(value.trim());
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Fuel meter / Compteur carburant'),
                  _buildOptionalTextField(
                    controller: _fuelMeterController,
                    hint: meterEnabled
                        ? 'Optionnel'
                        : 'Complétez d\'abord la date',
                    icon: Icons.local_gas_station_outlined,
                    enabled: meterEnabled,
                    onChanged: (value) {
                      ref
                          .read(reportDraftProvider.notifier)
                          .setFuelMeter(value.trim());
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _goNext,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: _navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Suivant'),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Étape 1 sur 2 · puis saisie de la production',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildLocalNote(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String subtitle,
    required Widget child,
    bool locked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _fieldFill,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _border),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (locked) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: _muted.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Text(
            subtitle,
            style: TextStyle(
              color: _muted.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _muted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sélections (seul l'élément actif porte la couleur)
  // ---------------------------------------------------------------------------

  Widget _buildChoice({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _orange : _fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _orange : _border,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: selected ? _navy : _muted),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _navy : _chipText,
                    fontSize: 14.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftButtons({required bool enabled}) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Row(
          children: [
            for (var index = 0; index < _quartOptions.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(
                child: _buildChoice(
                  label: _quartOptions[index] == 'Day/Jour' ? 'Jour' : 'Nuit',
                  icon: _quartOptions[index] == 'Day/Jour'
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round,
                  selected: _selectedQuart == _quartOptions[index],
                  onTap: () {
                    setState(() => _selectedQuart = _quartOptions[index]);
                    ref
                        .read(reportDraftProvider.notifier)
                        .setQuart(_quartOptions[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForeuseButtons() {
    if (_foreuses.isEmpty) {
      return _buildNotice(
        'Aucune foreuse disponible pour votre périmètre.',
        Icons.precision_manufacturing_outlined,
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _foreuses
          .map((item) {
            final selected = _selectedForeuseOdooId == item.odooId;
            return _buildChoice(
              label: item.name,
              icon: Icons.precision_manufacturing_outlined,
              selected: selected,
              onTap: () {
                setState(() => _selectedForeuseOdooId = item.odooId);
                ref
                    .read(reportDraftProvider.notifier)
                    .setForeuseOdooId(item.odooId);
                _applyAutoQuartFromSelection(force: true);
                _resetLocationIfOutOfScope();
              },
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildLocationButtons({required bool enabled}) {
    final visible = _visibleLocations();
    if (visible.isEmpty) {
      return _buildNotice(
        _selectedForeuseOdooId == null
            ? 'Sélectionnez d\'abord une foreuse.'
            : 'Aucune location disponible pour ce projet.',
        Icons.place_outlined,
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: visible
              .map((item) {
                final selected = _selectedLocationOdooId == item.odooId;
                return _buildChoice(
                  label: item.name,
                  icon: Icons.place_outlined,
                  selected: selected,
                  onTap: () {
                    setState(() => _selectedLocationOdooId = item.odooId);
                    ref
                        .read(reportDraftProvider.notifier)
                        .setLocationOdooId(item.odooId);
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  Widget _buildNotice(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _muted.withValues(alpha: 0.95),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Champs
  // ---------------------------------------------------------------------------

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: const TextStyle(
        color: _textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(
        hint: 'jj/mm/aaaa',
        icon: Icons.calendar_month_outlined,
        suffix: const Icon(
          Icons.edit_calendar_outlined,
          size: 20,
          color: _orange,
        ),
      ),
    );
  }

  Widget _buildOptionalTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // Chiffres + au maximum un separateur decimal ('.' ou ',').
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (RegExp(r'^\d*([.,]\d*)?$').hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      onChanged: onChanged,
      style: const TextStyle(
        color: _textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: _orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _orange, width: 1.6),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bandeaux
  // ---------------------------------------------------------------------------

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF6C9C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFFD64545),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFF9B2C2C),
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _softBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: _orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vos données restent enregistrées sur la tablette jusqu\'à la synchronisation.',
              style: TextStyle(
                color: _muted.withValues(alpha: 0.95),
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
