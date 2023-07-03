import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_flut_proj/register/verify_email_screen.dart';
import 'package:postgres/postgres.dart';
import 'validation.dart';

class SignUpForm extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  SignUpForm({Key? key, required this.auth, required this.firestore});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController innController = TextEditingController();
  final TextEditingController restaurantController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  static bool checkBoxValue1 = true;
  static bool checkBoxValue2 = false;
  static bool checkBoxValue3 = false;
  String? emailError;
  String? passwordError;

  Future<void> _registerUser(BuildContext context) async {
    // Проверка состояния обоих чекбоксов
    if (!(checkBoxValue1 || checkBoxValue2 || checkBoxValue3)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Выберите одно из условий'),
            actions: [
              TextButton(
                child: const Text('ОК'),
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
      if (!Validation.isValidEmail(email)) {
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
          await widget.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (checkBoxValue2) {
          // Регистрация компании
          await widget.firestore.collection('companies').doc(user.uid).set({
            'email': email,
            'password': password,
            'company': company,
            'phone': phone,
            'inn': inn,
          });

          // Сохранение данных в PostgreSQL
          final connection = PostgreSQLConnection(
            '37.140.241.144',
            5432,
            'postgres',
            username: 'postgres',
            password: '1',
          );

          try {
            await connection.open();

            final query = '''
            INSERT INTO companies (user_id, email, password, company, phone, inn)
            VALUES (@userId, @email, @password, @company, @phone, @inn)
          ''';

            await connection.query(
              query,
              substitutionValues: {
                'userId': user.uid,
                'email': email,
                'password': password,
                'company': company,
                'phone': phone,
                'inn': inn,
              },
            );

            print('Соединение закрыто');
          } catch (e) {
            print(e);
          } finally {
            await connection.close();
          }
        } else if (checkBoxValue1) {
          // Регистрация пользователя-ресторана
          await widget.firestore.collection('restaurant').doc(user.uid).set({
            'email': email,
            'password': password,
            'restaurant': restaurant,
            'fullName': fullName,
            'position': position,
          });

          // Сохранение данных в PostgreSQL
          final connection = PostgreSQLConnection(
            '37.140.241.144',
            5432,
            'postgres',
            username: 'postgres',
            password: '1',
          );

          try {
            await connection.open();

            final query = '''
            INSERT INTO restaurant (user_id, email, password, restaurant, full_name, position)
            VALUES (@userId, @email, @password, @restaurant, @fullName, @position)
          ''';

            await connection.query(
              query,
              substitutionValues: {
                'userId': user.uid,
                'email': email,
                'password': password,
                'restaurant': restaurant,
                'fullName': fullName,
                'position': position,
              },
            );

            print('Соединение закрыто');
          } catch (e) {
            print(e);
          } finally {
            await connection.close();
          }
        } else if (checkBoxValue3) {
          // Регистрация пользователя-ресторана
          final currentUser = FirebaseAuth.instance.currentUser;
          await widget.firestore
              .collection('users_sotrud')
              .doc(currentUser?.uid)
              .set({
            'email': email,
            'password': password,
            'fullName': fullName,
            'position': position,
          });

          // Сохранение данных в PostgreSQL
          final connection = PostgreSQLConnection(
            '37.140.241.144',
            5432,
            'postgres',
            username: 'postgres',
            password: '1',
          );

          try {
            await connection.open();

            final query = '''
      INSERT INTO users_sotrud (user_id, email, password, full_name, position)
      VALUES (@userId, @email, @password, @fullName, @position)
    ''';

            await connection.query(
              query,
              substitutionValues: {
                'userId': currentUser?.uid,
                'email': email,
                'password': password,
                'fullName': fullName,
                'position': position,
              },
            );

            print('Соединение закрыто');
          } catch (e) {
            print(e);
          } finally {
            await connection.close();
          }
        }
      }
    } catch (e) {
      // Обработка ошибок регистрации
      print(e);
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyEmailScreen(
          checkBoxValue1: checkBoxValue1,
          checkBoxValue2: checkBoxValue2,
          checkBoxValue3: checkBoxValue3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (checkBoxValue3) ...[
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
        Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: checkBoxValue1,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        checkBoxValue1 = value;
                        checkBoxValue2 = false;
                        checkBoxValue3 =
                            false; // Сбросить значение второго чекбокса
                      }
                    });
                  },
                ),
                Text('Вы представитель ресторана'),
              ],
            ),
            SizedBox(width: 15.0),
            Row(
              children: [
                Checkbox(
                  value: checkBoxValue3,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        checkBoxValue3 = value;
                        checkBoxValue1 = false;
                        checkBoxValue2 = false;
                      }
                    });
                  },
                ),
                Text('Вы сотрудник ресторана'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: checkBoxValue2,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        checkBoxValue2 = value;
                        checkBoxValue1 = false;
                        checkBoxValue3 =
                            false; // Сбросить значение первого чекбокса
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
    );
  }
}
