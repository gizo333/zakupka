import 'dart:convert';

import 'package:new_flut_proj/table/classes.dart';
import 'package:postgres/postgres.dart';
import 'package:http/http.dart' as http;

Future<void> saveDataToPostgreSQLB(
    List<dynamic> _lists, String tablename) async {
  final connection = PostgreSQLConnection(
    '37.140.241.144',
    5432,
    'postgres',
    username: 'postgres',
    password: '1',
  );

  try {
    await connection.open();

    // Clear the table before importing (if needed)
    await connection.execute('DELETE FROM $tablename');

    const batchSize = 1000; // Set the batch size as per your requirement
    final batches = (_lists.length / batchSize).ceil();
    final stopwatch = Stopwatch()..start(); // Start the stopwatch

    for (int batch = 0; batch < batches; batch++) {
      final start = batch * batchSize;
      final end = (start + batchSize).clamp(0, _lists.length);
      final batchLists = _lists.sublist(start, end);

      final values = batchLists
          .map((position) =>
              '(${position.code ?? 0}, \'${_escapeString(position.name ?? '')}\', ${position.ml ?? 0}, ${(position.itog ?? 0) + (position.ml ?? 0)})')
          .join(', ');

      await connection.execute(
        'INSERT INTO $tablename (code, name, ml, itog) VALUES $values',
      );
    }

    stopwatch.stop(); // Stop the stopwatch

    print(
        'Time taken to save data to PostgreSQL: ${stopwatch.elapsed}'); // Print the elapsed time

    await connection.close();
  } catch (e) {
    print('Error saving data to PostgreSQL: $e');
  }
}

Future<void> saveDataToPostgreSQLBWeb(
    List<PositionClass> _lists, String tablename) async {
  final stopwatch = Stopwatch()..start(); // Start the stopwatch
  final url = Uri.parse('http://37.140.241.144:8085/apip/tables/savedatab');
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
    final response = await http.post(
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
