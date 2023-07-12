import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../connect_BD/connect.dart';
import '../connect_BD/connect_web.dart';
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


  Future<void> fetchAndPrintRestaurants() async {
    List<String> restaurants = await fetchRestaurants();
    for (var restaurant in restaurants) {
      print('Restaurant: $restaurant');
    }
  }


  Future<List<String>> fetchRestaurants({String searchQuery = ''}) async {
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      List<dynamic> data = await getDataFromServer('restaurant', 'restaurant');
      print('Received data: $data');  // Add this line to log the data
      return data.cast<String>();
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Использовать Postgres для Android и IOS
      final postgresConnection = createDatabaseConnection();

      try {
        await postgresConnection.open();
        final results = await postgresConnection.query(
          'SELECT restaurant FROM restaurant WHERE restaurant ILIKE @query',
          substitutionValues: {'query': '%$searchQuery%'},
        );

        final list = results.map((row) => row[0] as String).toList();
        return list;
      } catch (e) {
        print('Error fetching restaurants: $e');
        throw e;
      } finally {
        await postgresConnection.close();
      }
    } else {
      throw UnsupportedError('This platform is not supported');
    }
  }


  Future<String> getUserFullName(String userId) async {
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      List<dynamic> data = await getDataFromServer('users_sotrud', userId);
      return data.isNotEmpty ? data.first as String : '';
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Использовать Postgres для Android и IOS
      final postgresConnection = createDatabaseConnection();

      try {
        await postgresConnection.open();
        final result = await postgresConnection.query(
          'SELECT full_name FROM users_sotrud WHERE user_id = \'$userId\'',
        );

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
    } else {
      throw UnsupportedError('This platform is not supported');
    }
  }

  Future<void> sendJoinRequest(String restaurantName, String userFullName, String userId, RestaurantListProvider restaurantListProvider) async {
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      await executeServerRequest('join_requests', '', body: {
        "restaurant_name": restaurantName,
        "user_full_name": userFullName,
        "user_id": userId,
        "status": "pending",
        "button_state": buttonState,
        "operation": "insert"
      });
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Использовать Postgres для Android и IOS
      if (restaurantListProvider.selectedRestaurant != null) {
        final previousRestaurantName = restaurantListProvider.selectedRestaurant!;
        await cancelJoinRequest(previousRestaurantName, userId, restaurantListProvider);
      }

      final postgresConnection = createDatabaseConnection();

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
    } else {
      throw UnsupportedError('This platform is not supported');
    }
  }



  Future<void> cancelJoinRequest(String restaurantName, String userId, RestaurantListProvider restaurantListProvider) async {
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      await executeServerRequest('join_requests', '', body: {
        "restaurant_name": restaurantName,
        "user_id": userId,
        "operation": "delete"
      });
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Использовать Postgres для Android и IOS
      if (restaurantListProvider.selectedRestaurant == restaurantName) {
        restaurantListProvider.selectedRestaurant = null;
      }

      final postgresConnection = createDatabaseConnection();

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
    } else {
      throw UnsupportedError('This platform is not supported');
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
                                            final restaurantListProvider = Provider.of<RestaurantListProvider>(context, listen: false);
                                           // cancelJoinRequest(name, userId, restaurantListProvider);
                                          },
                                          child: Text('Отменить'),
                                        )

                                            : ElevatedButton(
                                          onPressed: () {
                                            final restaurantListProvider = Provider.of<RestaurantListProvider>(context, listen: false);
                                            setState(() {
                                              buttonState = true;
                                            });
                                           // sendJoinRequest(name, userFullName, userId, restaurantListProvider);
                                          },
                                          child: Text('Вступить'),
                                        )
                                        ,
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
                              child: Text('3'),
                            );
                          },
                        );



                      } else if (userSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${userSnapshot.error}'),
                        );
                      }

                      return Center(
                        child: Text('1'),
                      );
                    },
                  );



                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                return Center(
                  child: Text('2'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}