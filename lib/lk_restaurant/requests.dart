

import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';


class JoinRequestsPage extends StatefulWidget {
  @override
  _JoinRequestsPageState createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  Future<List<String>> fetchJoinRequests() async {
    final postgresConnection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await postgresConnection.open();
      final userRestaurant = 'Erwin'; // Замените 'Erwin' на фактическое значение поля "user_restaurant"

      final results = await postgresConnection.query('''
  SELECT jr.restaurant_name
  FROM join_requests jr
  JOIN restaurant r ON jr.restaurant_name = r.restaurant
  WHERE r.restaurant = '$userRestaurant'
''');







      postgresConnection.close();

      final list = results.map((row) => row[0] as String).toList();
      return list;
    } catch (e) {
      print('Error fetching join requests: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  Future<void> acceptJoinRequest(String restaurantName) async {
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
      await postgresConnection.execute(
        "UPDATE join_requests SET status = 'accepted' WHERE restaurant_name = '${restaurantName}'",
      );
      print('Join request accepted');

      Navigator.pushNamed(context, '/kabinet'); // Переход на страницу '/kabinet' после принятия запроса
    } catch (e) {
      print('Error accepting join request: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Запросы на присоединение'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Возврат на предыдущую страницу
          },
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchJoinRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final joinRequests = snapshot.data!;
            return ListView.builder(
              itemCount: joinRequests.length,
              itemBuilder: (context, index) {
                final restaurantName = joinRequests[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(restaurantName),
                      trailing: ElevatedButton(
                        onPressed: () {
                          acceptJoinRequest(restaurantName); // Принятие запроса на присоединение
                        },
                        child: Text('Принять'),
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