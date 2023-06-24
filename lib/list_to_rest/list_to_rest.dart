import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgres/postgres.dart';

class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, bool> joinRequests = {}; // Словарь для хранения состояний запросов для каждого ресторана

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

  Future<String> getUserFullName(String userId) async {
    final postgresConnection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await postgresConnection.open();
      final result = await postgresConnection.query('SELECT full_name FROM users_sotrud WHERE user_id = \'$userId\'');
      postgresConnection.close();

      if (result.isNotEmpty) {
        final fullName = result.first[0] as String;
        return fullName;
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching user full name: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }


  Future<void> sendJoinRequest(String restaurantName, String userFullName) async {
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
        "INSERT INTO join_requests (restaurant_name, user_full_name, status) VALUES ('$restaurantName', '$userFullName', 'pending')",
      );
      print('Join request sent successfully');
      // После успешной отправки запроса, устанавливаем состояние запроса для данного ресторана и пользователя
      setState(() {
        joinRequests[restaurantName] = true;
      });
    } catch (e) {
      print('Error sending join request: $e');
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
            return FutureBuilder<User?>(
              future: _firebaseAuth.authStateChanges().first,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (userSnapshot.hasData) {
                  final userId = userSnapshot.data!.uid;
                  return FutureBuilder<String>(
                    future: getUserFullName(userId),
                    builder: (context, fullNameSnapshot) {
                      if (fullNameSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (fullNameSnapshot.hasData) {
                        final userFullName = fullNameSnapshot.data!;
                        return ListView.builder(
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final name = restaurants[index];
                            final isRequestSent = joinRequests[name] ?? false; // Получаем состояние запроса для данного ресторана и пользователя

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(name),
                                  trailing: ElevatedButton(
                                    onPressed: isRequestSent
                                        ? null // Если запрос отправлен, делаем кнопку недоступной
                                        : () {
                                      sendJoinRequest(name, userFullName); // Отправка запроса на присоединение к ресторану с именем пользователя
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
                      } else if (fullNameSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${fullNameSnapshot.error}'),
                        );
                      }

                      return Center(
                        child: Text('No data available'),
                      );
                    },
                  );
                } else if (userSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${userSnapshot.error}'),
                  );
                }

                return Center(
                  child: Text('No data available'),
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
