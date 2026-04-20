import 'package:dio/dio.dart';

class BootstrapApi {
  BootstrapApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchBootstrap() async {
    final response = await _dio.post(
      '/mobile/bootstrap',
      data: {
        'jsonrpc': '2.0',
        'params': {},
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    if (data['error'] != null) {
      final errorMap = Map<String, dynamic>.from(data['error'] as Map);
      throw Exception(errorMap['message']?.toString() ?? 'Erreur API');
    }

    if (data['result'] == null) {
      throw Exception('La reponse API ne contient pas de result');
    }

    return Map<String, dynamic>.from(data['result'] as Map);
  }
}
