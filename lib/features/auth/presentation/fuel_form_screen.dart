import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recap_screen.dart';

class _FuelLogDraft {
  _FuelLogDraft();

  _FuelLogDraft.fromReportDraft(ReportFuelLogDraft draft) {
    equipmentOdooId = draft.equipmentOdooId;
    equipementId.text = draft.equipement;
    qtyFuel.text = draft.qtyFuel;
    hDebut.text = draft.hDebut;
    hFin.text = draft.hFin;
    hDebutRavi.text = draft.hDebutRavi;
    hFinRavi.text = draft.hFinRavi;
  }

  int? equipmentOdooId;
  final TextEditingController equipementId = TextEditingController();
  final TextEditingController qtyFuel = TextEditingController(text: '0');
  final TextEditingController hDebut = TextEditingController();
  final TextEditingController hFin = TextEditingController();
  final TextEditingController hDebutRavi = TextEditingController();
  final TextEditingController hFinRavi = TextEditingController();

  ReportFuelLogDraft toReportDraft() {
    return ReportFuelLogDraft(
      equipmentOdooId: equipmentOdooId,
      equipement: equipementId.text,
      qtyFuel: qtyFuel.text,
      hDebut: hDebut.text,
      hFin: hFin.text,
      hDebutRavi: hDebutRavi.text,
      hFinRavi: hFinRavi.text,
    );
  }

  void applyEquipment(Equipment equipment) {
    equipmentOdooId = equipment.odooId;
    equipementId.text = equipment.name;
  }

  void clearEquipmentSelection() {
    equipmentOdooId = null;
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
  final List<_FuelLogDraft> _items = [];
  final ScrollController _scrollController = ScrollController();

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
    _persistDraft();
    _scrollController.dispose();
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
      final filtered = allEquipments.where((equipment) {
        final equipmentProjectId = equipment.projectOdooId;
        return equipmentProjectId == null || equipmentProjectId == projectId;
      }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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

    final foreuse = _findEquipmentMatch(equipmentOdooId: foreuseId);
    if (foreuse == null) {
      return;
    }

    for (final item in _items) {
      if (item.equipmentOdooId == foreuse.odooId) {
        item.applyEquipment(foreuse);
        return;
      }
    }

    final row = _FuelLogDraft()..applyEquipment(foreuse);
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
      if (item.equipmentOdooId != match.odooId || item.equipementId.text != match.name) {
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
    ref.read(reportDraftProvider.notifier).setFuelLogs(
          _items.map((item) => item.toReportDraft()).toList(),
        );
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

  void _addItem() {
    setState(() {
      _items.add(_FuelLogDraft());
    });
    _persistDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  void _showTimeSpinner(BuildContext context, TextEditingController controller) {
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      controller.text =
                          '${newDate.hour.toString().padLeft(2, '0')}:${newDate.minute.toString().padLeft(2, '0')}';
                    });
                    _persistDraft();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applySelectedEquipment(_FuelLogDraft item, Equipment equipment) {
    setState(() {
      item.applyEquipment(equipment);
    });
    _persistDraft();
  }

  void _handleEquipmentChanged(_FuelLogDraft item, String value) {
    item.equipementId.text = value;
    final match = _findEquipmentMatch(name: value);

    setState(() {
      if (match != null) {
        item.applyEquipment(match);
      } else {
        item.clearEquipmentSelection();
      }
    });
    _persistDraft();
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildReferenceStatus() {
    if (_loadingReferences) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LinearProgressIndicator(),
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

  Widget _buildSearchableDropdown(String label, _FuelLogDraft item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: RawAutocomplete<Equipment>(
                    displayStringForOption: (option) => option.name,
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return _availableEquipments;
                      }
                      return _availableEquipments.where(
                        (option) => option.name.toLowerCase().contains(query),
                      );
                    },
                    onSelected: (selection) => _applySelectedEquipment(item, selection),
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 520),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option.name),
                                  subtitle: Text(option.categoryName?.isNotEmpty == true ? option.categoryName! : '--'),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (item.equipementId.text.isNotEmpty && controller.text != item.equipementId.text) {
                        controller.value = TextEditingValue(
                          text: item.equipementId.text,
                          selection: TextSelection.collapsed(offset: item.equipementId.text.length),
                        );
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) => _handleEquipmentChanged(item, value),
                        decoration: const InputDecoration(
                          hintText: 'Selectionnez un equipement',
                          suffixIcon: Icon(Icons.search, size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove, size: 18, color: Colors.redAccent),
                  onPressed: () => _updateQuantity(controller, -1),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    onChanged: (_) => _persistDraft(),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add, size: 18, color: Colors.green),
                  onPressed: () => _updateQuantity(controller, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpinnerInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showTimeSpinner(context, controller),
          child: AbsorbPointer(
            child: Container(
              decoration: _fieldDecoration(),
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

  Widget _buildFuelCard(int index) {
    final item = _items[index];
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
                Text('EQUIP/AUX #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 22),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchableDropdown('Equipement', item),
                const SizedBox(height: 16),
                _buildQuantityInput('Qty Fuel', item.qtyFuel),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSpinnerInput('Heure. D', item.hDebut)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSpinnerInput('Heure. F', item.hFin)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSpinnerInput('H. Debut Ravi', item.hDebutRavi)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSpinnerInput('H. Fin Ravi', item.hFinRavi)),
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
              onTap: _addItem,
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
                    Text('Ajouter une ligne', style: TextStyle(color: Color(0xFF00C7C9), fontWeight: FontWeight.bold, fontSize: 13)),
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
                    builder: (_) => const RecapScreen(),
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
        title: const Text('EQUIPEMENT AUXILLIAIRE / FUEL', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildReferenceStatus();
          }
          final rowIndex = index - 1;
          if (rowIndex == _items.length) {
            return _buildActionButtons();
          }
          return _buildFuelCard(rowIndex);
        },
      ),
    );
  }
}
