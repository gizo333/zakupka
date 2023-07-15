import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../connect_BD/connect.dart';
import '../connect_BD/connect_web.dart';
import '../pages/account_screen.dart';
import 'dart:io';

class Kabinet extends StatefulWidget {
  const Kabinet({Key? key}) : super(key: key);

  @override
  _KabinetState createState() => _KabinetState();
}

class _KabinetState extends State<Kabinet> {
  final user = FirebaseAuth.instance.currentUser;
  String restaurantName = '';
  bool isInRestaurantTable = false;

  @override
  void initState() {
    super.initState();
    fetchRestaurantName();
  }

  void fetchRestaurantName() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Mobile device
      final postgresConnection = createDatabaseConnection();
      await postgresConnection.open();

      try {
        final userSotrudResults = await postgresConnection.query(
          'SELECT name_rest FROM users_sotrud WHERE user_id = @userId;',
          substitutionValues: {'userId': user?.uid},
        );

        final restaurantResults = await postgresConnection.query(
          'SELECT restaurant FROM restaurant WHERE user_id = @userId;',
          substitutionValues: {'userId': user?.uid},
        );

        if (userSotrudResults.isNotEmpty) {
          setState(() {
            restaurantName = userSotrudResults[0][0].toString();
          });
        } else if (restaurantResults.isNotEmpty) {
          setState(() {
            restaurantName = restaurantResults[0][0].toString();
            isInRestaurantTable = true;
          });
        }
      } finally {
        await postgresConnection.close();
      }
    } else {
      // Browser
      final userSotrudResults =
      await getDataFromServer('users_sotrud', 'user_id');
      final restaurantResults =
      await getDataFromServer('restaurant', 'user_id');
      final userId = user?.uid;

      if (userSotrudResults.isNotEmpty) {
        final isUserFoundInUsersSotrud = userSotrudResults.contains(userId);
        if (isUserFoundInUsersSotrud) {
          setState(() {
            restaurantName = userSotrudResults[0].toString();
          });
          return;
        }
      }

      if (restaurantResults.isNotEmpty) {
        final userId = user?.uid.toString();
        final restaurantUrl = 'http://37.140.241.144:8080/api/restaurant/';
        // final url = 'http://37.140.241.144:8080/api/restaurant/user_id';
        //
        // final response = await http.get(Uri.parse(url));
        //
        // if (response.statusCode == 200) {
        //   final data = jsonDecode(response.body) as List<dynamic>;
        //
        //   if (data.contains(userId)) {
        //     print('Массив данных содержит user.uid: $userId');
        //   } else {
        //     print('Массив данных не содержит user.uid: $userId');
        //   }
        // } else {
        //   print('Ошибка при получении данных: ${response.statusCode}');
        // }

        final restaurantResponse = await http.get(Uri.parse(restaurantUrl));
        if (restaurantResponse.statusCode == 200) {
          final restaurantData =
          jsonDecode(restaurantResponse.body) as List<dynamic>;

          final matchingRestaurant = restaurantData.firstWhere(
                (result) => result['user_id'] == userId,
            orElse: () => null,
          );

          if (matchingRestaurant != null) {
            restaurantName = matchingRestaurant['restaurant'].toString();
            setState(() {
              isInRestaurantTable = true;
            });
          } else {
            // Обработка случая, когда ресторан с указанным user_id не найден
          }
        } else {
          throw Exception(
              'Ошибка при получении данных: ${restaurantResponse.statusCode}');
        }
      }
    }
  }

  void goInvent() {
    if (user != null) {
      Navigator.pushNamed(context, '/table');
    }
  }

  void goStop() {
    if (user != null) {
      Navigator.pushNamed(context, '/requests');
    }
  }

  void goExcel() {
    if (user != null) {
      Navigator.pushNamed(context, '/excel');
    }
  }

  void goListsNavigator() {
    if (user != null) {
      Navigator.pushNamed(context, '/listsNavigator');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(restaurantName),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.account_circle,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: goExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Цвет фона третьей кнопки
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child:
                const Text("Excel", style: TextStyle(color: Colors.white)),
              ),
              if (isInRestaurantTable)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: goStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.black, // Цвет фона третьей кнопки
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text("Запросы",
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.black, // Цвет фона третьей кнопки
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: goListsNavigator,
                      child: const Text("Таблицы",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}