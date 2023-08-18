import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
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

  Future<void> fetchTableListFromPostgreSQLWeb() async {
    final user = FirebaseAuth.instance.currentUser;

    final url = Uri.parse('https://zakup.bar:8080/api/restaurant_users');

    try {
      if (user != null) {
        final response = await https.get(url);

        if (response.statusCode == 200) {
          final userList = json.decode(response.body) as List<dynamic>;

          final userRestaurant = userList
              .cast<Map<String, dynamic>>()
              .firstWhere((userMap) => userMap['user_id_varchar'] == user.uid,
                  orElse: () => {});

          if (userRestaurant.isNotEmpty) {
            final userRestaurantId = userRestaurant['user_id_in_restaurant'];

            final userRestaurantPrefix = 'r_${userRestaurantId.toLowerCase()}_';

            final responseTables = await https.get(
              Uri.parse('https://zakup.bar:8085/api/tables/alltables'),
            );

            if (responseTables.statusCode == 200) {
              final tables = json.decode(responseTables.body) as List<dynamic>;

              final filteredTables = tables
                  .cast<String>()
                  .where(
                      (tableName) => tableName.startsWith(userRestaurantPrefix))
                  .toList();

              setState(() {
                _tableList = filteredTables;
              });
            } else {
              print(
                  'Error fetching table list from API: ${responseTables.statusCode}');
            }
          } else {
            print('User is not associated with a restaurant');
          }
        } else {
          print('Error fetching user data from API: ${response.statusCode}');
        }
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error fetching data from API: $e');
    }
  }

  Future<void> visionRest() async {
    final user = FirebaseAuth.instance.currentUser;

    final url = Uri.parse('https://zakup.bar:8085/api/tables/alltables');

    try {
      final response = await https.get(url);

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

  Future<void> createrTableWeb() async {
    final user = FirebaseAuth.instance.currentUser?.uid;
    final url = Uri.parse('https://zakup.bar:8085/api/tables/create');
    final tableName = _tableNameController.text.isNotEmpty
        ? _tableNameController.text
        : DateTime.now().microsecondsSinceEpoch.toString();

    final body = json.encode({
      'tableName': tableName,
      'user': user,
    });

    try {
      final response = await https.post(url,
          headers: {
            'Content-Type': 'application/json',
            // 'user': user.toString(),
          },
          body: body);
      if (response.statusCode == 200) {
        // Таблица успешно создана, выполните действия, необходимые после создания
        await fetchTableListFromPostgreSQLWeb();
        await visionRest();
      } else {
        print('Ошибка создания таблицы: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка создания таблицы: $e');
    }
  }

  Future<void> deleteTableWeb(String tableName) async {
    final apiUrl =
        'https://zakup.bar:8085/api/tables/deletetable/' '$tableName';

    try {
      final response = await https.delete(Uri.parse(apiUrl));

      await fetchTableListFromPostgreSQLWeb();
      await visionRest();

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

    fetchTableListFromPostgreSQLWeb();
    visionRest();
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
                    mainAxisSize: MainAxisSize
                        .min, // Задает основной размер по минимальному значению
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.file_download), // Иконка загрузки
                        onPressed: () {
                          downloadTable(
                              '$tableName'); // Вместо 'your_table_name' укажите имя вашей таблицы
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await deleteTableWeb(tableName);
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
          await createrTableWeb();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
