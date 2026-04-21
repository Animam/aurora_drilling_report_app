import 'package:dio/dio.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String db,
    required String login,
    required String password,
  }) async {
    final response = await _dio.post(
      '/mobile/auth/login',
      data: {
        'jsonrpc': '2.0',
        'params': {
          'db': db,
          'login': login,
          'password': password,
        },
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    if (data['error'] != null) {
      final errorMap = Map<String, dynamic>.from(data['error'] as Map);
      throw Exception(errorMap['message']?.toString() ?? 'Erreur de login');
    }

    if (data['result'] == null) {
      throw Exception('La reponse de login ne contient pas de result');
    }

    final result = Map<String, dynamic>.from(data['result'] as Map);
    final success = result['success'] == true;

    if (!success) {
      throw Exception(result['message']?.toString() ?? 'Identifiants invalides');
    }

    return result;
  }

  Future<void> logout() async {
    await _dio.post(
      '/mobile/auth/logout',
      data: {
        'jsonrpc': '2.0',
        'params': <String, dynamic>{},
      },
    );
  }
}
