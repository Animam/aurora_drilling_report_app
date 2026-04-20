import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/auth_api.dart';
import '../../data/remote/api/bootstrap_api.dart';
import '../../data/remote/api/sync_api.dart';

final cookieJarProvider = Provider<CookieJar>((ref) {
  return CookieJar();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8016',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(CookieManager(ref.read(cookieJarProvider)));
  return dio;
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});

final bootstrapApiProvider = Provider<BootstrapApi>((ref) {
  return BootstrapApi(ref.read(dioProvider));
});

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.read(dioProvider));
});
