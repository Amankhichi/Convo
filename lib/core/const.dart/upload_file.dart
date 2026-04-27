import 'dart:convert';
import 'dart:typed_data';
import 'package:convo/core/const.dart/api_config.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> uploadFile(Uint8List bytes) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/file/upload'), // ✅ fixed
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'image.jpg',
      ),
    );

    final res = await request.send();

    if (res.statusCode != 200) return null;

    final data = jsonDecode(await res.stream.bytesToString());

    print("✅ Uploaded: ${data['url']}");

    return data;
  } catch (e) {
    print("❌ Upload Error: $e");
    return null;
  }
}
