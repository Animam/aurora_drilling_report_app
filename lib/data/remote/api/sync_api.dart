import 'package:dio/dio.dart';

class SyncApi {
  SyncApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> syncFullFeuille({
    required Map<String, dynamic> feuille,
    required List<Map<String, dynamic>> lignes,
    required List<Map<String, dynamic>> employes,
    required List<Map<String, dynamic>> fuels,
    required List<Map<String, dynamic>> materiels,
  }) async {
    final response = await _dio.post(
      '/mobile/feuilles/full_sync',
      data: {
        'jsonrpc': '2.0',
        'params': {
          'feuille': feuille,
          'lignes': lignes,
          'employes': employes,
          'fuels': fuels,
          'materiels': materiels,
        },
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    if (data['error'] != null) {
      final errorMap = Map<String, dynamic>.from(data['error'] as Map);
      throw Exception(errorMap['message']?.toString() ?? 'Erreur de synchronisation');
    }

    if (data['result'] == null) {
      throw Exception('La reponse de synchronisation ne contient pas de result');
    }

    final result = Map<String, dynamic>.from(data['result'] as Map);
    if (result['success'] != true) {
      throw Exception(result['message']?.toString() ?? 'Synchronisation echouee');
    }

    return result;
  }
}
