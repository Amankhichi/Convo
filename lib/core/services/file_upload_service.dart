import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

class FileUploadService {
  final ApiClient _apiClient;

  FileUploadService(this._apiClient);

  Future<Map<String, dynamic>?> uploadFile(Uint8List bytes) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'image.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/file/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("❌ Upload Error: $e");
      return null;
    }
  }
}
