import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fuel_form_screen.dart';

class _ConsumableLogDraft {
  _ConsumableLogDraft();

  _ConsumableLogDraft.fromReportDraft(ReportMaterielDraft draft) {
    materialOdooId = draft.materialOdooId;
    descriptionController.text = draft.description;
    serie.text = draft.serie;
    quantite.text = draft.quantite;
    observation.text = draft.observation;
    status.text = draft.status;
  }

  int? materialOdooId;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController serie = TextEditingController();
  final TextEditingController quantite = TextEditingController(text: '0');
  final TextEditingController observation = TextEditingController();
  final TextEditingController status = TextEditingController();

  ReportMaterielDraft toReportDraft() {
    return ReportMaterielDraft(
      materialOdooId: materialOdooId,
      description: descriptionController.text,
      serie: serie.text,
      quantite: quantite.text,
      observation: observation.text,
      status: status.text,
    );
  }

  void applyMaterial(MaterialReference material) {
    materialOdooId = material.odooId;
    descriptionController.text = material.description;
    serie.text = material.reference ?? '';
  }

  void clearMaterialSelection({bool clearSerie = true}) {
    materialOdooId = null;
    if (clearSerie) {
      serie.text = '';
    }
  }

  void dispose() {
    descriptionController.dispose();
    serie.dispose();
    quantite.dispose();
    observation.dispose();
    status.dispose();
  }
}

class DrillingConsumableForm extends ConsumerStatefulWidget {
  const DrillingConsumableForm({super.key});

  @override
  ConsumerState<DrillingConsumableForm> createState() => _DrillingConsumableFormState();
}

class _DrillingConsumableFormState extends ConsumerState<DrillingConsumableForm> {
  static const Map<String, String> _statusOptions = {
    '': 'Aucun',
    '1': 'Usee',
    '2': 'En panne',
    '3': 'Bon Etat',
  };

  final List<_ConsumableLogDraft> _items = [];
  final ScrollController _scrollController = ScrollController();

  List<MaterialReference> _materialReferences = [];
  bool _loadingReferences = true;
  String? _referenceError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    if (draft.materielLogs.isNotEmpty) {
      _items.addAll(draft.materielLogs.map(_ConsumableLogDraft.fromReportDraft));
    }
    Future.microtask(_loadMaterialReferences);
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

  Future<void> _loadMaterialReferences() async {
    setState(() {
      _loadingReferences = true;
      _referenceError = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final materials = await db.getAllMaterialReferences();
      materials.sort((a, b) => a.description.toLowerCase().compareTo(b.description.toLowerCase()));

      if (!mounted) {
        return;
      }

      setState(() {
        _materialReferences = materials;
        _loadingReferences = false;
      });
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

  void _refreshDraftRowsFromReferences() {
    var changed = false;
    for (final item in _items) {
      final match = _findMaterialMatch(
        materialOdooId: item.materialOdooId,
        description: item.descriptionController.text,
      );
      if (match == null) {
        continue;
      }
      if (item.materialOdooId != match.odooId || item.serie.text != (match.reference ?? '')) {
        item.applyMaterial(match);
        changed = true;
      }
    }
    if (changed) {
      _persistDraft();
    }
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setMaterielLogs(
          _items.map((item) => item.toReportDraft()).toList(),
        );
  }

  MaterialReference? _findMaterialMatch({int? materialOdooId, String? description}) {
    if (materialOdooId != null) {
      for (final material in _materialReferences) {
        if (material.odooId == materialOdooId) {
          return material;
        }
      }
    }

    final normalized = (description ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final material in _materialReferences) {
      if (material.description.trim().toLowerCase() == normalized) {
        return material;
      }
    }
    return null;
  }

  MaterialReference? _findMaterialMatchByReference(String? reference) {
    final normalized = (reference ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final material in _materialReferences) {
      if ((material.reference ?? '').trim().toLowerCase() == normalized) {
        return material;
      }
    }
    return null;
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
      _items.add(_ConsumableLogDraft());
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

  void _applySelectedMaterial(_ConsumableLogDraft item, MaterialReference material) {
    setState(() {
      item.applyMaterial(material);
    });
    _persistDraft();
  }

  void _handleDescriptionChanged(_ConsumableLogDraft item, String value) {
    item.descriptionController.text = value;
    final match = _findMaterialMatch(description: value);

    setState(() {
      if (match != null) {
        item.applyMaterial(match);
      } else {
        item.clearMaterialSelection();
      }
    });
    _persistDraft();
  }

  void _handleReferenceChanged(_ConsumableLogDraft item, String value) {
    item.serie.text = value;
    final match = _findMaterialMatchByReference(value);

    setState(() {
      if (match != null) {
        item.applyMaterial(match);
      } else {
        item.materialOdooId = null;
      }
    });
    _persistDraft();
  }

  BoxDecoration _fieldDecoration({required bool isReadOnly}) {
    return BoxDecoration(
      color: isReadOnly ? const Color(0xFFF3F4F6) : Colors.white,
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
    if (_materialReferences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Aucun materiel de reference charge. Rechargez le bootstrap.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(isReadOnly: false),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        controller.text = '0';
                        controller.selection = TextSelection.fromPosition(
                          const TextPosition(offset: 1),
                        );
                      }
                      _persistDraft();
                    },
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

  Widget _buildSearchableDropdown(String label, _ConsumableLogDraft item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(isReadOnly: false),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: RawAutocomplete<MaterialReference>(
                    displayStringForOption: (option) => option.description,
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return _materialReferences;
                      }
                      return _materialReferences.where((option) {
                        final description = option.description.toLowerCase();
                        final reference = (option.reference ?? '').toLowerCase();
                        return description.contains(query) || reference.contains(query);
                      });
                    },
                    onSelected: (selection) => _applySelectedMaterial(item, selection),
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
                                  title: Text(option.description),
                                  subtitle: Text(option.reference?.isNotEmpty == true ? option.reference! : '--'),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (item.descriptionController.text.isNotEmpty &&
                          controller.text != item.descriptionController.text) {
                        controller.value = TextEditingValue(
                          text: item.descriptionController.text,
                          selection: TextSelection.collapsed(offset: item.descriptionController.text.length),
                        );
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) => _handleDescriptionChanged(item, value),
                        decoration: const InputDecoration(
                          hintText: 'Selectionnez un materiel',
                          suffixIcon: Icon(Icons.unfold_more, size: 18),
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

  Widget _buildReferenceAutocomplete(String label, _ConsumableLogDraft item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(isReadOnly: false),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: RawAutocomplete<MaterialReference>(
                    displayStringForOption: (option) => option.reference ?? '',
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return _materialReferences.where((option) => (option.reference ?? '').trim().isNotEmpty);
                      }
                      return _materialReferences.where((option) {
                        final reference = (option.reference ?? '').toLowerCase();
                        final description = option.description.toLowerCase();
                        return reference.contains(query) || description.contains(query);
                      });
                    },
                    onSelected: (selection) => _applySelectedMaterial(item, selection),
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
                                  title: Text(option.reference?.isNotEmpty == true ? option.reference! : '--'),
                                  subtitle: Text(option.description),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (item.serie.text.isNotEmpty && controller.text != item.serie.text) {
                        controller.value = TextEditingValue(
                          text: item.serie.text,
                          selection: TextSelection.collapsed(offset: item.serie.text.length),
                        );
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) => _handleReferenceChanged(item, value),
                        decoration: const InputDecoration(
                          hintText: 'Saisir ou choisir une reference',
                          suffixIcon: Icon(Icons.unfold_more, size: 18),
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

  String _normalizeStatusValue(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case '1':
      case 'usee':
      case 'us?e':
        return '1';
      case '2':
      case 'en panne':
        return '2';
      case '3':
      case 'bon etat':
      case 'bon ?tat':
        return '3';
      default:
        return '';
    }
  }

  Widget _buildStatusDropdown(_ConsumableLogDraft item) {
    final normalizedValue = _statusOptions.containsKey(item.status.text) ? item.status.text : _normalizeStatusValue(item.status.text);
    if (item.status.text != normalizedValue) {
      item.status.text = normalizedValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(isReadOnly: false),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Colors.red),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: normalizedValue,
                    items: _statusOptions.entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        item.status.text = value ?? '';
                      });
                      _persistDraft();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      isDense: true,
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardInput(String label, TextEditingController controller, {bool isReadOnly = false}) {
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
                    onChanged: (_) => _persistDraft(),
                    style: TextStyle(fontSize: 13, color: isReadOnly ? Colors.grey : const Color(0xFF1F2937)),
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

  Widget _buildNavButton(
    String label,
    Color color,
    IconData icon,
    bool isLeading, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLeading) Icon(icon, color: Colors.white, size: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            if (!isLeading) ...[
              const SizedBox(width: 4),
              Icon(icon, color: Colors.white, size: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsumableCard(int index) {
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
                Text(
                  'MATERIEL #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
                ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildReferenceAutocomplete('Serie / Reference', item)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSearchableDropdown('Description', item)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuantityInput('Quantite', item.quantite),
                const SizedBox(height: 16),
                _buildStandardInput('Observation', item.observation),
                const SizedBox(height: 16),
                _buildStatusDropdown(item),
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
            child: _buildNavButton(
              'Precedent',
              const Color(0xFF374151),
              Icons.arrow_back_ios,
              true,
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
                    Text(
                      'Ajouter une ligne',
                      style: TextStyle(color: Color(0xFF00C7C9), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNavButton(
              'Suivant',
              const Color(0xFF374151),
              Icons.arrow_forward_ios,
              false,
              onTap: () {
                _persistDraft();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DrillingFuelForm(),
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
          'MATERIELS',
          style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        ),
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
          return _buildConsumableCard(rowIndex);
        },
      ),
    );
  }
}
