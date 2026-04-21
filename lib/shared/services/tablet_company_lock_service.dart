import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class TabletCompanyLockService {
  static const _fileName = 'tablet_company_lock.json';
  static const _localDataFolder = r'C:\Users\Parfait-SEDOGO\DevOps\forages_mobile_data';

  Future<Map<String, dynamic>?> readBinding() async {
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

  Future<void> bindCompany({
    required int companyId,
    required String companyName,
  }) async {
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode({
        'company_id': companyId,
        'company_name': companyName,
      }),
      flush: true,
    );
  }

  Future<void> clearBinding() async {
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
