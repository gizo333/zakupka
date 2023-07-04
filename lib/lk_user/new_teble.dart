import 'package:postgres/postgres.dart';

void createTableForUsers() async {
  final postgresConnection = PostgreSQLConnection(
    '37.140.241.144',
    5432,
    'postgres',
    username: 'postgres',
    password: '1',
  );

  try {
    await postgresConnection.open();

    // Получение всех пользователей из таблицы users_sotrud
    final users = await postgresConnection.query('SELECT * FROM restaurant');

    for (final user in users) {
      final userId = user[5];
      final nameRest = user[6];

      // Проверка, что поле name_rest заполнено
      if (nameRest != null && nameRest.isNotEmpty) {
        // Генерация имени новой таблицы
        final tableName = 'user_$userId';
        // Создание новой таблицы с двумя столбцами типа VARCHAR
        await postgresConnection.execute(
            'CREATE TABLE $tableName (column1 VARCHAR, column2 VARCHAR)');
        // Дальнейшие действия с созданной таблицей
        // ...
        print('Создана новая таблица $tableName для пользователя $userId');
      }
    }

    await postgresConnection.close();
  } catch (e) {
    print('Ошибка при подключении к базе данных: $e');
  }
}
