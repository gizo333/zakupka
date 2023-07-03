import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'restaurant_list_bloc.dart';

class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  bool buttonState = true;
  String searchQuery = '';

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, bool> joinRequests = {};

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
      final results = await postgresConnection.query(
          'SELECT restaurant FROM restaurant WHERE restaurant ILIKE @query',
          substitutionValues: {'query': '%$searchQuery%'}); // Используем ILIKE для регистро-независимого поиска
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
      final result = await postgresConnection.query(
          'SELECT full_name FROM users_sotrud WHERE user_id = \'$userId\'');
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

  Future<void> sendJoinRequest(String restaurantName, String userFullName,
      String userId) async {
    final restaurantListProvider = Provider.of<RestaurantListProvider>(
        context, listen: false);

    if (restaurantListProvider.selectedRestaurant != null) {
      final previousRestaurantName = restaurantListProvider.selectedRestaurant!;
      await cancelJoinRequest(previousRestaurantName, userId);
    }

    final postgresConnection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    final buttonStateValue = buttonState;

    try {
      await postgresConnection.open();
      await postgresConnection.execute(
        "INSERT INTO join_requests (restaurant_name, user_full_name, user_id, status, button_state) VALUES ('$restaurantName', '$userFullName', '$userId', 'pending', '$buttonStateValue')",
      );


      print('Join request sent successfully');

      // Обновление состояния запроса в провайдере
      restaurantListProvider.selectedRestaurant = restaurantName;
      if (!restaurantListProvider.joinRequests.containsKey(restaurantName)) {
        restaurantListProvider.joinRequests[restaurantName] = {};
      }
      restaurantListProvider.joinRequests[restaurantName]![userId] = 'pending';
      restaurantListProvider.notifyListeners();
    } catch (e) {
      print('Error sending join request: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  Future<void> cancelJoinRequest(String restaurantName, String userId) async {
    final restaurantListProvider = Provider.of<RestaurantListProvider>(
        context, listen: false);

    if (restaurantListProvider.selectedRestaurant == restaurantName) {
      restaurantListProvider.selectedRestaurant = null;
    }

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
        "DELETE FROM join_requests WHERE restaurant_name = '$restaurantName' AND user_id = '$userId'",
      );
      print('Join request canceled successfully');

      // Обновление состояния запроса в провайдере
      restaurantListProvider.joinRequests[restaurantName]?.remove(userId);
      restaurantListProvider.notifyListeners();
    } catch (e) {
      print('Error canceling join request: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _restaurantListProvider = Provider.of<RestaurantListProvider>(
        context);

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Поиск ресторанов',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchRestaurants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  final restaurants = snapshot.data!;
                  return FutureBuilder<User?>(
                    future: _firebaseAuth
                        .authStateChanges()
                        .first,
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (userSnapshot.hasData) {
                        final userId = userSnapshot.data!.uid;
                        return FutureBuilder<String>(
                          future: getUserFullName(userId),
                          builder: (context, fullNameSnapshot) {
                            if (fullNameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (fullNameSnapshot.hasData) {
                              final userFullName = fullNameSnapshot.data!;
                              return ListView.builder(
                                itemCount: restaurants.length,
                                itemBuilder: (context, index) {
                                  final name = restaurants[index];
                                  final isRequestSent =
                                      _restaurantListProvider.getRequestStatus(
                                          name, userId) == 'pending';

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(name),
                                        trailing: isRequestSent
                                            ? ElevatedButton(
                                          onPressed: () {
                                            cancelJoinRequest(
                                                name, userId);
                                          },
                                          child: Text('Отменить'),
                                        )
                                            : ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              buttonState = true;
                                            });
                                            sendJoinRequest(
                                                name,
                                                userFullName,
                                                userId);
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
                                child: Text(
                                    'Error: ${fullNameSnapshot.error}'),
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
          ),
        ],
      ),
    );
  }
}