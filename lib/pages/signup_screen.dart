import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController innController = TextEditingController();
  final TextEditingController restaurantController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool checkBoxValue1 = true; // По умолчанию checkBoxValue1 включен
  bool checkBoxValue2 = false;

  String? emailError;
  String? passwordError;

  Future<void> _registerUser(BuildContext context) async {
    // Проверка состояния обоих чекбоксов
    if (!(checkBoxValue1 || checkBoxValue2)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text('Выберите одно из условий'),
            actions: [
              TextButton(
                child: Text('ОК'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final String email = emailController.text.trim();
      final String password = passwordController.text;
      final String company = companyController.text.trim();
      final String phone = phoneController.text.trim();
      final String inn = innController.text.trim();
      final String restaurant = restaurantController.text.trim();
      final String fullName = fullNameController.text.trim();
      final String position = positionController.text.trim();

      // Проверка формата адреса электронной почты
      if (!isValidEmail(email)) {
        setState(() {
          emailError = 'Неправильный формат адреса электронной почты';
        });
        return;
      }

      // Проверка длины пароля
      if (password.length < 6) {
        setState(() {
          passwordError = 'Пароль должен содержать не менее 6 символов';
        });
        return;
      }

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (checkBoxValue2) {
          // Регистрация компании
          await _firestore.collection('companies').doc(user.uid).set({
            'email': email,
            'password': password,
            'company': company,
            'phone': phone,
            'inn': inn,
          });

          Navigator.pushReplacementNamed(context, '/account');
        } else if (checkBoxValue1) {
          // Регистрация пользователя-ресторана
          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'password': password,
            'restaurant': restaurant,
            'fullName': fullName,
            'position': position,
          });

          Navigator.pushReplacementNamed(context, '/kabinet');
        }
      }
    } catch (e) {
      // Обработка ошибок регистрации
      print(e);
    }
  }

  bool isValidEmail(String email) {
    // Проверка формата адреса электронной почты с использованием регулярного выражения
    final String emailRegex =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*\.[a-zA-Z\d-]{2,4}$';
    final RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorText: emailError,
                ),
                onChanged: (value) {
                  setState(() {
                    emailError = null;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  errorText: passwordError,
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    passwordError = null;
                  });
                },
              ),
              SizedBox(height: 16.0),
              if (checkBoxValue1) ...[
                TextField(
                  controller: restaurantController,
                  decoration: InputDecoration(
                    labelText: 'Ресторан',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'ФИО',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: 'Должность',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
              if (checkBoxValue2) ...[
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Название компании',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: innController,
                  decoration: InputDecoration(
                    labelText: 'ИНН',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: checkBoxValue1,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              checkBoxValue1 = value;
                              checkBoxValue2 = false; // Сбросить значение второго чекбокса
                            }
                          });
                        },
                      ),
                      Text('Вы Ресторан'),
                    ],
                  ),
                  SizedBox(width: 16.0),
                  Row(
                    children: [
                      Checkbox(
                        value: checkBoxValue2,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              checkBoxValue2 = value;
                              checkBoxValue1 = false; // Сбросить значение первого чекбокса
                            }
                          });
                        },
                      ),
                      Text('Вы Поставщик'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _registerUser(context),
                child: Text('Зарегистрироваться'),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
