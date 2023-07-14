import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import '../table/tableview.dart';

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

      final restaurantTablesResult = await connection.query(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'public' AND table_name LIKE @tableName",
        substitutionValues: {
          'tableName': 'restaurant_${user?.uid?.toLowerCase()}_%'
        },
      );
      print(user?.uid);

      final restaurantTables =
          restaurantTablesResult.map((row) => row[0] as String).toList();

      final allLinksResult = await connection.query('SELECT * FROM links');

      final restaurantLinksResult = await connection.query(
        "SELECT linked_table_name FROM links "
        "WHERE restaurant_table_name IN (${restaurantTables.map((_) => '\'$_\'').join(',')})",
      );

      final restaurantLinks =
          restaurantLinksResult.map((row) => row[0] as String).toList();

      final filteredLinks = allLinksResult.toList();

      setState(() {
        _tableList = restaurantTables
            // .map((tableName) => tableName.split('_').last)
            .toList();
      });

      await connection.close();
    } catch (e) {
      print('Error fetching table list from PostgreSQL: $e');
    }
  }

  Future<void> createRestaurantTable() async {
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
            'restaurant_${user?.uid?.toLowerCase()}_${_tableNameController.text}';
      } else {
        tableName =
            'restaurant_${user?.uid?.toLowerCase()}_${DateTime.now().microsecondsSinceEpoch}';
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
        'INSERT INTO links (restaurant_table_name, linked_table_name) '
        "VALUES ('restaurant_${user?.uid?.toLowerCase()}', '$tableName')",
      );

      await fetchTableListFromPostgreSQL(); // Refresh the table list

      await connection.close();
    } catch (e) {
      print('Error creating restaurant table: $e');
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
    fetchTableListFromPostgreSQL();
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTable(tableName),
                  ),
                  onTap: () => navigateToTableView(tableName),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createRestaurantTable,
        child: Icon(Icons.add),
      ),
    );
  }
}
