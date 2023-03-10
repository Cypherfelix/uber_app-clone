import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(String url, String mode) async {
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String jSonData = response.body;
        if (mode.toLowerCase() == "string".toLowerCase()) {
          return jSonData;
        }
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      } else {
        return "Failed";
      }
    } catch (e) {
      return "Failed";
    }
  }
}
