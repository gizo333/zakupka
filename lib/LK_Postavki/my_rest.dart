import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:new_flut_proj/LK_Postavki/bottom_bar.dart';

import 'package:provider/provider.dart';

class MyRestPage extends StatefulWidget {
  @override
  _MyRestPageState createState() => _MyRestPageState();
}

class _MyRestPageState extends State<MyRestPage> {
  List<String> myRestaurants = [];

  void initState() {
    super.initState();
    // Получаем текущего пользователя
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Выполняем HTTP-запрос к API-маршруту на сервере, передавая user.uid
      fetchMyRestaurants(user.uid);
    }
  }

  Future<void> fetchMyRestaurants(String userId) async {
    final response = await https
        .get(Uri.parse('https://zakup.bar:9000/my_restaurants/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> restaurantNames = [];
      for (final restaurant in data) {
        final restaurantName = restaurant['restaurant_name'];
        if (restaurantName != null) {
          restaurantNames.add(restaurantName.toString());
        }
      }
      setState(() {
        myRestaurants = restaurantNames;
      });
    } else {
      throw Exception('Ошибка при загрузке данных');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomState = Provider.of<BottomNavState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyRest'),
      ),
      body: Center(
        child: Column(
          children: myRestaurants.map((restaurant) {
            return TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/zakaz');
                print('Вы выбрали ресторан: $restaurant');
              },
              child: Text(
                restaurant,
                style: const TextStyle(
                  color: Colors.blue, // Цвет текста кнопки
                  decoration:
                      TextDecoration.underline, // Добавление подчеркивания
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: buildMyBottomNavigationBar(
          context, bottomState.currentIndex, (index) {
        bottomState.setCurrentIndex(index);
      }),
    );
  }
}
