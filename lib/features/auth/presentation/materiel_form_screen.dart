import 'dart:math' as math;

import 'package:aurora_drilling_report/data/local/db/app_database.dart';
import 'package:aurora_drilling_report/shared/providers/app_providers.dart';
import 'package:aurora_drilling_report/shared/providers/report_draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  ConsumerState<DrillingConsumableForm> createState() =>
      _DrillingConsumableFormState();
}

class _DrillingConsumableFormState
    extends ConsumerState<DrillingConsumableForm> {
  static const Map<String, String> _statusOptions = {
    '': 'Aucun',
    '1': 'Usee',
    '2': 'En panne',
    '3': 'Bon Etat',
  };

  static const Color _accentOrange = Color(0xFFF18E28);
  static const Color _designNavy = Color(0xFF13233F);
  static const Color _designNavyLight = Color(0xFF1E3A5F);
  static const Color _textDark = Color(0xFF18243E);
  static const Color _muted = Color(0xFF69758C);
  static const Color _border = Color(0xFFD7DFEA);
  static const Color _softBg = Color(0xFFFDF8E1);
  static const Color _fieldBg = Color(0xFFF3F6FB);

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  final List<_ConsumableLogDraft> _items = [];
  List<MaterialReference> _materialReferences = [];
  bool _loadingReferences = true;
  String? _referenceError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    if (draft.materielLogs.isNotEmpty) {
      _items.addAll(
        draft.materielLogs.map(_ConsumableLogDraft.fromReportDraft),
      );
    }
    Future.microtask(_loadMaterialReferences);
  }

  @override
  void dispose() {
    // Ne pas appeler _persistDraft() ici : il fait ref.read(...notifier).setMaterielLogs
    // + Future.microtask, ce qui peut faire tourner du code apres que ce State soit
    // detruit et provoquer l'assertion _dependents.isEmpty. Le draft est deja persiste
    // a chaque onChanged/setState precedent.
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
      materials.sort(
        (a, b) =>
            a.description.toLowerCase().compareTo(b.description.toLowerCase()),
      );

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
    if (!mounted) {
      return;
    }
    // Differer a apres le frame courant pour eviter que le notify de Riverpod
    // ne se propage pendant qu'un rebuild est deja en cours (source du crash
    // _dependents.isEmpty lors du clic 'Valider' du clavier numerique).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(reportDraftProvider.notifier)
          .setMaterielLogs(
            _items.map((item) => item.toReportDraft()).toList(growable: false),
          );
      _autoSaveMaterielLogs();
    });
  }

  Future<void> _autoSaveMaterielLogs() async {
    final draft = ref.read(reportDraftProvider);
    final feuilleLocalId = draft.currentFeuilleLocalId;
    if (feuilleLocalId == null) {
      return;
    }

    final uuid = const Uuid();
    final rows = _items
        .where(
          (item) =>
              item.descriptionController.text.trim().isNotEmpty ||
              item.serie.text.trim().isNotEmpty,
        )
        .map(
          (item) => <String, dynamic>{
            'mobile_uuid': uuid.v4(),
            'description': item.descriptionController.text.trim().isEmpty
                ? null
                : item.descriptionController.text.trim(),
            'serial_number': item.serie.text.trim().isEmpty
                ? null
                : item.serie.text.trim(),
            'quantity': double.tryParse(item.quantite.text.trim()),
            'observation': item.observation.text.trim().isEmpty
                ? null
                : item.observation.text.trim(),
            'status': item.status.text.trim().isEmpty
                ? null
                : item.status.text.trim(),
          },
        )
        .toList(growable: false);

    await ref
        .read(appDatabaseProvider)
        .replaceFeuilleMaterielsDraft(
          feuilleLocalId: feuilleLocalId,
          rows: rows,
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
                filtered = _materialReferences
                    .where((material) {
                      if (_isMaterialAlreadyAdded(material.odooId)) {
                        return false;
                      }
                      if (normalized.isEmpty) {
                        return true;
                      }
                      final haystack =
                          '${material.reference ?? ''} ${material.description}'
                              .toLowerCase();
                      return haystack.contains(normalized);
                    })
                    .toList(growable: false);
              });
            }

            // Dialog bulletproof : SingleChildScrollView englobe TOUT.
            // La liste a une hauteur bornee (max 300, virtualisee) → jamais
            // de freeze meme avec 1000+ items. Si la hauteur totale (titre +
            // recherche + liste + bouton) depasse l'espace du dialog (rotation
            // paysage + clavier), le tout devient scrollable → AUCUN overflow.
            final mq = MediaQuery.of(context);
            final keyboardOpen = mq.viewInsets.bottom > 0;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: keyboardOpen ? 8 : 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: mq.viewInsets.bottom.clamp(0.0, 32.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _accentOrange.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_box_outlined,
                                size: 20,
                                color: _accentOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Ajouter un materiel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller,
                          onChanged: applyFilter,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un materiel',
                            hintStyle: const TextStyle(color: _muted),
                            prefixIcon: const Icon(Icons.search, color: _muted),
                            isDense: true,
                            filled: true,
                            fillColor: _fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _accentOrange,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Aucun materiel disponible.',
                                style: TextStyle(color: _muted),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: math.min(filtered.length * 72.0, 300.0),
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final material = filtered[index];
                                return Material(
                                  color: _fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                  child: ListTile(
                                    dense: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      material.reference?.isNotEmpty == true
                                          ? material.reference!
                                          : '--',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    subtitle: Text(
                                      material.description,
                                      style: const TextStyle(color: _muted),
                                    ),
                                    trailing: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: _accentOrange,
                                    ),
                                    onTap: () =>
                                        Navigator.pop(context, material),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: _designNavy,
                            ),
                            child: const Text('Fermer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        child: LinearProgressIndicator(
          color: _accentOrange,
          backgroundColor: Color(0xFFF0E4BC),
        ),
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
      children: _statusOptions.entries
          .map((entry) {
            final selected = normalizedValue == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() {
                  item.status.text = entry.key;
                });
                _persistDraft();
              },
              labelStyle: TextStyle(
                color: _designNavy,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              selectedColor: _accentOrange,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? _accentOrange : _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildQuantityField(_ConsumableLogDraft item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.quantite, -1),
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: _accentOrange,
            ),
            tooltip: 'Diminuer',
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
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _updateQuantity(item.quantite, 1),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: _accentOrange,
            ),
            tooltip: 'Augmenter',
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
      style: const TextStyle(color: _textDark),
      decoration: InputDecoration(
        hintText: 'Ajouter une observation si necessaire',
        hintStyle: const TextStyle(color: _muted),
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accentOrange, width: 1.6),
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
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F13233F),
            blurRadius: 14,
            offset: Offset(0, 6),
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
                        item.serie.text.trim().isEmpty
                            ? '--'
                            : item.serie.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.descriptionController.text.trim().isEmpty
                            ? 'Materiel non renseigne'
                            : item.descriptionController.text.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Supprimer',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _fieldBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Quantite'),
            const SizedBox(height: 8),
            _buildQuantityField(item),
            const SizedBox(height: 16),
            _buildFieldLabel('Status'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: _accentOrange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.observation.text.trim().isEmpty
                            ? 'Ajouter une observation'
                            : 'Observation renseignee',
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      item.showObservation
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _muted,
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_designNavy, _designNavyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2213233F),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SHIFT EN COURS',
                style: TextStyle(
                  color: _accentOrange,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Materiel du shift',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_items.length} materiel(s) selectionne(s) pour cette feuille.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _materialReferences.isEmpty
                  ? null
                  : _openAddMaterialDialog,
              icon: const Icon(Icons.add_box_outlined, size: 20),
              label: const Text('Ajouter un materiel'),
              style: FilledButton.styleFrom(
                backgroundColor: _accentOrange,
                foregroundColor: _designNavy,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Precedent'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _designNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                _persistDraft();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DrillingFuelForm()),
                );
              },
              label: const Text('Suivant'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              style: FilledButton.styleFrom(
                backgroundColor: _accentOrange,
                foregroundColor: _designNavy,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: _softBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 6,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Retour',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _designNavy,
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
                'Materiel',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _accentOrange,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: _designNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_items.length}',
                      style: const TextStyle(
                        color: _designNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _accentOrange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 30,
                              color: _accentOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun materiel selectionne',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ajoute seulement les materiels utilises sur cette feuille.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted),
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
