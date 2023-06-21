import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

Future<void> saveDataToPostgreSQL(BuildContext context, List<dynamic> _lists) async {
  final connection = PostgreSQLConnection(
    '37.140.241.144',
    5432,
    'postgres',
    username: 'postgres',
    password: '1',
  );

  try {
    await connection.open();

    // Очистить таблицу перед импортом (если нужно)
    await connection.execute('DELETE FROM position');

    // Создать список значений для вставки
    final values = _lists
        .map((position) => '(${position.code}, \'${_escapeString(position.name)}\', ${position.ml}, ${position.itog})')
        .join(', ');

    // Замерить время сохранения данных
    final stopwatch = Stopwatch()..start();

    // Вставить данные в таблицу
    await connection.execute('INSERT INTO position (code, name, ml, itog) VALUES $values');

    // Остановить и вывести время сохранения в консоль
    stopwatch.stop();
    print('Время сохранения в PostgreSQL: ${stopwatch.elapsed.inMilliseconds} мс');

    // Закрыть соединение
    await connection.close();

    // Очистить списки после сохранения данных в БД
    _lists.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Данные сохранены в PostgreSQL'),
      ),
    );
  } catch (e) {
    print('Ошибка при сохранении данных в PostgreSQL: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ошибка при сохранении данных в PostgreSQL'),
      ),
    );
  }
}
// _escapeString используется для экранирования специальных символов в строке.
// Экранирование символов осуществляется путем замены одинарных кавычек (') на двойные кавычки (''),
// чтобы предотвратить ошибки при выполнении SQL-запросов.
String _escapeString(String value) {
  return value.replaceAll("'", "''");
}
