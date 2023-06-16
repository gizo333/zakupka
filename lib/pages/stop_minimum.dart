import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';


class sql extends StatelessWidget {
  final connection = PostgreSQLConnection(
    '37.140.241.144',
    5432,
    'postgres',
    username: 'postgres',
    password: '1',
  );

  void connectToDatabase() async {
    try {
      await connection.open();
      if (connection.isClosed) {
        print('Не удалось установить соединение с базой данных');
      } else {
        print('Соединение с базой данных успешно установлено');
      }
    } catch (e) {
      print('Ошибка при подключении к базе данных: $e');
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Подключение к базе данных'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: connectToDatabase,
            child: Text('Подключиться к базе данных'),
          ),
        ),
      ),
    );
  }
}
