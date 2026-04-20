import 'package:aurora_drilling_report/features/auth/presentation/post_login_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_providers.dart';
import '../../../shared/providers/app_providers.dart';

Future<void> ensureReferenceData(WidgetRef ref) async {
  final db = ref.read(appDatabaseProvider);

  final localProjects = await db.getAllProjects();
  final localEmployees = await db.getAllEmployees();
  final localEquipments = await db.getAllEquipments();
  final localTasks = await db.getAllTasks();
  final localLocations = await db.getAllLocations();
  final localMaterials = await db.getAllMaterialReferences();

  final hasReferenceData = localProjects.isNotEmpty &&
      localEmployees.isNotEmpty &&
      localEquipments.isNotEmpty &&
      localTasks.isNotEmpty &&
      localLocations.isNotEmpty &&
      localMaterials.isNotEmpty;

  if (hasReferenceData) {
    return;
  }

  final api = ref.read(bootstrapApiProvider);
  final result = await api.fetchBootstrap();

  final projects = (result['projects'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final employees = (result['employees'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final equipments = (result['equipments'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final tasks = (result['tasks'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final locations = (result['locations'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final materials = (result['materials'] as List<dynamic>? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();

  await db.saveProjects(projects);
  await db.saveEmployees(employees);
  await db.saveEquipments(equipments);
  await db.saveTasks(tasks);
  await db.saveLocations(locations);
  await db.saveMaterialReferences(materials);
}


class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  bool _loading = false;
  String? _error;

  int _projectsCount = 0;
  int _employeesCount = 0;
  int _equipmentsCount = 0;
  int _tasksCount = 0;
  int _locationsCount = 0;
  int _materialsCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_ensureReferenceData);
  }

  Future<void> _ensureReferenceData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      _setCounts(
        projects: (await db.getAllProjects()).length,
        employees: (await db.getAllEmployees()).length,
        equipments: (await db.getAllEquipments()).length,
        tasks: (await db.getAllTasks()).length,
        locations: (await db.getAllLocations()).length,
        materials: (await db.getAllMaterialReferences()).length,
      );

      await ensureReferenceData(ref);

      _setCounts(
        projects: (await db.getAllProjects()).length,
        employees: (await db.getAllEmployees()).length,
        equipments: (await db.getAllEquipments()).length,
        tasks: (await db.getAllTasks()).length,
        locations: (await db.getAllLocations()).length,
        materials: (await db.getAllMaterialReferences()).length,
      );

      _openFeuilleList();
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

  void _setCounts({
    required int projects,
    required int employees,
    required int equipments,
    required int tasks,
    required int locations,
    required int materials,
  }) {
    if (!mounted) {
      return;
    }
    setState(() {
      _projectsCount = projects;
      _employeesCount = employees;
      _equipmentsCount = equipments;
      _tasksCount = tasks;
      _locationsCount = locations;
      _materialsCount = materials;
    });
  }

  void _openFeuilleList() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PostLoginMenuScreen(),
      ),
    );
  }

  Widget _buildCountCard(String title, int count) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialisation des donnees'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Chargement automatique des donnees de reference...'),
            ],
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _ensureReferenceData,
                child: const Text('Reessayer le chargement'),
              ),
              const SizedBox(height: 16),
            ],
            _buildCountCard('Projects', _projectsCount),
            _buildCountCard('Employees', _employeesCount),
            _buildCountCard('Equipments', _equipmentsCount),
            _buildCountCard('Tasks', _tasksCount),
            _buildCountCard('Locations', _locationsCount),
            _buildCountCard('Materials', _materialsCount),
          ],
        ),
      ),
    );
  }
}
