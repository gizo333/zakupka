import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

///данная функция позволяет скачать файл из БД в .xlsx формате
Future<void> downloadTable(String tableName) async {
  final user = (FirebaseAuth.instance.currentUser?.uid ?? '').toLowerCase();

  if (tableName == null || tableName.isEmpty) {
    print('Название таблицы не может быть пустым.');
    return;
  }

  final url = Uri.parse('http://37.140.241.144:8080/api/tables/download/$tableName');

  final headers = {
    'Content-Type': 'application/json',
    'user': user,
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      if (kIsWeb) {
        // Если это веб-платформа
        var data = response.bodyBytes;
        final blob = html.Blob([data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = '$tableName.xlsx';
        html.document.body?.children.add(anchor);

        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print('Таблица успешно загружена.');
      } else {
        // Если это мобильная платформа
        var data = response.bodyBytes;
        final directory = await getApplicationSupportDirectory(); // Изменение здесь
        final path = directory.path;
        final filePath = '$path/$tableName.xlsx';
        File file = File(filePath);
        await file.writeAsBytes(data);

        print('Файл сохранен в $filePath');

        // Открыть файл с помощью пакета open_file
        final result = await OpenFile.open(filePath);
        print(result.message); // Вывести сообщение о результате открытия файла
      }
    } else {
      print('Ошибка загрузки таблицы: ${response.statusCode}');
    }
  } catch (e) {
    print('Ошибка загрузки таблицы: $e');
  }
}