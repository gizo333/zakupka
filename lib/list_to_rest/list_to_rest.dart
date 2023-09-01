import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../connect_BD/connect_web.dart';
import '../services/who.dart';
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
      print('Restaurant: $restaurant');
    }
  }

  Future<List<String>> fetchRestaurants(String searchQuery) async {
    List<dynamic> data = await getDataFromServer('restaurant', 'restaurant');
    List<String> filteredData = data
        .where((item) => item.contains(searchQuery))
        .cast<String>()
        .toList();

    return filteredData;
  }

// Получаем имя компании
  Future<String> getCompanyName(String userId) async {
    try {
      final response = await https.get(
        Uri.parse('https://zakup.bar:9000/api/name_company/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('name_company')) {
          return data['name_company'] as String;
        } else {
          print('Company name not found');
          return '';
        }
      } else if (response.statusCode == 404) {
        print('Company not found');
        return '';
      } else {
        throw Exception('Error getting company name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making request: $e');
      throw Exception('Error making request: $e');
    }
  }

// получаем имя пользователя
  Future<String> getUserCombinedFullName(String userId) async {
    try {
      final response = await https.get(
        Uri.parse('https://zakup.bar:8080/api/user_full_name/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('combined_full_name')) {
          return data['combined_full_name'] as String;
        } else {
          print('No such user');
          return '';
        }
      } else if (response.statusCode == 404) {
        print('Пользователь не найден');
        return '';
      } else {
        throw Exception('Ошибка при получении данных: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }

// Отправка запросов для поставщиков
  Future<void> sendCompJoinRequest(
      String restaurantName,
      String userFullName,
      String userId,
      String companyName,
      RestaurantListProvider restaurantListProvider) async {
    print('User Full Name: $userFullName');

    // Отменить предыдущий запрос, если есть
    if (restaurantListProvider.selectedRestaurant != null) {
      final previousRestaurantName = restaurantListProvider.selectedRestaurant!;
      final previousJoinRequestStatus = restaurantListProvider.getRequestStatus(
          previousRestaurantName, userId);
      if (previousJoinRequestStatus == 'pending') {
        await cancelJoinRequest(
            previousRestaurantName, userId, restaurantListProvider);
        print('Canceled previous join request for User ID: $userId');
      }
    }

    https
        .post(
      Uri.parse('https://zakup.bar:9000/api/comp_join_requests'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'restaurant_name': restaurantName,
        'user_full_name': userFullName,
        'user_id': userId,
        'status': 'pending',
        'name_company': companyName,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        print('Join request sent successfully');
        // Обновление состояния запроса в провайдере
        restaurantListProvider.selectedRestaurant = restaurantName;
        if (!restaurantListProvider.joinRequests.containsKey(restaurantName)) {
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
  }

// Отправка запросов за сотрудников
  Future<void> sendJoinRequest(String restaurantName, String userFullName,
      String userId, RestaurantListProvider restaurantListProvider) async {
    print('User Full Name: $userFullName');

    // Отменить предыдущий запрос, если есть
    if (restaurantListProvider.selectedRestaurant != null) {
      final previousRestaurantName = restaurantListProvider.selectedRestaurant!;
      final previousJoinRequestStatus = restaurantListProvider.getRequestStatus(
          previousRestaurantName, userId);
      if (previousJoinRequestStatus == 'pending') {
        await cancelSotrudJoinRequest(
            previousRestaurantName, userId, restaurantListProvider);
      }
    }

    https
        .post(
      Uri.parse('https://zakup.bar:8080/api/join_requests'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'restaurant_name': restaurantName,
        'user_full_name': userFullName,
        'user_id': userId,
        'status': 'pending',
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        print('Join request sent successfully');
        // Обновление состояния запроса в провайдере
        restaurantListProvider.selectedRestaurant = restaurantName;
        if (!restaurantListProvider.joinRequests.containsKey(restaurantName)) {
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
  }

// удаления запроса для поставщика
  Future<void> cancelJoinRequest(String restaurantName, String userId,
      RestaurantListProvider restaurantListProvider) async {
    print('Cancelling join request for User ID: $userId');

    final response = await companyConnect('comp_join_requests', '', body: {
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
    restaurantListProvider.joinRequests[restaurantName]?.remove(userId);
    restaurantListProvider.notifyListeners();
    print('Join request cancelled successfully for User ID2312321: $userId');
  }

// удаление запроса  для гостей
  Future<void> cancelSotrudJoinRequest(String restaurantName, String userId,
      RestaurantListProvider restaurantListProvider) async {
    print('Cancelling join request for User ID: $userId');

    final response = await sotrudConnect('join_requests', '', body: {
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
    restaurantListProvider.joinRequests[restaurantName]?.remove(userId);
    restaurantListProvider.notifyListeners();
    print('Join request cancelled successfully for User ID2312321: $userId');
  }

  @override
  Widget build(BuildContext context) {
    final _restaurantListProvider = Provider.of<RestaurantListProvider>(
      context,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список ресторанов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              decoration: const InputDecoration(
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  final restaurants = snapshot.data!;
                  return FutureBuilder<User?>(
                    future: _firebaseAuth.authStateChanges().first,
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (userSnapshot.hasData) {
                        final userId = userSnapshot.data!.uid;
                        return FutureBuilder<String>(
                          future: getUserCombinedFullName(userId),
                          builder: (context, fullNameSnapshot) {
                            switch (fullNameSnapshot.connectionState) {
                              case ConnectionState.none:
                                return const Text('Future not started yet');
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.active:
                                return const Text(
                                    'Future still active, not done yet');
                              case ConnectionState.done:
                                if (fullNameSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        'Error: ${fullNameSnapshot.error}'),
                                  );
                                } else if (fullNameSnapshot.hasData) {
                                  final userFullName = fullNameSnapshot.data!;
                                  return ListView.builder(
                                    itemCount: restaurants.length,
                                    itemBuilder: (context, index) {
                                      final name = restaurants[index];
                                      final isRequestSent =
                                          _restaurantListProvider
                                                  .getRequestStatus(
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
                                                          Who whoInstance =
                                                              Who();
                                                          await whoInstance
                                                              .WhoYou();
                                                          final restaurantListProvider =
                                                              // ignore: use_build_context_synchronously
                                                              Provider.of<
                                                                      RestaurantListProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          if (whoInstance
                                                              .sotrud) {
                                                            await cancelSotrudJoinRequest(
                                                                name,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                          if (whoInstance
                                                              .comp) {
                                                            await cancelJoinRequest(
                                                                name,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                          setState(() {
                                                            // Удалить запрос из списка и обновить состояние
                                                            _restaurantListProvider
                                                                .joinRequests[
                                                                    name]
                                                                ?.remove(
                                                                    userId);
                                                          });
                                                        },
                                                        child: const Text(
                                                            'Отменить'),
                                                      )
                                                    : ElevatedButton(
                                                        onPressed: () async {
                                                          Who whoInstance =
                                                              Who();
                                                          await whoInstance
                                                              .WhoYou();
                                                          final restaurantListProvider =
                                                              // ignore: use_build_context_synchronously
                                                              Provider.of<
                                                                      RestaurantListProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          String companyName =
                                                              await getCompanyName(
                                                                  userId);
                                                          if (whoInstance
                                                              .sotrud) {
                                                            await sendJoinRequest(
                                                                name,
                                                                userFullName,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                          if (whoInstance
                                                              .comp) {
                                                            await sendCompJoinRequest(
                                                              name,
                                                              userFullName,
                                                              userId,
                                                              companyName,
                                                              restaurantListProvider,
                                                            );
                                                          }
                                                          setState(() {
                                                            // Удалить предыдущий запрос и обновить состояние
                                                            _restaurantListProvider
                                                                .joinRequests
                                                                .forEach((key,
                                                                    value) {
                                                              if (value
                                                                  .containsKey(
                                                                      userId)) {
                                                                value.remove(
                                                                    userId);
                                                              }
                                                            });
                                                          });
                                                        },
                                                        child: const Text(
                                                            'Вступить'),
                                                      )
                                                : isRequestSent
                                                    ? ElevatedButton(
                                                        onPressed: () async {
                                                          Who whoInstance =
                                                              Who();
                                                          await whoInstance
                                                              .WhoYou();
                                                          final restaurantListProvider =
                                                              // ignore: use_build_context_synchronously
                                                              Provider.of<
                                                                      RestaurantListProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          if (whoInstance
                                                              .sotrud) {
                                                            await cancelSotrudJoinRequest(
                                                                name,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                          if (whoInstance
                                                              .comp) {
                                                            await cancelJoinRequest(
                                                                name,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Отменить'),
                                                      )
                                                    : ElevatedButton(
                                                        onPressed: () async {
                                                          Who whoInstance =
                                                              Who();
                                                          await whoInstance
                                                              .WhoYou();
                                                          String companyName =
                                                              await getCompanyName(
                                                                  userId);
                                                          final restaurantListProvider =
                                                              // ignore: use_build_context_synchronously
                                                              Provider.of<
                                                                      RestaurantListProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          if (whoInstance
                                                              .sotrud) {
                                                            await sendJoinRequest(
                                                                name,
                                                                userFullName,
                                                                userId,
                                                                restaurantListProvider);
                                                          }
                                                          if (whoInstance
                                                              .comp) {
                                                            await sendCompJoinRequest(
                                                              name,
                                                              userFullName,
                                                              userId,
                                                              companyName,
                                                              restaurantListProvider,
                                                            );
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Вступить'),
                                                      ),
                                          ),
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
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
                      return const Center(
                        child: Text('1'),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
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
