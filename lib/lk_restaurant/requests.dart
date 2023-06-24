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
        currentUserId = user.uid; // Установка идентификатора текущего пользователя
      });
    }
  }

  Future<List<JoinRequest>> fetchJoinRequests() async {
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

      postgresConnection.close();

      final list = results.map((row) => JoinRequest(
        restaurantName: row[0] as String,
        userFullName: row[1] as String,
      )).toList();
      return list;
    } catch (e) {
      print('Error fetching join requests: $e');
      throw e;
    } finally {
      await postgresConnection.close();
    }
  }

  Future<String> _fetchUserRestaurant(PostgreSQLConnection connection, String currentUserId) async {
    final userRestaurantQuery = 'SELECT restaurant FROM restaurant WHERE user_id = \'$currentUserId\'';

    final userRestaurantResult = await connection.query(userRestaurantQuery);

    if (userRestaurantResult.isEmpty) {
      throw Exception('User restaurant not found');
    }

    final userRestaurant = userRestaurantResult[0][0] as String;
    return userRestaurant;
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
        "UPDATE users_sotrud SET name_rest = '$restaurantName'",
      );
      await postgresConnection.execute(
        "UPDATE join_requests SET status = 'accepted' WHERE restaurant_name = '$restaurantName'",
      );
      await postgresConnection.execute(
        "DELETE FROM join_requests WHERE restaurant_name = '$restaurantName'",
      );
      print('Join request accepted');

      Navigator.pushNamed(context, '/kabinet');
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
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<JoinRequest>>(
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
                          acceptJoinRequest(request.restaurantName);
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

  JoinRequest({
    required this.restaurantName,
    required this.userFullName,
  });
}
