import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/db/app_database.dart';
import '../services/project_drilling_task_store.dart';
import '../services/project_hole_progress_store.dart';
import '../services/mobile_scope_cache_service.dart';
import '../services/tablet_company_lock_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final tabletCompanyLockProvider = Provider<TabletCompanyLockService>((ref) {
  return TabletCompanyLockService();
});

final projectDrillingTaskStoreProvider = Provider<ProjectDrillingTaskStore>((ref) {
  return ProjectDrillingTaskStore();
});

final projectHoleProgressStoreProvider = Provider<ProjectHoleProgressStore>((ref) {
  return ProjectHoleProgressStore();
});

final mobileScopeCacheProvider = Provider<MobileScopeCacheService>((ref) {
  return MobileScopeCacheService();
});
