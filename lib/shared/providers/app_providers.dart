import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/db/app_database.dart';
import '../services/tablet_company_lock_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final tabletCompanyLockProvider = Provider<TabletCompanyLockService>((ref) {
  return TabletCompanyLockService();
});
