import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stocke localement les credentials du dernier login online reussi
/// et permet une revalidation offline dans une fenetre de temps limitee.
///
/// Fichier stocke : `offline_auth.json` dans le documents directory.
///
/// Format :
/// `{`
/// `  "db": "aurora_db",`
/// `  "login": "user@example.com",`
/// `  "salt": "32 char hex",`
/// `  "password_hash": "sha256 hex de salt + password",`
/// `  "last_online_login_at": "2026-07-27T14:32:11.000Z"`
/// `}`
class OfflineAuthService {
  static const _fileName = 'offline_auth.json';

  /// Duree de vie de la session offline sans reconnexion online.
  static const Duration offlineSessionMaxAge = Duration(days: 7);

  Future<Map<String, dynamic>?> _read() async {
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

  Future<void> saveCredentials({
    required String db,
    required String login,
    required String password,
  }) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password: password, salt: salt);
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode({
        'db': db,
        'login': login,
        'salt': salt,
        'password_hash': hash,
        'last_online_login_at': DateTime.now().toUtc().toIso8601String(),
      }),
      flush: true,
    );
  }

  /// Retourne true si les credentials correspondent ET si la session
  /// n'est pas expiree (7 jours max sans reconnexion online).
  Future<OfflineAuthResult> validateOffline({
    required String db,
    required String login,
    required String password,
  }) async {
    final data = await _read();
    if (data == null) {
      return OfflineAuthResult.noCredentialsStored;
    }

    final storedDb = data['db']?.toString() ?? '';
    final storedLogin = data['login']?.toString() ?? '';
    if (storedDb != db || storedLogin != login) {
      return OfflineAuthResult.credentialsMismatch;
    }

    final salt = data['salt']?.toString() ?? '';
    final storedHash = data['password_hash']?.toString() ?? '';
    final computed = _hashPassword(password: password, salt: salt);
    if (computed != storedHash) {
      return OfflineAuthResult.wrongPassword;
    }

    final lastLoginRaw = data['last_online_login_at']?.toString();
    if (lastLoginRaw == null || lastLoginRaw.isEmpty) {
      return OfflineAuthResult.expired;
    }
    final lastLogin = DateTime.tryParse(lastLoginRaw);
    if (lastLogin == null) {
      return OfflineAuthResult.expired;
    }
    final age = DateTime.now().toUtc().difference(lastLogin.toUtc());
    if (age > offlineSessionMaxAge) {
      return OfflineAuthResult.expired;
    }

    return OfflineAuthResult.valid;
  }

  Future<bool> hasStoredCredentialsFor({
    required String db,
    required String login,
  }) async {
    final data = await _read();
    if (data == null) {
      return false;
    }
    return data['db']?.toString() == db && data['login']?.toString() == login;
  }

  Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _hashPassword({required String password, required String salt}) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }
}

enum OfflineAuthResult {
  valid,
  noCredentialsStored,
  credentialsMismatch,
  wrongPassword,
  expired,
}
