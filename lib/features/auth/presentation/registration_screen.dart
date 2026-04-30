import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'production_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const List<String> _quartOptions = ['Day/Jour', 'Night/Nuit'];

  String? _selectedQuart;
  int? _selectedForeuseOdooId;
  int? _selectedLocationOdooId;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fuelMeterController = TextEditingController();
  final TextEditingController _hourMeterController = TextEditingController();

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
    _dateController.text = draft.dateText ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
    _fuelMeterController.text = draft.fuelMeter;
    _hourMeterController.text = draft.hourMeter;
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
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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

  void _goNext() {
    if (_selectedQuart == null ||
        _selectedForeuseOdooId == null ||
        _selectedLocationOdooId == null ||
        _dateController.text.trim().isEmpty ||
        _hourMeterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez Quart, Foreuse, Location, Date et Compteur horaire.'),
        ),
      );
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
    draftNotifier.setHourMeter(_hourMeterController.text.trim());
    draftNotifier.setProjectData(
      projectOdooId: project.odooId,
      projectDateDJ: project.dateDJ,
      projectDateDN: project.dateDN,
    );

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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        isExpanded: true,
        decoration: _inputDecoration(),
        items: items,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: _inputDecoration().copyWith(
          suffixIcon: const Icon(
            Icons.calendar_month,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }


  Widget _buildShiftButtons({required bool enabled}) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Row(
        children: _quartOptions.map((quart) {
          final selected = _selectedQuart == quart;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: quart == _quartOptions.last ? 0 : 12),
              child: InkWell(
                onTap: enabled
                    ? () {
                        setState(() => _selectedQuart = quart);
                        ref.read(reportDraftProvider.notifier).setQuart(quart);
                      }
                    : null,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E3A5F) : const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      quart == 'Day/Jour' ? 'Jour' : 'Nuit',
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF374151),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildOptionalTextField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: _inputDecoration().copyWith(
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildNavButton(
    String label,
    Color color,
    IconData icon, {
    required bool isLeading,
  }) {
    return InkWell(
      onTap: _goNext,
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
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (!isLeading) Icon(icon, color: Colors.white, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: _buildNavButton(
              'Suivant',
              const Color(0xFF374151),
              Icons.arrow_forward_ios,
              isLeading: false,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFCBD5E0)),
        borderRadius: BorderRadius.circular(4),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quartEnabled = _selectedForeuseOdooId != null;
    final locationEnabled = quartEnabled && (_selectedQuart?.trim().isNotEmpty ?? false);
    final dateEnabled = locationEnabled && _selectedLocationOdooId != null;
    final meterEnabled = dateEnabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'RAPPORT DE FORAGE',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8,
                    shadowColor: const Color(0x14000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contexte feuille',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                          ],
                          _buildLabel('Foreuse *'),
                          _buildDropdownField<int>(
                            hint: 'Choisissez...',
                            value: _selectedForeuseOdooId,
                            items: _foreuses
                                .map(
                                  (item) => DropdownMenuItem<int>(
                                    value: item.odooId,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedForeuseOdooId = value);
                              ref.read(reportDraftProvider.notifier).setForeuseOdooId(value);
                              _applyAutoQuartFromSelection(force: true);
                            },
                          ),
                          const SizedBox(height: 25),
                          _buildLabel('Quart/Shift *'),
                          _buildShiftButtons(enabled: quartEnabled),
                          const SizedBox(height: 25),
                          _buildLabel('Location *'),
                          _buildDropdownField<int>(
                            hint: locationEnabled ? 'Choisissez...' : 'Selectionnez d abord le quart',
                            value: _selectedLocationOdooId,
                            enabled: locationEnabled,
                            items: _locations
                                .map(
                                  (item) => DropdownMenuItem<int>(
                                    value: item.odooId,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedLocationOdooId = value);
                              ref.read(reportDraftProvider.notifier).setLocationOdooId(value);
                            },
                          ),
                          const SizedBox(height: 25),
                          _buildLabel('Date *'),
                          AbsorbPointer(
                            absorbing: !dateEnabled,
                            child: Opacity(
                              opacity: dateEnabled ? 1 : 0.55,
                              child: _buildDateField(),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildLabel('Hour meter / Compteur horaire *'),
                          _buildOptionalTextField(
                            controller: _hourMeterController,
                            hint: meterEnabled ? 'Obligatoire' : 'Selectionnez d abord la date',
                            enabled: meterEnabled,
                            onChanged: (value) => ref.read(reportDraftProvider.notifier).setHourMeter(value.trim()),
                          ),
                          const SizedBox(height: 25),
                           _buildLabel('Fuel meter / Compteur carburant'),
                          _buildOptionalTextField(
                            controller: _fuelMeterController,
                            hint: meterEnabled ? 'Optionnel' : 'Selectionnez d abord la date',
                            enabled: meterEnabled,
                            onChanged: (value) => ref.read(reportDraftProvider.notifier).setFuelMeter(value.trim()),
                          ),
                          const SizedBox(height: 25),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
