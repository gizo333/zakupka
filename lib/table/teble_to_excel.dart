import 'dart:html' as html;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';

Future<void> downloadTable(String tableName) async {
  final user = (FirebaseAuth.instance.currentUser?.uid ?? '').toLowerCase();

  if (tableName == null || tableName.isEmpty) {
    print('Название таблицы не может быть пустым.');
    return;
  }


  final url = Uri.parse('http://37.140.241.144:8085/api/tables/download/$tableName');

  // if (user == null) {
  //   print('Пользователь не зарегистрирован.');
  //   return;
  // }

  final headers = {
    'Content-Type': 'application/json',
    'user': user,
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var excel = Excel.createExcel();

      List<dynamic> list = jsonDecode(response.body);

      for (var item in list) {
        if (item is Map<String, dynamic>) {
          item.remove('id'); // Удалить столбец 'id'
          excel.sheets['Sheet1']?.appendRow(item.values.toList());
        }
      }

      List<int>? encodedExcel = await excel.encode();
      if (encodedExcel != null) {
        final blob = html.Blob([encodedExcel]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = '$tableName.xlsx';
        html.document.body?.children.add(anchor);

        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        // print('Таблица успешно загружена.');
      } else {
        // print('Ошибка при кодировании Excel файла');
      }
    } else {
      // print('Ошибка загрузки таблицы: ${response.statusCode}');
    }
  } catch (e) {
    // print('Ошибка загрузки таблицы: $e');
  }
}
