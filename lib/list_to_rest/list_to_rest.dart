import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    List<String> restaurants = await fetchRestaurants(searchQuery);
    for (var restaurant in restaurants) {
      //print('Restaurant: $restaurant');
    }
  }
  Future<List<String>> fetchRestaurants(String searchQuery) async {
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      List<dynamic> data = await getDataFromServer('restaurant', 'restaurant');
      List<String> filteredData = data.where((item) => item.contains(searchQuery)).cast<String>().toList();
      return filteredData;
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
      Map<String, dynamic> data = await getUserData('users_sotrud', userId);
      if (data.isNotEmpty) {
        return data['full_name'] ?? '';
      } else {
        print('No such user');
        return '';
      }
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Использовать Postgres для Android и IOS
      final postgresConnection = createDatabaseConnection();

      try {
        await postgresConnection.open();
        final result = await postgresConnection.query(
          'SELECT full_name FROM users_sotrud WHERE user_id = \'$userId\'',
        );

        if (result.isNotEmpty) {
          final fullName = result.first[0] as String?;
          return fullName ?? '';
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
    print('User Full Name: $userFullName');

    // Отменить предыдущий запрос, если есть
    if (restaurantListProvider.selectedRestaurant != null) {
      final previousRestaurantName = restaurantListProvider.selectedRestaurant!;
      final previousJoinRequestStatus = restaurantListProvider.getRequestStatus(previousRestaurantName, userId);
      if (previousJoinRequestStatus == 'pending') {
        await cancelJoinRequest(previousRestaurantName, userId, restaurantListProvider);
      }
    }
    // Отправка нового запроса на вступление
    if (kIsWeb) {
      // Использовать HTTP для веб-версии
      http.post(
        Uri.parse('http://37.140.241.144:8080/api/join_requests'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'restaurant_name': restaurantName,
          'user_full_name': userFullName,
          'user_id': userId,
          'status': 'pending',
        }),
      ).then((response) {
        if (response.statusCode == 200) {
          print('Join request sent successfully');
          // Обновление состояния запроса в провайдере
          restaurantListProvider.selectedRestaurant = restaurantName;
          if (!restaurantListProvider.joinRequests.containsKey(
              restaurantName)) {
            restaurantListProvider.joinRequests[restaurantName] = {};
          }
          restaurantListProvider.joinRequests[restaurantName]![userId] =
          'pending';
          restaurantListProvider.notifyListeners();
        } else {
          print('Error sending join request: ${response.statusCode}');
          throw Exception('Failed to send join request');
        }
      }).catchError((error) {
        print('Error sending join request: $error');
        throw error;
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
      final response = await executeServerRequest('join_requests', '', body: {
        "restaurant_name": restaurantName,
        "user_id": userId,
        "operation": "delete"
      });
      if (response.containsKey('error')) {
        // Обработка ошибки при удалении записи
        print('Error canceling join request: ${response['error']}');
        throw Exception('Error canceling join request');
      } else {
        // Успешное удаление записи
        print('Join request canceled successfully');
        // Дополнительные действия после успешного удаления записи
      }
      if (restaurantListProvider.currentJoinRequestRestaurant == restaurantName) {
        restaurantListProvider.currentJoinRequestRestaurant = null;
      }

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
      context,
    );
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
              future: fetchRestaurants(searchQuery),
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
                            switch (fullNameSnapshot.connectionState) {
                              case ConnectionState.none:
                                return Text('Future not started yet');
                              case ConnectionState.waiting:
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.active:
                                return Text(
                                    'Future still active, not done yet');
                              case ConnectionState.done:
                                if (fullNameSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        'Error: ${fullNameSnapshot.error}'),
                                  );
                                } else if (fullNameSnapshot.hasData) {
                                  final userFullName =
                                  fullNameSnapshot.data!;
                                  return ListView.builder(
                                    itemCount: restaurants.length,
                                    itemBuilder: (context, index) {
                                      final name = restaurants[index];
                                      final isRequestSent =
                                          _restaurantListProvider.getRequestStatus(
                                              name, userId) ==
                                              'pending';
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(name),
                                            trailing: kIsWeb
                                                ? isRequestSent
                                                ? ElevatedButton(
                                              onPressed: () async {
                                                final restaurantListProvider =
                                                Provider.of<
                                                    RestaurantListProvider>(
                                                    context,
                                                    listen: false);
                                                await cancelJoinRequest(
                                                    name,
                                                    userId,
                                                    restaurantListProvider);
                                                setState(() {
                                                  // Удалить запрос из списка и обновить состояние
                                                  _restaurantListProvider
                                                      .joinRequests[name]
                                                      ?.remove(userId);
                                                });
                                              },
                                              child: Text('Отменить'),
                                            )
                                                : ElevatedButton(
                                              onPressed: () async {
                                                final restaurantListProvider =
                                                Provider.of<
                                                    RestaurantListProvider>(
                                                    context,
                                                    listen: false);
                                                await sendJoinRequest(
                                                    name,
                                                    userFullName,
                                                    userId,
                                                    restaurantListProvider);
                                                setState(() {
                                                  // Удалить предыдущий запрос и обновить состояние
                                                  _restaurantListProvider
                                                      .joinRequests
                                                      .forEach((key, value) {
                                                    if (value.containsKey(
                                                        userId)) {
                                                      value.remove(userId);
                                                    }
                                                  });
                                                });
                                              },
                                              child: Text('Вступить'),
                                            )
                                                : isRequestSent
                                                ? ElevatedButton(
                                              onPressed: () async {
                                                final restaurantListProvider =
                                                Provider.of<
                                                    RestaurantListProvider>(
                                                    context,
                                                    listen: false);
                                                await cancelJoinRequest(
                                                    name,
                                                    userId,
                                                    restaurantListProvider);
                                              },
                                              child: Text('Отменить'),
                                            )
                                                : ElevatedButton(
                                              onPressed: () async {
                                                final restaurantListProvider =
                                                Provider.of<
                                                    RestaurantListProvider>(
                                                    context,
                                                    listen: false);
                                                await sendJoinRequest(
                                                    name,
                                                    userFullName,
                                                    userId,
                                                    restaurantListProvider);
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
                                } else {
                                  return Center(
                                    child: Text('Unknown error occurred'),
                                  );
                                }
                            }
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