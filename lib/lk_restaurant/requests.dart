import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinRequestsPage extends StatefulWidget {
  @override
  _JoinRequestsPageState createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  String currentUserId = ''; // Идентификатор текущего пользователя
  @override
  void initState() {
    super.initState();
    getCurrentUser(); // Получение текущего пользователя при инициализации
  }

  Future<void> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId =
            user.uid; // Установка идентификатора текущего пользователя
      });
    }
  }

// чекает запросы к рестарану
  Future<dynamic> fetchJoinRequests() async {
    try {
      final usersUrl = Uri.parse('https://zakup.bar:8080/api/restaurant');
      final usersResponse = await https.get(usersUrl);
      String? userRestaurant;

      if (usersResponse.statusCode == 200) {
        final usersData = jsonDecode(usersResponse.body);
        final currentUser = usersData.firstWhere(
            (user) => user['user_id'] == currentUserId,
            orElse: () => null);

        if (currentUser == null) {
          throw Exception('Пользователь с ID $currentUserId не найден');
        }

        userRestaurant = currentUser['restaurant'];

        if (userRestaurant == null) {
          throw Exception(
              'Авторизованный ресторан для пользователя с ID $currentUserId не найден');
        }
      } else {
        throw Exception(
            'Ошибка при получении данных о пользователях: ${usersResponse.statusCode}');
      }

      final joinRequestsUrl =
          Uri.parse('https://zakup.bar:8080/api/join_requests');
      final joinRequestsResponse = await https.get(joinRequestsUrl);

      if (joinRequestsResponse.statusCode == 200) {
        final joinRequestsData = jsonDecode(joinRequestsResponse.body);
        final filteredJoinRequestsList = joinRequestsData
            .where((item) => item['restaurant_name'] == userRestaurant)
            .map((item) => JoinRequest(
                  restaurantName: item['restaurant_name'],
                  userFullName: item['user_full_name'],
                  userId: item['user_id'],
                ))
            .toList();

        return filteredJoinRequestsList;
      } else {
        throw Exception(
            'Ошибка при получении данных о запросах на присоединение: ${joinRequestsResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }

  Future<String> _fetchUserRestaurant(
      PostgreSQLConnection? connection, String userId) async {
    final url = Uri.parse('https://zakup.bar:8080/api/restaurant/user/$userId');

    try {
      final response = await https.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userRestaurant = data['restaurant'] as String;
        return userRestaurant;
      } else {
        throw Exception(
            'Ошибка при получении ресторана пользователя: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }

// получает id сотрудника который привязан к ресторану
  Future<String?> getUserId(String nameRest) async {
    final url =
        Uri.parse('https://zakup.bar:8080/api/users_sotrud/user_id/$nameRest');
    final response = await https.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Извлекаем значение 'user_id' из полученных данных
      String userId = data['user_id'];

      return userId;
    } else {
      print('Ошибка при получении user_id: ${response.statusCode}');
      return null;
    }
  }

// чекает принадлежит ли сотрудник ресторану
  Future<String?> getRestName(String userId) async {
    final url =
        Uri.parse('https://zakup.bar:8080/api/users_sotrud/name_rest/$userId');
    final response = await https.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['name_rest'];
    } else {
      print('Ошибка при получении rest_name: ${response.statusCode}');
      return null;
    }
  }

// функция вставляет значения в промежуточную таблицу, связывает ресторан с сотрудником
  Future<void> insertRestaurantUser(String restaurantName, String currentUserId,
      String nameRestInSotrud, String userId_sotrud) async {
    final restaurantUsersUrl =
        Uri.parse('https://zakup.bar:8080/api/restaurant_users');
    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({
      'restaurant_name': restaurantName,
      'user_id_in_restaurant': currentUserId,
      'name_rest_in_sotrud': nameRestInSotrud,
      'user_id_varchar': userId_sotrud,
    });
    try {
      final response =
          await https.post(restaurantUsersUrl, headers: headers, body: body);

      if (response.statusCode == 200) {
        //print('Успешная вставка'); // Успешная вставка
      } else {
        print('Ошибка при вставке: ${response.statusCode}'); // Обработка ошибки
        // print('Response body: ${response.body}'); // Вывод тела ответа
      }
    } catch (e) {
      print('Произошла ошибка при вставке данных: $e');
    }
  }

  Future<void> acceptJoinRequest(String restaurantName, String userId) async {
    final userListUrl = Uri.parse('https://zakup.bar:8080/api/users_sotrud');
    final headers = {"Content-Type": "application/json"};

    try {
      //print('Starting acceptJoinRequest function');

      final response = await https.get(userListUrl, headers: headers);
      //print('User list response status code: ${response.statusCode}');
      // print('User list response body: ${response.body}');

      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        // print('Received user list: $userList');

        final user = userList.firstWhere((user) => user['user_id'] == userId,
            orElse: () => null);
        if (user != null) {
          // Check if the name_rest field is null or different
          if (user['name_rest'] == null ||
              user['name_rest'] != restaurantName) {
            // print('Updating user data for user ID: ${user['user_id']}');
            // print('Restaurant name: $restaurantName');
            // print('User ID: $userId');

            final updateUser = {
              'name_rest': restaurantName,
            };
            final updateUserJson = jsonEncode(updateUser);
            //print('User ID for updating: ${user['user_id']}');
            final updateUserUrl = Uri.parse(
                'https://zakup.bar:8080/api/users_sotrud/user_id/$userId');

            final updateResponse = await https.patch(updateUserUrl,
                headers: headers, body: updateUserJson);

            // print('Update response status code: ${updateResponse.statusCode}');
            // print('Update response body: ${updateResponse.body}');

            if (updateResponse.statusCode == 200) {
              // Update status
              final updateStatus = {
                'status': 'accepted',
              };
              final updateStatusJson = jsonEncode(updateStatus);

              final updateStatusUrl = Uri.parse(
                  'https://zakup.bar:5000/status/join_requests/user_id/${user['user_id']}');

              final updateStatusResponse = await https.patch(updateStatusUrl,
                  headers: headers, body: updateStatusJson);

              // print(
              //     'Update status response status code: ${updateStatusResponse.statusCode}');
              // print(
              //     'Update status response body: ${updateStatusResponse.body}');

              if (updateStatusResponse.statusCode == 200) {
                // Delete join request
                final deleteJoinRequestUrl = Uri.parse(
                    'https://zakup.bar:5000/delete/join_requests/user_id/${user['user_id']}');

                final deleteResponse =
                    await https.delete(deleteJoinRequestUrl, headers: headers);

                // print(
                //     'Delete response status code: ${deleteResponse.statusCode}');
                // print('Delete response body: ${deleteResponse.body}');

                if (deleteResponse.statusCode == 200) {
                  //print('Join request successfully deleted');
                } else {
                  throw Exception(
                      'Error deleting request: ${deleteResponse.statusCode}');
                }
              } else {
                throw Exception(
                    'Error updating status: ${updateStatusResponse.statusCode}');
              }
            } else {
              print('Field name_rest already set to the desired value');
              // Handle case where the field is already set to the desired value
            }
          } else {
            print('Field name_rest already set');
            // Handle case where the field is already set
          }
        } else {
          print('User with user_id "$userId" not found');
          // Handle case where user is not found
        }
      } else {
        throw Exception('Error getting user list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error accepting join request: $e');
      throw e;
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
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<dynamic>(
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
                final request = joinRequests[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(request.restaurantName),
                      subtitle: Text(request.userFullName),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await acceptJoinRequest(
                              request.restaurantName, request.userId);

                          // Получаем имя ресторана
                          final nameRestInSotrud =
                              await getRestName(request.userId);

                          if (nameRestInSotrud != null) {
                            await insertRestaurantUser(
                                request.restaurantName,
                                currentUserId,
                                nameRestInSotrud,
                                request.userId);
                            print(
                                'Имя ресторана для пользователя ${request.userId}: $nameRestInSotrud');
                          } else {
                            print('Ошибка при получении имени ресторана');
                          }

                          setState(() {});
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

class JoinRequest {
  final String restaurantName;
  final String userFullName;
  final String userId; // Add userId property

  JoinRequest({
    required this.restaurantName,
    required this.userFullName,
    required this.userId, // Include userId in the constructor
  });
}
