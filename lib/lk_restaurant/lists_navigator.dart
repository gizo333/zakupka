import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../table/tableview.dart';
import '../table/teble_to_excel.dart';

class ListsNavigatorPage extends StatefulWidget {
  const ListsNavigatorPage({Key? key}) : super(key: key);

  @override
  State<ListsNavigatorPage> createState() => ListsNavigatorPageState();
}

class ListsNavigatorPageState extends State<ListsNavigatorPage> {
  List<String> _tableList = [];
  TextEditingController _tableNameController = TextEditingController();
  late String realName;

  Future<void> fetchTableListFromPostgreSQL() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    final user = FirebaseAuth.instance.currentUser;

    try {
      await connection.open();

      final rTablesResult = await connection.query(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'public' AND table_name LIKE @tableName",
        substitutionValues: {'tableName': 'r_${user?.uid?.toLowerCase()}_%'},
      );
      print(user?.uid);

      final rTables =
          rTablesResult.map((row) => row[0] as String).toList();

      setState(() {
        _tableList = rTables
            // .map((tableName) => tableName.split('_').last)
            .toList();
      });

      await connection.close();
    } catch (e) {
      print('Error fetching table list from PostgreSQL: $e');
    }
  }

  Future<void> fetchTableListFromPostgreSQLWeb() async {
    final user = FirebaseAuth.instance.currentUser;

    final url = Uri.parse('http://37.140.241.144:8085/api/tables/alltables');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final tables = json.decode(response.body) as List<dynamic>;

        final filteredTables = tables
            .cast<String>()
            .where((tableName) =>
                tableName.startsWith('r_${user?.uid?.toLowerCase()}_'))
            .toList();

        setState(() {
          _tableList = filteredTables;
        });
      } else {
        print('Error fetching table list from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching table list from API: $e');
    }
  }

  Future<void> createrTable() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    final user = FirebaseAuth.instance.currentUser;

    try {
      await connection.open();

      String tableName;
      if (_tableNameController.text.isNotEmpty) {
        tableName =
            'r_${user?.uid?.toLowerCase()}_${_tableNameController.text}';
      } else {
        tableName =
            'r_${user?.uid?.toLowerCase()}_${DateTime.now().microsecondsSinceEpoch}';
      }

      await connection.execute(
        'CREATE TABLE $tableName ('
        'id SERIAL PRIMARY KEY, '
        'code INTEGER, '
        'name TEXT, '
        'ml INTEGER, '
        'itog INTEGER'
        ')',
      );

      await connection.execute(
        'INSERT INTO links (r_table_name, linked_table_name) '
        "VALUES ('r_${user?.uid?.toLowerCase()}', '$tableName')",
      );

      await fetchTableListFromPostgreSQL(); // Refresh the table list

      await connection.close();
    } catch (e) {
      print('Error creating r table: $e');
    }
  }

  Future<void> createrTableWeb() async {
    final user = FirebaseAuth.instance.currentUser?.uid;
    final url = Uri.parse('http://37.140.241.144:8085/api/tables/create');
    final tableName = _tableNameController.text.isNotEmpty
        ? _tableNameController.text
        : DateTime.now().microsecondsSinceEpoch.toString();

    final body = json.encode({
      'tableName': tableName,
      'user': user,
    });

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            // 'user': user.toString(),
          },
          body: body);

      if (response.statusCode == 200) {
        // Таблица успешно создана, выполните действия, необходимые после создания
        await fetchTableListFromPostgreSQLWeb();
      } else {
        print('Ошибка создания таблицы: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка создания таблицы: $e');
    }
  }

  Future<void> deleteTable(String tableName) async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      await connection.execute('DROP TABLE IF EXISTS $tableName');

      await connection.execute(
        "DELETE FROM links WHERE linked_table_name = '$tableName'",
      );

      await fetchTableListFromPostgreSQL(); // Refresh the table list

      await connection.close();
    } catch (e) {
      print('Error deleting table: $e');
    }
  }

  Future<void> deleteTableWeb(String tableName) async {
    final apiUrl =
        'http://37.140.241.144:8085/api/tables/deletetable/' '$tableName';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      await fetchTableListFromPostgreSQLWeb();

      if (response.statusCode == 200) {
        print('Table $tableName deleted');
      } else {
        print('Error deleting table: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting table: $e');
    }
  }

  void navigateToTableView(String tableName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableView(
          tableName: tableName,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      fetchTableListFromPostgreSQLWeb();
    } else {
      fetchTableListFromPostgreSQL();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 16,
              controller: _tableNameController,
              decoration: InputDecoration(
                labelText: 'Table Name',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tableList.length,
              itemBuilder: (context, index) {
                final tableName = _tableList[index];
                return ListTile(
                  title: Text(tableName.split('_').last),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,  // Задает основной размер по минимальному значению
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.file_download),  // Иконка загрузки
                        onPressed: () {
                          downloadTable('$tableName');  // Вместо 'your_table_name' укажите имя вашей таблицы
                        },
                      ),




                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          if (kIsWeb) {
                            await deleteTableWeb(tableName);
                          } else {
                            deleteTable(tableName);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => navigateToTableView(tableName),
                );

              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (kIsWeb) {
            await createrTableWeb();
          } else {
            createrTable();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
