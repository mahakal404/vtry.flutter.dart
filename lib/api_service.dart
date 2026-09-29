import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String apiUrl = 'https://api.lightxeditor.com/external/api/v1/virtual-try-on';
  
  // API Key - Ensure no spaces
  static const String apiKey = 'e364681a2d4d407e849d99226c39e3d6_d002fb3bbf2444c29d7f67be8e1867bc_andoraitools'; 

  /// Generates a Virtual Try-On image.
  /// Returns a Map with 'success' (bool) and either 'url' (String) or 'error' (String).
  Future<Map<String, dynamic>> generateTryOn(XFile userImage, XFile clothImage) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // Essential Headers for LightX
      request.headers.addAll({
        'x-api-key': apiKey.trim(),
        'Accept': 'application/json',
      });

      // Files
      request.files.add(await http.MultipartFile.fromPath('image', userImage.path));
      request.files.add(await http.MultipartFile.fromPath('garment_image', clothImage.path));

      // Category - Required by LightX
      request.fields['category'] = 'tops'; 

      debugPrint("Sending request to LightX API...");
      var streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      var response = await http.Response.fromStream(streamedResponse);

      // Detailed Logging for Debugging 403/Other Errors
      debugPrint("Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          debugPrint("Try-On Successful!");
          return {
            'success': true,
            'url': data['data']['output_url'],
          };
        } else {
          debugPrint("API logic error: ${response.body}");
          return {
            'success': false,
            'error': data['message'] ?? "Unknown API Error",
          };
        }
      } else {
        // This is where we catch the 403 Forbidden details
        debugPrint("CRITICAL ERROR [${response.statusCode}]: ${response.body}");
        
        String errorMessage = "Failed with status: ${response.statusCode}";
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (_) {
          // If response is not JSON
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
      
    } catch (e) {
      debugPrint("ApiService Exception: $e");
      return {
        'success': false,
        'error': "Connection Error: ${e.toString()}",
      };
    }
  }
}