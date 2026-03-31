import 'dart:convert';
import 'dart:typed_data';
import 'package:convo/core/const.dart/constant.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> uploadFileWeb(Uint8List bytes) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$IpAddress:7000/file/upload'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: "image.jpg",
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var data = jsonDecode(res);

      print("Image ID: ${data['id']}");
      print("Image URL: ${data['url']}");

      return data; // return full map
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Upload Error: $e");
    return null;
  }
}

