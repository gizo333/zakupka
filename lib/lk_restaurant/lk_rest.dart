import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../connect_BD/connect.dart';
import '../connect_BD/connect_web.dart';
import '../pages/account_screen.dart';
import 'dart:io';
import '../services/test.dart';
import '../services/who.dart';

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
    Who().WhoYou();
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
      Navigator.pushNamed(context, '/test');
    }
  }

  void goListsNavigator() {
    if (user != null) {
      Navigator.pushNamed(context, '/listsNavigator');
    }
  }

  void fetchRestaurantName() async {
    print("Sending JWT Token: ${GlobalData.jwtToken}");
    // Browser
    final userSotrudResults =
        await getDataFromServer('users_sotrud', 'user_id');
    final restaurantResults = await getDataFromServer('restaurant', 'user_id');
    final userId = user?.uid;

    if (userSotrudResults.isNotEmpty) {
      final isUserFoundInUsersSotrud = userSotrudResults.contains(userId);
      if (isUserFoundInUsersSotrud) {
        if (mounted) {
          setState(() {
            restaurantName = userSotrudResults[0].toString();
          });
        }
        return;
      }
    }
    if (restaurantResults.isNotEmpty) {
      final userId = user?.uid.toString();
      final restaurantUrl = 'https://zakup.bar:8080/api/restaurant/';
      final restaurantResponse = await https.get(
        Uri.parse(restaurantUrl),
        headers: {'Authorization': 'Bearer ${GlobalData.jwtToken}'},
      );

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

  void navigatorToCheckout() {
    if (user != null) {
      Navigator.pushNamed(context, '/checkoutNavigator');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(38, 37, 35, 1),
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
          child: Container(
            color: const Color.fromRGBO(47, 46, 42, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: goExcel,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Excel", style: TextStyle(color: Colors.white)),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 0)),
                        Text(
                          'I dont know what is it',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (GlobalData.jwtToken != null) {
                        print("JWT Token: ${GlobalData.jwtToken}");
                      } else {
                        print("Токен еще не получен");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Вывести JWT Token",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: goListsNavigator,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Taблицы", style: TextStyle(color: Colors.white)),
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                        Text(
                          'Простой способ провести инвентаризацию',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: navigatorToCheckout,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Заказ", style: TextStyle(color: Colors.white)),
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                        Text(
                          'Формирует заказ и отправляет поставщику',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                if (Who().rest) SizedBox(height: 8),
                ElevatedButton(
                  onPressed: goStop,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Запросы", style: TextStyle(color: Colors.white)),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
