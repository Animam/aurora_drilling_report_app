import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class MobileScopeCacheService {
  static const _fileName = 'mobile_scope_cache.json';
  static const _localDataFolder = r'C:\Users\Parfait-SEDOGO\DevOps\forages_mobile_data';

  Future<Map<String, dynamic>?> readScope() async {
    final file = await _getFile();
    if (!await file.exists()) {
      return null;
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveScope({
    required int companyId,
    required String companyName,
    required int employeeId,
    required String employeeName,
    required List<int> assignedProjectIds,
  }) async {
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode({
        'company_id': companyId,
        'company_name': companyName,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'assigned_project_ids': assignedProjectIds,
      }),
      flush: true,
    );
  }

  Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _getFile() async {
    final dir = Directory(_localDataFolder);
    await dir.create(recursive: true);
    return File(p.join(dir.path, _fileName));
  }
}
