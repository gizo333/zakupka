import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_flut_proj/LK_Postavki/lk_post.dart';
import '../lk_restaurant/lk_rest.dart';
import '../lk_user/lk_user_sotrud.dart';
import '../services/check_sotrud_in_rest.dart';
import '../services/test.dart';
import '../services/who.dart';
import '/services/snack_bar.dart';
import 'package:http/http.dart' as https;

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

  void initState() {
    super.initState();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> login() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final requestHeaders = {"Content-Type": "application/json"};
        final requestBody = jsonEncode({"userId": user.uid});

        final response = await https.post(
            Uri.parse("https://zakup.bar:8080/api/login"),
            headers: requestHeaders,
            body: requestBody);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final token = jsonData['token'] as String;

          setState(() {
            GlobalData.jwtToken = token;
          });

          // ignore: use_build_context_synchronously
          SnackBarService.showSnackBar(
            context,
            'Вход успешно выполнен!',
            false,
          );

          Who whoInstance = Who();
          await whoInstance.WhoYou();
          if (whoInstance.rest) {
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Kabinet()),
            );
          } else if (whoInstance.sotrud) {
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LkUser()),
            );
          } else if (whoInstance.comp) {
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LkPostavPage()),
            );
          }
        } else {
          // ignore: use_build_context_synchronously
          SnackBarService.showSnackBar(
            context,
            'Не удалось создать токен. Код ошибки: ${response.statusCode}',
            true,
          );
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
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12), // Закругление углов
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6), // Цвет тени
                        spreadRadius: 3, // Распределение тени
                        blurRadius: 1, // Размытие тени
                        offset: const Offset(0, 3), // Смещение тени
                      ),
                    ],
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    controller: emailTextInputController,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Введите правильный Email'
                            : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // Убираем внешние границы
                      ),
                      filled: true,
                      fillColor: Colors.white, // Цвет фона
                      hintText: 'Введите Email',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      // Остальные параметры стиля
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 400,
                  child: TextFormField(
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
                ),
                const SizedBox(height: 30),
                Container(
                  width: 200, // Установите желаемую ширину для контейнера
                  child: ElevatedButton(
                    onPressed: () {
                      login().then((_) async {
                        // Получаем текущего пользователя
                        var currentUser = FirebaseAuth.instance.currentUser;
                      });
                    },
                    child: const Center(child: Text('Войти')),
                  ),
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
      ),
    );
  }
}
