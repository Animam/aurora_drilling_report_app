import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fuel_form_screen.dart';

class _ConsumableLogDraft {
  _ConsumableLogDraft({
    required this.showObservation,
    this.materialOdooId,
    String description = '',
    String serie = '',
    String quantite = '0',
    String observation = '',
    String status = '',
  }) {
    descriptionController.text = description;
    this.serie.text = serie;
    this.quantite.text = quantite;
    this.observation.text = observation;
    this.status.text = status;
  }

  _ConsumableLogDraft.fromReportDraft(ReportMaterielDraft draft)
      : materialOdooId = draft.materialOdooId,
        showObservation = draft.observation.trim().isNotEmpty {
    descriptionController.text = draft.description;
    serie.text = draft.serie;
    quantite.text = draft.quantite;
    observation.text = draft.observation;
    status.text = draft.status;
  }

  int? materialOdooId;
  bool showObservation;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController serie = TextEditingController();
  final TextEditingController quantite = TextEditingController(text: '0');
  final TextEditingController observation = TextEditingController();
  final TextEditingController status = TextEditingController();

  ReportMaterielDraft toReportDraft() {
    return ReportMaterielDraft(
      materialOdooId: materialOdooId,
      description: descriptionController.text.trim(),
      serie: serie.text.trim(),
      quantite: quantite.text.trim(),
      observation: observation.text.trim(),
      status: status.text.trim(),
    );
  }

  void applyMaterial(MaterialReference material) {
    materialOdooId = material.odooId;
    descriptionController.text = material.description;
    serie.text = material.reference ?? '';
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
      if (item.materialOdooId == null) {
        continue;
      }
      for (final material in _materialReferences) {
        if (material.odooId == item.materialOdooId) {
          item.applyMaterial(material);
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      _persistDraft();
    }
  }

  void _persistDraft() {
    ref.read(reportDraftProvider.notifier).setMaterielLogs(
          _items.map((item) => item.toReportDraft()).toList(growable: false),
        );
  }

  bool _isMaterialAlreadyAdded(int materialOdooId) {
    return _items.any((item) => item.materialOdooId == materialOdooId);
  }

  Future<void> _openAddMaterialDialog() async {
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
      return;
    }

    setState(() {
      _items.add(
        _ConsumableLogDraft(
          showObservation: false,
          materialOdooId: selectedMaterial.odooId,
          description: selectedMaterial.description,
          serie: selectedMaterial.reference ?? '',
        ),
      );
    });
    _persistDraft();
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
        child: Text(_referenceError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_materialReferences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Aucun materiel de reference charge.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusChips(_ConsumableLogDraft item) {
    final normalizedValue = _statusOptions.containsKey(item.status.text)
        ? item.status.text
        : _normalizeStatusValue(item.status.text);
    if (item.status.text != normalizedValue) {
      item.status.text = normalizedValue;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusOptions.entries.map((entry) {
        final selected = normalizedValue == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: selected,
          onSelected: (_) {
            setState(() {
              item.status.text = entry.key;
            });
            _persistDraft();
          },
        );
      }).toList(growable: false),
    );
  }

  Widget _buildQuantityField(_ConsumableLogDraft item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DFEA)),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.quantite, -1),
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
          ),
          Expanded(
            child: TextField(
              controller: item.quantite,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _persistDraft(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.quantite, 1),
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationField(_ConsumableLogDraft item) {
    return TextField(
      controller: item.observation,
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

  Widget _buildConsumableCard(int index) {
    final item = _items[index];
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
                        item.serie.text.trim().isEmpty ? '--' : item.serie.text.trim(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.descriptionController.text.trim().isEmpty
                            ? 'Materiel non renseigne'
                            : item.descriptionController.text.trim(),
                        style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
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
            const Text(
              'Quantite',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildQuantityField(item),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildStatusChips(item),
            const SizedBox(height: 14),
            InkWell(
              onTap: () {
                setState(() {
                  item.showObservation = !item.showObservation;
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
                        item.observation.text.trim().isEmpty ? 'Ajouter une observation' : 'Observation renseignee',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      item.showObservation ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: const Color(0xFF475569),
                    ),
                  ],
                ),
              ),
            ),
            if (item.showObservation) ...[
              const SizedBox(height: 12),
              _buildObservationField(item),
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
            'Materiels du shift',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_items.length} materiel(s) selectionne(s) pour cette feuille.',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _materialReferences.isEmpty ? null : _openAddMaterialDialog,
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Ajouter un materiel'),
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
              style:OutlinedButton.styleFrom(
                 padding:  EdgeInsets.symmetric(vertical: 23)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                _persistDraft();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DrillingFuelForm(),
                  ),
                );
              },
              label: const Text('Suivant'),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
          'Materiels',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReferenceStatus(),
                  _buildTopActions(),
                  const SizedBox(height: 18),
                  if (_items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 42, color: Color(0xFF64748B)),
                          SizedBox(height: 12),
                          Text(
                            'Aucun materiel selectionne',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ajoute seulement les materiels utilises sur cette feuille.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_items.length, _buildConsumableCard),
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



