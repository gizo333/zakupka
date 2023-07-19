import 'package:postgres/postgres.dart';
import '../connect_BD/connect.dart';


void createTableForUsers() async {
  final postgresConnection = createDatabaseConnection();

  try {
    await postgresConnection.open();

    // Получение всех пользователей из таблицы users_sotrud
    final users = await postgresConnection.query('SELECT * FROM restaurant');

    for (final user in users) {
      final userId = user[6];
      final nameRest = user[3];

      // Проверка, что поле name_rest заполнено
      if (nameRest != null && nameRest.isNotEmpty) {
        // Генерация имени новой таблицы на основе userId и nameRest
        final tableName = 'restaurant_${userId}_$nameRest';

        // Проверка существования таблицы
        final tableExists = await checkIfTableExists(postgresConnection, tableName);

        if (!tableExists) {
          // Создание новой таблицы с необходимыми полями
          await postgresConnection.execute('''
            CREATE TABLE $tableName (
              id SERIAL PRIMARY KEY,
              email TEXT,
              restaurant TEXT,
              user_id TEXT
            )
          ''');

          // Получение значений email, restaurant и user_id из таблицы restaurant
          final email = user[1];
          final restaurant = user[3];
          final userId = user[6];

          // Вставка значений в новую таблицу
          await postgresConnection.execute('''
            INSERT INTO $tableName (email, restaurant, user_id)
            VALUES (@email, @restaurant, @userId)
          ''', substitutionValues: {
            'email': email,
            'restaurant': restaurant,
            'userId': userId,
          });

          // Дальнейшие действия с созданной таблицей
          // ...
          print('Создана новая таблица $tableName для пользователя $nameRest');
        } else {
          print('Таблица $tableName уже существует');
        }
      }
    }

    await postgresConnection.close();
  } catch (e) {
    print('Ошибка при подключении к базе данных: $e');
  }
}

// Проверка существования таблицы
Future<bool> checkIfTableExists(PostgreSQLConnection connection, String tableName) async {
  final result = await connection.query(
    'SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = @tableName)',
    substitutionValues: {
      'tableName': tableName,
    },
  );

  return result.first[0];
}
