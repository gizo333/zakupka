import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as https;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadTable(String tableName) async {
  final user = (FirebaseAuth.instance.currentUser?.uid ?? '').toLowerCase();

  if (tableName == null || tableName.isEmpty) {
    print('Название таблицы не может быть пустым.');
    return;
  }

  final url =
      Uri.parse('https://zakup.bar:8080/api/tables/download/$tableName');

  final headers = {
    'Content-Type': 'application/json',
    'user': user,
  };

  try {
    final response = await https.get(url, headers: headers);

    if (response.statusCode == 200) {
      if (kIsWeb) {
        var data = response.bodyBytes;
        final blob = html.Blob([data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..style.display = 'none'
          ..download = '$tableName.xlsx';
        html.document.body?.children.add(anchor);

        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print('Таблица успешно загружена.');
      } else {
        var data = response.bodyBytes;
        final directory = await getApplicationSupportDirectory();
        final path = directory.path;
        final filePath = '$path/$tableName.xlsx';
        File file = File(filePath);
        await file.writeAsBytes(data);

        print('Файл сохранен в $filePath');

        final result = await OpenFile.open(filePath);
        print(result.message);
      }
    } else {
      print('Ошибка загрузки таблицы. Код состояния: ${response.statusCode}');
      print('Тело ответа: ${response.body}');
    }
  } catch (e) {
    print('Ошибка загрузки таблицы: $e');
    if (e is https.ClientException) {
      if (e.uri != null) {
        print('URI запроса: ${e.uri}');
      }
      if (e.message != null) {
        print('Сообщение об ошибке: ${e.message}');
      }
    } else if (kIsWeb && e is html.DomException) {
      print('Ошибка DOM: ${e.message}');
    }
  }
}
