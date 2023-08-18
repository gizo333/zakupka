import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

class CheckInternetConnection with ChangeNotifier {
  double _lowSpeedThreshold = 5;

  Future<bool> runSpeedTest() async {
    var url =
        'https://www.google.com/'; // Замените на доступный сервер для теста скорости
    try {
      var client = https.Client();
      var response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var contentLength =
            double.parse(response.headers['content-length'] ?? '0');
        var downloadTime = response.bodyBytes.length / contentLength;
        var downloadSpeed = (downloadTime / 1000) * 8;
        client.close();
        return downloadSpeed >= _lowSpeedThreshold;
      }
    } catch (error) {
      return false;
    }
    return false;
  }
}
