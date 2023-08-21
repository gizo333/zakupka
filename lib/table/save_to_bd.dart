import 'dart:convert';

import 'package:new_flut_proj/table/classes.dart';
import 'package:postgres/postgres.dart';
import 'package:http/http.dart' as https;

Future<void> saveDataToPostgreSQLBWeb(
    List<PositionClass> _lists, String tablename) async {
  final stopwatch = Stopwatch()..start(); // Start the stopwatch
  final url = Uri.parse('https://zakup.bar:8085/apip/tables/savedatab');
  final body = json.encode({
    'tableName': tablename,
    'data': _lists.map((position) {
      final code = position.code ?? 0;
      final name = _escapeString(position.name) ?? '';
      final ml = position.ml ?? 0;
      final itog = (position.itog ?? 0) + (position.ml ?? 0);
      return {
        'code': code,
        'name': name,
        'ml': ml,
        'itog': itog,
      };
    }).toList(),
  });

  try {
    final response = await https.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('good job!');
      print(
          'Time taken to save data to PostgreSQL: ${stopwatch.elapsed}'); // Print the elapsed time
    } else {
      print('Error saving data toPostgreSQL blyaaa: ${response.statusCode}');
    }
  } catch (e) {
    print('Error saving data to PostgreSQL: $e');
  }
}

String _escapeString(String value) {
  return value.replaceAll("'", "''");
}
