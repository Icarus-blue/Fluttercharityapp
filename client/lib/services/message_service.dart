import 'dart:convert';
import 'package:client/services/config.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MessageService {
  static Future<http.Response> fetchMessages(String token, String chatId) async {
    final uri = '$messageUrl/$chatId';
    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<http.Response> sendMessage(String token, Map<String, dynamic> reqBody, {File? file}) async {
    var request = http.MultipartRequest('POST', Uri.parse(messageUrl));

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add text fields
    reqBody.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    // Add file if present
    if (file != null) {
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: file.path.split('/').last
      );
      request.files.add(multipartFile);
    }

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  static Future<http.Response> readMessage(String token, String messageId) async {
    final uri = '$messageUrl/$messageId';
    final response = await http.patch(
      Uri.parse(uri),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<http.Response> downloadFile(String token, String fileName) async {
    final response = await http.get(
      Uri.parse('$messageUrl/download/$fileName'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}