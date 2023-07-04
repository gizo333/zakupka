import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class ListsNavigatorPage extends StatefulWidget {
  const ListsNavigatorPage({super.key});

  @override
  State<ListsNavigatorPage> createState() => ListsNavigatorPageState();
}

class ListsNavigatorPageState extends State<ListsNavigatorPage> {
  List<String> _tableList = [];

  Future<void> fetchTableListFromPostgreSQL() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      final result = await connection.query(
        'SELECT table_name FROM information_schema.tables '
        "WHERE table_schema = 'public' AND table_name LIKE 'user\\_%'",
      );

      setState(() {
        _tableList = result.map((row) => row[0] as String).toList();
      });

      await connection.close();
    } catch (e) {
      print('Error fetching table list from PostgreSQL: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTableListFromPostgreSQL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table List'),
      ),
      body: ListView.builder(
        itemCount: _tableList.length,
        itemBuilder: (context, index) {
          final tableName = _tableList[index];
          return ListTile(
            title: Text(tableName),
          );
        },
      ),
    );
  }
}
