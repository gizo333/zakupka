import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      final query = 'SELECT * FROM users';
      final results = await connection.query(query);

      setState(() {
        userList = results.map((row) => row.toColumnMap()).toList();
      });
    } catch (e) {
      print(e);
    } finally {
      await connection.close();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список пользователей'),
      ),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return ListTile(
            title: Text(user['full_name']),
            subtitle: Text(user['email']),
          );
        },
      ),
    );
  }
}
