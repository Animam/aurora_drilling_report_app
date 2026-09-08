import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class TabletCompanyLockService {
  static const _fileName = 'tablet_company_lock.json';

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
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
