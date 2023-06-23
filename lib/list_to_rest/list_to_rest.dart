import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  Future<List<String>> fetchRestaurants() async {
    final postgresConnection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await postgresConnection.open();
      final results = await postgresConnection.query('SELECT restaurant FROM restaurant');
      postgresConnection.close();

      final list = results.map((row) => row[0] as String).toList();
      return list;
    } catch (e) {
      print('Error fetching restaurants: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  Future<void> addToUsersTable(String restaurantName) async {
    final postgresConnection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await postgresConnection.open();
      await postgresConnection.execute(
        "UPDATE users_sotrud SET name_rest = '${restaurantName}'",
      );
      print('Record updated successfully');
    } catch (e) {
      print('Error updating record: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список ресторанов'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Возврат на предыдущую страницу
          },
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final restaurants = snapshot.data!;
            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final name = restaurants[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(name),
                      trailing: ElevatedButton(
                        onPressed: () {
                          addToUsersTable(name); // Запись названия ресторана в таблицу users_sotrud
                          // Действия при нажатии на кнопку "Вступить"
                          // Можно добавить навигацию на другую страницу или выполнить другие операции
                        },
                        child: Text('Вступить'),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }
}
