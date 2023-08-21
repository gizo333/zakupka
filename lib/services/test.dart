import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalData {
  static String? jwtToken;
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final String serverUrl = "https://zakup.bar:8080/api/login";
  late User? user;
  String? jwtToken;

  Future<void> createAndSaveToken() async {
    try {
      print("Отправка запроса на создание токена...");

      final requestHeaders = {"Content-Type": "application/json"};
      final requestBody = jsonEncode({"userId": user!.uid});

      print("Заголовки запроса: $requestHeaders");
      print("Тело запроса: $requestBody");

      final response = await https.post(Uri.parse(serverUrl),
          headers: requestHeaders, body: requestBody);

      print("Ответ сервера: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final token = jsonData['token'] as String;

        setState(() {
          jwtToken = token;
        });

        GlobalData.jwtToken = token; // Сохраните токен в GlobalData

        print("JWT Token: $jwtToken");
        print("Токен был успешно записан в переменную jwtToken");
      } else {
        print("Ошибка: ${response.statusCode}");
        throw Exception(
            'Не удалось создать токен. Код ошибки: ${response.statusCode}');
      }
    } catch (error) {
      print('Ошибка при отправке запроса: $error');
      throw Exception('Произошла ошибка');
    }
  }

  Future<void> refreshToken() async {
    try {
      if (jwtToken != null) {
        final requestHeaders = {"Content-Type": "application/json"};
        final requestBody = jsonEncode({"refreshToken": jwtToken});

        final response = await https.post(
            Uri.parse("https://zakup.bar:8080/api/refresh-token"),
            headers: requestHeaders,
            body: requestBody);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final newAccessToken = jsonData['accessToken'] as String;

          setState(() {
            GlobalData.jwtToken = newAccessToken;
            jwtToken = newAccessToken;
          });

          print("Новый JWT Token: $newAccessToken");
        } else {
          print("Ошибка при обновлении токена: ${response.statusCode}");
        }
      } else {
        print("JWT Token отсутствует");
      }
    } catch (error) {
      print('Ошибка при обновлении токена: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await createAndSaveToken();
              },
              child: Text('Получить JWT Token'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user != null) {
                  print("ID пользователя: ${user!.uid}");
                } else {
                  print("Пользователь не авторизован");
                }
              },
              child: Text('Вывести ID пользователя'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await refreshToken();
              },
              child: Text('Обновить токен'),
            ),
          ],
        ),
      ),
    );
  }
}
