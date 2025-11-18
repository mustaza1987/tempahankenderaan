import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tempahan_model.dart';

class TempahanService {
  static const String baseUrl =
      'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/borang_tempahan_api.php';

  Future<DropdownData> getDropdownData(int idBahagian) async {
    try {
      final uri = Uri.parse(
        '$baseUrl?action=get_dropdown&id_bahagian=$idBahagian',
      );
      print('🔍 Fetching dropdown data from: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug print untuk melihat struktur data
        print('🔍 JSON structure: ${jsonData.keys}');
        if (jsonData['data'] != null) {
          print('🔍 Data structure: ${jsonData['data'].keys}');
        }

        if (jsonData['status'] == 'success') {
          return DropdownData.fromJson(jsonData['data'] ?? {});
        } else {
          throw Exception(
            jsonData['message'] ?? 'Failed to load dropdown data',
          );
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to load dropdown data',
        );
      }
    } catch (e) {
      print('❌ Error in getDropdownData: $e');
      rethrow;
    }
  }

  Future<MaklumatPemohon> getMaklumatPemohon(int idPemohon) async {
    try {
      final uri = Uri.parse(
        '$baseUrl?action=get_pemohon&id_pemohon=$idPemohon',
      );
      print('🔍 Fetching pemohon data from: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          return MaklumatPemohon.fromJson(jsonData['data'] ?? {});
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load pemohon data');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to load pemohon data',
        );
      }
    } catch (e) {
      print('❌ Error in getMaklumatPemohon: $e');
      rethrow;
    }
  }

  Future<ApiResponse> simpanTempahan(TempahanRequest request) async {
    try {
      print('💾 Saving tempahan to: $baseUrl');
      print('📤 Request data: ${request.toJson()}');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to save tempahan');
      }
    } catch (e) {
      print('❌ Error in simpanTempahan: $e');
      rethrow;
    }
  }
}
