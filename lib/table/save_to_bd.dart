import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';


Future<void> saveDataToPostgreSQLB(List<dynamic> _lists, String tablename) async {
  final connection = PostgreSQLConnection(
    '37.140.241.144',
    5432,
    'postgres',
    username: 'postgres',
    password: '1',
  );

  try {
    await postgresConnection.open();

    // Очистить таблицу перед импортом (если нужно)
    await connection.execute('DELETE FROM $tablename');

    // Создать список значений для вставки
    final values = _lists
        .asMap()
        .entries
        .map((entry) =>
            '(${entry.key + 1}, ${entry.value.code}, \'${_escapeString(entry.value.name)}\', ${entry.value.ml}, ${entry.value.itog})')
        .join(', ');

    // Замерить время сохранения данных
    final stopwatch = Stopwatch()..start();

    // Вставить данные в таблицу

    await connection.execute(
        'INSERT INTO $tablename (id, code, name, ml, itog) VALUES $values');

    // Остановить и вывести время сохранения в консоль
    stopwatch.stop();
    print('Время сохранения в PostgreSQL: ${stopwatch.elapsed.inMilliseconds} мс');

    // Закрыть соединение
    await postgresConnection.close();

    // Очистить списки после сохранения данных в БД
    // _lists.clear();
  } catch (e) {
    print('Ошибка при сохранении данных в PostgreSQL: $e');
  }
}

// _escapeString используется для экранирования специальных символов в строке.
// Экранирование символов осуществляется путем замены одинарных кавычек (') на двойные кавычки (''),
// чтобы предотвратить ошибки при выполнении SQL-запросов.
String _escapeString(String value) {
  return value.replaceAll("'", "''");
}
