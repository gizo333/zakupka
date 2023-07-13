import 'package:postgres/postgres.dart';

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

    print('Time taken to save data to PostgreSQL: ${stopwatch.elapsed}'); // Print the elapsed time

    await connection.close();
  } catch (e) {
    print('Error saving data to PostgreSQL: $e');
  }
}

String _escapeString(String value) {
  return value.replaceAll("'", "''");
}
