import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';



class JoinRequestsPage extends StatefulWidget {
  @override
  _JoinRequestsPageState createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  String currentUserId = '';// Идентификатор текущего пользователя
  @override
  void initState() {
    super.initState();
    getCurrentUser(); // Получение текущего пользователя при инициализации
  }

  Future<void> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Установка идентификатора текущего пользователя
      });
    }
  }

  Future<dynamic> fetchJoinRequests() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final postgresConnection = PostgreSQLConnection(
        '37.140.241.144',
        5432,
        'postgres',
        username: 'postgres',
        password: '1',
      );

      try {
        await postgresConnection.open();
        final userRestaurant = await _fetchUserRestaurant(postgresConnection, currentUserId);
        final results = await postgresConnection.query('''
        SELECT jr.restaurant_name, jr.user_full_name
        FROM join_requests jr
        WHERE jr.restaurant_name = '$userRestaurant'
      ''');

        final list = results.map((row) => JoinRequest(
          restaurantName: row[0] as String,
          userFullName: row[1] as String,
          userId: '',
        )).toList();

        return list;
      } catch (e) {
        print('Error fetching join requests: $e');
        throw e;
      } finally {
        await postgresConnection.close();
      }
    } else {
      try {
        final usersUrl = Uri.parse('http://37.140.241.144:8080/api/restaurant');
        final usersResponse = await http.get(usersUrl);
        String? userRestaurant;

        if (usersResponse.statusCode == 200) {
          final usersData = jsonDecode(usersResponse.body);
          final currentUser = usersData.firstWhere((user) => user['user_id'] == currentUserId, orElse: () => null);

          if (currentUser == null) {
            throw Exception('Пользователь с ID $currentUserId не найден');
          }

          userRestaurant = currentUser['restaurant'];

          if (userRestaurant == null) {
            throw Exception('Авторизованный ресторан для пользователя с ID $currentUserId не найден');
          }
        } else {
          throw Exception('Ошибка при получении данных о пользователях: ${usersResponse.statusCode}');
        }

        final joinRequestsUrl = Uri.parse('http://37.140.241.144:8080/api/join_requests');
        final joinRequestsResponse = await http.get(joinRequestsUrl);


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
          throw Exception('Ошибка при получении данных о запросах на присоединение: ${joinRequestsResponse.statusCode}');
        }
      } catch (e) {
        throw Exception('Ошибка при выполнении запроса: $e');
      }
    }

  }



  Future<String> _fetchUserRestaurant(PostgreSQLConnection? connection,String userId) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final postgresConnection = connection ?? PostgreSQLConnection(
        '37.140.241.144',
        5432,
        'postgres',
        username: 'postgres',
        password: '1',
      );

      try {
        if (postgresConnection.isClosed) {
          await postgresConnection.open();
        }

        final userRestaurantQuery = 'SELECT restaurant FROM restaurant WHERE user_id = \'$userId\'';
        final userRestaurantResult = await postgresConnection.query(userRestaurantQuery);

        if (userRestaurantResult.isEmpty) {
          throw Exception('User restaurant not found');
        }

        final userRestaurant = userRestaurantResult[0][0] as String;
        return userRestaurant;
      } catch (e) {
        throw Exception('Error fetching user restaurant: $e');
      } finally {
        if (connection == null && !postgresConnection.isClosed) {
          await postgresConnection.close();
        }
      }
    } else {
      final url = Uri.parse('http://37.140.241.144:8080/api/restaurant/user/$userId');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final userRestaurant = data['restaurant'] as String;
          return userRestaurant;
        } else {
          throw Exception('Ошибка при получении ресторана пользователя: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Ошибка при выполнении запроса: $e');
      }
    }
  }









  Future<void> acceptJoinRequest(String restaurantName, String userId) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Код для мобильных устройств
      final postgresConnection = PostgreSQLConnection(
        '37.140.241.144',
        5432,
        'postgres',
        username: 'postgres',
        password: '1',
      );

      try {
        await postgresConnection.open();
        final userIdResult = await postgresConnection.query(
          "SELECT user_id FROM join_requests WHERE restaurant_name = '$restaurantName' AND status = 'pending'",
        );

        if (userIdResult.isNotEmpty) {
          final userId = userIdResult.first[0] as String;
          await postgresConnection.execute(
            "UPDATE join_requests SET status = 'accepted' WHERE user_id = '$userId' AND restaurant_name = '$restaurantName' AND status = 'pending'",
          );

          // Обновление поля name_rest в таблице users_sotrud
          await postgresConnection.execute(
            "UPDATE users_sotrud SET name_rest = '$restaurantName' WHERE user_id = '$userId'",
          );

          print('Join request accepted');

          // Navigator.pushNamed(context, '/kabinet');
        }
      }
      catch (e) {
        print('Error accepting join request: $e');
        throw e;
      }
        } else {
          final userListUrl = Uri.parse(
              'http://37.140.241.144:8080/api/users_sotrud');
          final headers = {"Content-Type": "application/json"};

          try {
            final response = await http.get(userListUrl, headers: headers);

            if (response.statusCode == 200) {
              final userList = jsonDecode(response.body) as List<dynamic>;

              final user = userList.firstWhere((user) =>
              user['user_id'] == userId, orElse: () => null);
              if (user != null) {
                final updateUser = {
                  'name_rest': restaurantName,
                };
                final updateUserJson = jsonEncode(updateUser);

                final updateUserUrl = Uri.parse(
                    'http://37.140.241.144:8080/api/users_sotrud/user_id/${user['user_id']}');

                final updateResponse = await http.patch(
                    updateUserUrl, headers: headers, body: updateUserJson);

                if (updateResponse.statusCode == 200) {
                  // Update status to 'accepted' after the initial update
                  final updateStatus = {
                    'status': 'accepted',
                  };
                  final updateStatusJson = jsonEncode(updateStatus);

                  final updateStatusUrl = Uri.parse(
                      'http://37.140.241.144:5000/status/join_requests/user_id/${user['user_id']}');

                  final updateStatusResponse = await http.patch(
                      updateStatusUrl, headers: headers, body: updateStatusJson);

                  if (updateStatusResponse.statusCode == 200) {
                    // Status update successful
                  } else {
                    throw Exception(
                        'Ошибка при обновлении статуса: ${updateStatusResponse.statusCode}');
                  }

                  // Navigator.pushNamed(context, '/kabinet');
                } else if (updateResponse.statusCode == 404) {
                  throw Exception('User not found: $userId');
                } else {
                  throw Exception(
                      'Ошибка при обновлении данных: ${updateResponse.statusCode}');
                }
              } else {
                print('Пользователь с user_id "$userId" не найден');
                // Добавьте здесь обработку, если пользователь не найден
              }
            } else {
              throw Exception(
                  'Ошибка при получении списка пользователей: ${response.statusCode}');
            }

          } catch (e) {
            print('Error accepting join request: $e');
            throw e;
          }
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
                        onPressed: () {
                          acceptJoinRequest(request.restaurantName, request.userId);
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