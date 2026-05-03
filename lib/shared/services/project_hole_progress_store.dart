import 'dart:convert';
import 'dart:io';

class ProjectHoleProgressStore {
  static const _folderPath = r'C:\Users\Parfait-SEDOGO\DevOps\forages_mobile_data';
  static const _fileName = 'project_hole_progress_map.json';

  Future<File> _getFile() async {
    final folder = Directory(_folderPath);
    await folder.create(recursive: true);
    return File('$_folderPath\\$_fileName');
  }

  Future<Map<String, Map<String, int>>> readMap() async {
    final file = await _getFile();
    if (!await file.exists()) {
      return const {};
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const {};
    }

    return decoded.map((projectId, value) {
      final rawHoles = value is Map<String, dynamic> ? value : <String, dynamic>{};
      final holes = rawHoles.map((holeNo, maxValue) => MapEntry(holeNo, (maxValue as num).toInt()));
      return MapEntry(projectId, holes);
    });
  }

  Future<Map<String, int>> getHoleProgressForProject(int projectOdooId) async {
    final mapping = await readMap();
    return mapping[projectOdooId.toString()] ?? const {};
  }

  Future<void> replaceMap(Map<String, Map<String, int>> mapping) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(mapping));
  }

  Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
