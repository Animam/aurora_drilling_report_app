import 'dart:convert';
import 'dart:io';

class MaterialTagStore {
  static const _folderPath = r'C:\Users\Parfait-SEDOGO\DevOps\forages_mobile_data';
  static const _fileName = 'material_tag_map.json';

  Future<File> _getFile() async {
    final folder = Directory(_folderPath);
    await folder.create(recursive: true);
    return File('$_folderPath\\$_fileName');
  }

  Future<Map<String, List<String>>> readMap() async {
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

    return decoded.map((key, value) {
      final items = (value as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false);
      return MapEntry(key, items);
    });
  }

  Future<List<String>> getTagsForMaterial(int materialOdooId) async {
    final mapping = await readMap();
    return mapping[materialOdooId.toString()] ?? const [];
  }

  Future<void> replaceMap(Map<String, List<String>> mapping) async {
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
