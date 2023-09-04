import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../list_to_rest/list_to_rest.dart';
import '../list_to_rest/restaurant_list_bloc.dart';

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
  Future<List<JoinRequest>> fetchJoinRequests() async {
    try {
      final usersUrl = Uri.parse('https://zakup.bar:8080/api/restaurant');
      final usersResponse = await https.get(usersUrl);

      final joinRequestsUrl1 =
          Uri.parse('https://zakup.bar:8080/api/join_requests');
      final joinRequestsResponse1 = await https.get(joinRequestsUrl1);

      final joinRequestsUrl2 =
          Uri.parse('https://zakup.bar:8080/api/comp_join_requests');
      final joinRequestsResponse2 = await https.get(joinRequestsUrl2);

      if (usersResponse.statusCode == 200 &&
          joinRequestsResponse1.statusCode == 200 &&
          joinRequestsResponse2.statusCode == 200) {
        final usersData = jsonDecode(usersResponse.body);
        final currentUser = usersData.firstWhere(
            (user) => user['user_id'] == currentUserId,
            orElse: () => null);

        if (currentUser == null) {
          throw Exception('Пользователь с ID $currentUserId не найден');
        }

        final userRestaurant = currentUser['restaurant'];

        if (userRestaurant == null) {
          throw Exception(
              'Авторизованный ресторан для пользователя с ID $currentUserId не найден');
        }

        final joinRequestsData1 = jsonDecode(joinRequestsResponse1.body);
        final joinRequestsData2 = jsonDecode(joinRequestsResponse2.body);

        final allJoinRequestsData = [
          ...joinRequestsData1,
          ...joinRequestsData2
        ];

        final filteredJoinRequestsList = allJoinRequestsData
            .where((item) => item['restaurant_name'] == userRestaurant)
            .map((item) => JoinRequest(
                  restaurantName: item['restaurant_name'],
                  userFullName: item['user_full_name'],
                  userId: item['user_id'],
                  nameCompany: item['name_company'] ?? '',
                ))
            .toList();

        return filteredJoinRequestsList;
      } else {
        throw Exception(
            'Ошибка при получении данных: Пользователи - ${usersResponse.statusCode}, Запросы на присоединение 1 - ${joinRequestsResponse1.statusCode}, Запросы на присоединение 2 - ${joinRequestsResponse2.statusCode}');
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
  Future<void> insertRestaurantUser(
      String restaurantName,
      String currentUserId,
      String nameRestInSotrud,
      String userId_sotrud,
      String userFullName) async {
    final restaurantUsersUrl =
        Uri.parse('https://zakup.bar:8080/api/restaurant_users');
    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({
      'restaurant_name': restaurantName,
      'user_id_in_restaurant': currentUserId,
      'name_rest_in_sotrud': nameRestInSotrud,
      'user_id_varchar': userId_sotrud,
      'full_name': userFullName,
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

  Future<void> insertCompRestaurant(String restaurantName, String nameCompany,
      String userFullName, String currentUserId, String userIdComp) async {
    final restaurantUsersUrl =
        Uri.parse('https://zakup.bar:9000/api/restaurant_comp');
    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({
      'restaurant_name': restaurantName,
      'name_comp': nameCompany,
      'fullname_user_comp': userFullName,
      'user_id_in_restaurant': currentUserId,
      'user_id_in_companies': userIdComp,
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

  Future<void> acceptCompJoinRequest(
      String restaurantName, String userId) async {
    // Определение URL для получения списка пользователей
    final userListUrl = Uri.parse('https://zakup.bar:8080/api/companies');

    // Заголовки для запросов (указание формата данных)
    final headers = {"Content-Type": "application/json"};

    try {
      // Отправка GET-запроса для получения списка пользователей
      final response = await https.get(userListUrl, headers: headers);

      // Проверка успешности GET-запроса
      if (response.statusCode == 200) {
        // Декодирование ответа в JSON-формате и преобразование в список
        final userList = jsonDecode(response.body) as List<dynamic>;

        // Поиск пользователя по userId в полученном списке
        final user = userList.firstWhere((user) => user['user_id'] == userId,
            orElse: () => null);

        if (user != null) {
          List<String> currentNameRest = user['name_rest'] != null
              ? List<String>.from(user['name_rest'])
              : [];

          currentNameRest.add(restaurantName);

          if (user['name_rest'] == null ||
              user['name_rest'] != restaurantName) {
            final updateUser = {
              'name_rest': restaurantName,
            };
            final updateUserJson = jsonEncode(updateUser);

            final updateUserUrl = Uri.parse(
                'https://zakup.bar:9000/api/companies/user_id/$userId'); // запись в массив БД
            final updateResponse = await https.patch(updateUserUrl,
                headers: headers, body: updateUserJson);

            // Проверка успешности PATCH-запроса
            if (updateResponse.statusCode == 200) {
              // Подготовка данных для обновления статуса
              final updateStatus = {
                'status': 'accepted',
              };
              final updateStatusJson = jsonEncode(updateStatus);

              // Определение URL для обновления статуса запроса на присоединение
              final updateStatusUrl = Uri.parse(
                  'https://zakup.bar:5000/status/comp_join_requests/user_id/${user['user_id']}'); // в работе

              // Отправка PATCH-запроса для обновления статуса запроса на присоединение
              final updateStatusResponse = await https.patch(updateStatusUrl,
                  headers: headers, body: updateStatusJson);

              // Проверка успешности PATCH-запроса для обновления статуса
              if (updateStatusResponse.statusCode == 200) {
                // Определение URL для удаления запроса на присоединение
                final deleteJoinRequestUrl = Uri.parse(
                    'https://zakup.bar:5000/delete/comp_join_requests/user_id/${user['user_id']}'); // в работе

                // Отправка DELETE-запроса для удаления запроса на присоединение
                final deleteResponse =
                    await https.delete(deleteJoinRequestUrl, headers: headers);

                // Проверка успешности DELETE-запроса
                if (deleteResponse.statusCode == 200) {
                  // Выполнение каких-либо действий при успешном удалении
                } else {
                  throw Exception(
                      'Error deleting request: ${deleteResponse.statusCode}');
                }
              } else {
                throw Exception(
                    'Error updating status: ${updateStatusResponse.statusCode}');
              }
            }
          } else {
            print('Field name_rest already set to the desired value');
            // Обработка случая, когда поле уже имеет требуемое значение
          }
        } else {
          print('User with user_id "$userId" not found');
          // Обработка случая, когда пользователь не найден
        }
      } else {
        throw Exception('Error getting user list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error accepting company join request: $e');
      throw e;
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
          if (user['name_rest'] == null ||
              user['name_rest'] != restaurantName) {
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
    final restaurantListProvider =
        Provider.of<RestaurantListProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запросы на присоединение'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: fetchJoinRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: const Color.fromARGB(255, 148, 136, 136)!,
                          width: 1,
                        ),
                      ),
                      title: Text(
                        request.restaurantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userFullName,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Запрос от пользователя: ${request.userFullName}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (request.nameCompany != null)
                            RichText(
                              text: TextSpan(
                                text: 'Запрос от компании: ',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic,
                                ),
                                children: [
                                  TextSpan(
                                    text: request.nameCompany,
                                    style: const TextStyle(
                                      color: Colors
                                          .red, // Замените на желаемый цвет
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (request.hasNameCompany) {
                                  await acceptCompJoinRequest(
                                    request.restaurantName,
                                    request.userId,
                                  );

                                  await insertCompRestaurant(
                                    request.restaurantName,
                                    request.nameCompany,
                                    request.userFullName,
                                    currentUserId,
                                    request.userId,
                                  );
                                } else if (request.hasNameCompany == false) {
                                  await acceptJoinRequest(
                                    request.restaurantName,
                                    request.userId,
                                  );

                                  final nameRestInSotrud =
                                      await getRestName(request.userId);
                                  if (nameRestInSotrud != null) {
                                    await insertRestaurantUser(
                                      request.restaurantName,
                                      currentUserId,
                                      nameRestInSotrud,
                                      request.userId,
                                      request.userFullName,
                                    );
                                  }
                                }

                                setState(() {});
                              },
                              child: const Text('Принять'),
                            ),
                          ),

                          SizedBox(height: 14), // Разделитель
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (request.hasNameCompany == false) {
                                  await restaurantListProvider
                                      .cancelSotrudJoinRequest(
                                          request.restaurantName,
                                          request.userId,
                                          restaurantListProvider);
                                } else if (request.hasNameCompany) {
                                  await restaurantListProvider
                                      .cancelJoinRequest(
                                          request.restaurantName,
                                          request.userId,
                                          restaurantListProvider);
                                }
                                setState(
                                    () {}); // Обновление списка после отмены
                              },
                              child: const Text(
                                  'Отменить'), // Добавленная кнопка "Отменить"
                            ),
                          ),
                        ],
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
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return const Center(
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
  final String userId;
  final String? nameCompany; // Добавленное поле
  final bool hasNameCompany;

  JoinRequest({
    required this.restaurantName,
    required this.userFullName,
    required this.userId,
    required this.nameCompany, // Включено в конструктор
  }) : hasNameCompany = nameCompany != null && nameCompany.isNotEmpty;
}
