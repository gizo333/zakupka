import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_flut_proj/register/verify_email_screen.dart';
import '../animation/question.dart';
import 'validation.dart';
import 'dart:convert';
import 'package:http/http.dart' as https;

class SignUpForm extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  SignUpForm({Key? key, required this.auth, required this.firestore});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isButtonActive = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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
  String? confirmPasswordError;

  bool isRegistrationButtonActive() {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String company = companyController.text.trim();
    final String phone = phoneController.text.trim();
    final String inn = innController.text.trim();
    final String restaurant = restaurantController.text.trim();
    final String fullName = fullNameController.text.trim();
    final String position = positionController.text.trim();

    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        checkPasswordsMatch() &&
        (_isButtonActive ||
            checkBoxValue1 ||
            checkBoxValue2 ||
            checkBoxValue3) &&
        ((checkBoxValue1 &&
                restaurant.isNotEmpty &&
                fullName.isNotEmpty &&
                position.isNotEmpty) ||
            (checkBoxValue2 &&
                company.isNotEmpty &&
                phone.isNotEmpty &&
                inn.isNotEmpty) ||
            (checkBoxValue3 && fullName.isNotEmpty && position.isNotEmpty));
  }

  Future<bool> checkEmailExists(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final Future<QuerySnapshot> snapshotUsers = firestore
        .collection('users_sotrud')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final Future<QuerySnapshot> snapshotRestaurant = firestore
        .collection('restaurant')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final Future<QuerySnapshot> snapshotCompanies = firestore
        .collection('companies')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final results = await Future.wait(
        [snapshotUsers, snapshotRestaurant, snapshotCompanies]);

    for (QuerySnapshot result in results) {
      if (result.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<void> _registerUser(BuildContext context) async {
    // Проверка состояния обоих чекбоксов

    if (!(checkBoxValue1 || checkBoxValue2 || checkBoxValue3)) {
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
      final String confirmPassword = confirmPasswordController.text;
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

      // Проверка совпадения паролей
      if (password != confirmPassword) {
        setState(() {
          confirmPasswordError = 'Пароли не совпадают';
        });
        return;
      }

      setState(() {
        emailError = null;
        passwordError = null;
        confirmPasswordError = null;
      });

      final bool emailExists = await checkEmailExists(email);

      if (emailExists) {
        setState(() {
          emailError = 'Указанный email уже существует';
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

          var url = Uri.parse('https://zakup.bar:5000/register_company');
          var body = jsonEncode({
            'userId': user
                .uid, // Предполагается, что у вас есть user.uid с идентификатором пользователя
            'email': email,
            'password': password,
            'company': company,
            'phone': phone,
            'inn': inn,
          });

          try {
            var response = await https.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: body,
            );

            if (response.statusCode == 201) {
              print('User registered successfully.');
            } else {
              print('Failed to register user.');
              print('Status code: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          } catch (e) {
            print('Error: $e');
          }
        } else if (checkBoxValue1) {
          // Регистрация ресторана
          final currentUser = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance
              .collection('restaurant')
              .doc(currentUser?.uid)
              .set({
            'email': email,
            'password': password,
            'restaurant': restaurant,
            'fullName': fullName,
            'position': position,
          });

          // Сохранение данных в PostgreSQL
          var url = Uri.parse('https://zakup.bar:5000/register_restaurant');

          // Параметры, которые вы хотите отправить на сервер
          var body = jsonEncode({
            'userId': currentUser?.uid,
            'email': email,
            'password': password,
            'restaurant': restaurant,
            'fullName': fullName,
            'position': position,
          });

          try {
            var response = await https.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: body,
            );

            if (response.statusCode == 201) {
              print('User registered successfully.');
            } else {
              print('Failed to register user.');
              print('Status code: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          } catch (e) {
            print('Error: $e');
          }
        } else if (checkBoxValue3) {
          // Регистрация пользователя-сотрудника
          final currentUser = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance
              .collection('users_sotrud')
              .doc(currentUser?.uid)
              .set({
            'email': email,
            'password': password,
            'fullName': fullName,
            'position': position,
          });

          // Сохранение данных в PostgreSQL через Node.js API
          var url = Uri.parse('https://zakup.bar:5000/register_user');

          // Параметры, которые вы хотите отправить на сервер
          var body = jsonEncode({
            'userId': currentUser?.uid,
            'email': email,
            'password': password,
            'fullName': fullName,
            'position': position,
          });

          try {
            var response = await https.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: body,
            );

            if (response.statusCode == 201) {
              print('User registered successfully.');
            } else {
              print('Failed to register user.');
              print('Status code: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          } catch (e) {
            print('Error: $e');
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

  bool checkPasswordsMatch() {
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    return password == confirmPassword;
  }

  bool emailExists = false;

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
            errorText: emailExists ? 'Email уже существует' : null,
          ),
          onChanged: (value) async {
            final String email = value.trim();
            emailExists = await checkEmailExists(email);
            setState(() {});
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
              _isButtonActive = isRegistrationButtonActive();
            });
          },
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Подтвердите пароль',
            border: OutlineInputBorder(),
            errorText: !checkPasswordsMatch() ? 'Пароли не совпадают' : null,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _isButtonActive = isRegistrationButtonActive();
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
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: 'ФИО',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: positionController,
            decoration: InputDecoration(
              labelText: 'Должность',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
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
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: positionController,
            decoration: InputDecoration(
              labelText: 'Должность',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
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
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Номер телефона',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: innController,
            decoration: InputDecoration(
              labelText: 'ИНН',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _isButtonActive = isRegistrationButtonActive();
              });
            },
          ),
          SizedBox(height: 16.0),
        ],
        Column(
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
                        checkBoxValue3 = false;
                      }
                    });
                  },
                ),
                Text('Ресторан'),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // Открыть модальное окно с дополнительной информацией
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                              'Дополнительная информация о ресторане'),
                          content: const Text(
                              'Если вы являетесь представителем ресторана, мы приглашаем вас пройти регистрацию. Присоединившись к нашей платформе, вы сможете воспользоваться нашими сервисами и облегчить ведение ресторанного бизнеса.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Закрыть'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: AnimatedQuestionMarkIcon(),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: checkBoxValue2,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        checkBoxValue1 = false;
                        checkBoxValue2 = value;
                        checkBoxValue3 = false;
                      }
                    });
                  },
                ),
                Text('Поставщик'),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // Открыть модальное окно с дополнительной информацией
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                              'Дополнительная информация о поставщике'),
                          content: const Text(
                              'Если вы являетесь поставщиком и собираетесь воспользоваться этим сервисом, продолжайте регистрацию, чтобы присоединиться к нашей платформе и начать успешное сотрудничество'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Закрыть'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: AnimatedQuestionMarkIcon(),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: checkBoxValue3,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        checkBoxValue1 = false;
                        checkBoxValue2 = false;
                        checkBoxValue3 = value;
                      }
                    });
                  },
                ),
                Text('Гость'),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // Открыть модальное окно с дополнительной информацией
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              const Text('Дополнительная информация о госте'),
                          content: const Text(
                              'Если вы гость, мы рады пригласить вас на нашу платформу. Здесь вы сможете общаться, найти работу или присоединяться к ресторанам или поставщикам для дальнейшей работы.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Закрыть'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: AnimatedQuestionMarkIcon(),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: (isRegistrationButtonActive() && !emailExists)
              ? () {
                  _isButtonActive = true;
                  _registerUser(context);
                }
              : null,
          child: Text('Зарегистрироваться'),
        ),
      ],
    );
  }
}
