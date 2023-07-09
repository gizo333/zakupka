import 'dart:convert';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../connect_BD/connect.dart';
import '/services/snack_bar.dart';
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHiddenPassword = true;
  bool isWrongPassword = false;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();

    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> login() async {
    final navigator = Navigator.of(context);
    final isValid = formKey.currentState!.validate();
    if (isValid == null || isValid == false) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );

      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          final postgresConnection = createDatabaseConnection();

          try {
            await postgresConnection.open();

            final query = 'SELECT * FROM users_sotrud WHERE user_id = @userId';
            final results = await postgresConnection.query(query, substitutionValues: {
              'userId': user.uid,
            });

            if (results.isNotEmpty) {
              final nameRest = results.first[6] as String?;

              if (nameRest != null && nameRest.isNotEmpty && nameRest != 'null') {
                navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
                return;
              } else {
                navigator.pushNamedAndRemoveUntil('/lk-user', (Route<dynamic> route) => false);
                return;
              }
            }

            final query2 = 'SELECT * FROM restaurant WHERE user_id = @userId';
            final results2 = await postgresConnection.query(query2, substitutionValues: {
              'userId': user.uid,
            });

            if (results2.isNotEmpty) {
              navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
              return;
            }

            final query3 = 'SELECT * FROM companies WHERE user_id = @userId';
            final results3 = await postgresConnection.query(query3, substitutionValues: {
              'userId': user.uid,
            });

            if (results3.isNotEmpty) {
              navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
              return;
            }
          } catch (e) {
            print(e);
          } finally {
            await postgresConnection.close();
          }
        } else {
          final tableName = 'users_sotrud';
          final fieldName = 'user_id';
          final url = Uri.parse('http://37.140.241.144:8080/api/$tableName/$fieldName');

          try {
            final response = await http.get(url);

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final userId = user.uid;

              final isUserFoundInUsersSotrud = data.contains(userId);

              if (isUserFoundInUsersSotrud) {
                navigator.pushNamedAndRemoveUntil('/lk-user', (Route<dynamic> route) => false);
                return;
              }

              final restaurantTableName = 'restaurant';
              final restaurantUrl = Uri.parse('http://37.140.241.144:8080/api/$restaurantTableName/user_id');
              final restaurantResponse = await http.get(restaurantUrl);

              if (restaurantResponse.statusCode == 200) {
                final restaurantData = jsonDecode(restaurantResponse.body);
                final isUserFoundInRestaurant = restaurantData.contains(userId);

                if (isUserFoundInRestaurant) {
                  navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
                  return;
                }
              } else {
                throw Exception('Ошибка при получении данных: ${restaurantResponse.statusCode}');
              }

              // Обработка случая, когда совпадение не найдено
            } else {
              throw Exception('Ошибка при получении данных: ${response.statusCode}');
            }
          } catch (e) {
            throw Exception('Ошибка при выполнении запроса: $e');
          }






        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e);

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() {
          isWrongPassword = true;
        });
        SnackBarService.showSnackBar(
          context,
          'Неправильный email или пароль. Повторите попытку',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
        return;
      }
    } catch (e) {
      print(e);
    }

    // По умолчанию переходим на страницу '/kabinet'
    // navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Войти'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                controller: emailTextInputController,
                validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Введите правильный Email'
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите Email',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                autocorrect: false,
                controller: passwordTextInputController,
                obscureText: isHiddenPassword,
                onChanged: (value) {
                  setState(() {
                    isWrongPassword = false;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Минимум 6 символов';
                  }
                  if (isWrongPassword) {
                    return 'Неверный пароль';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Введите пароль',
                  suffix: InkWell(
                    onTap: togglePasswordView,
                    child: Icon(
                      isHiddenPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isWrongPassword ? Colors.red : Colors.black,
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: login,
                child: const Center(child: Text('Войти')),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/signup'),
                child: const Text(
                  'Регистрация',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/reset_password'),
                child: const Text('Сбросить пароль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

