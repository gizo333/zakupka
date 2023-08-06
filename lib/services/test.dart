import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';


class TestSpeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test App',
      home: SpeedTestScreen(),
    );
  }
}

class SpeedTestScreen extends StatefulWidget {
  @override
  _SpeedTestScreenState createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  String _speedResult = '';

  Future<void> _runSpeedTest() async {
    // Проверяем доступность интернета
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      setState(() {
        _speedResult = 'Нет подключения к интернету';
      });
      return;
    }

    // Запускаем тестирование загрузки файла с некоторого URL
    var url = 'https://pagespeed.web.dev/'; // Замените на реальный URL файла
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Получаем размер файла в байтах
      var fileSize = response.bodyBytes.length;

      // Измеряем время загрузки файла
      var startTime = DateTime.now();
      await http.get(Uri.parse(url));
      var endTime = DateTime.now();

      // Вычисляем скорость загрузки (в Килобитах в секунду)
      var downloadTime = endTime.difference(startTime).inMilliseconds / 1000;
      var speedKbps = (fileSize / downloadTime) * 8 / 1024;

      setState(() {
        _speedResult = 'Скорость загрузки: ${speedKbps.toStringAsFixed(2)} Kbps';
      });
    } else {
      setState(() {
        _speedResult = 'Ошибка при измерении скорости';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speed Test App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _runSpeedTest,
              child: Text('Измерить скорость интернета'),
            ),
            SizedBox(height: 20),
            Text(
              _speedResult,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
