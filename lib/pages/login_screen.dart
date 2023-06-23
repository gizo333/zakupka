import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import '/services/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHiddenPassword = true;
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

      // Получение текущего пользователя
      final User? user = FirebaseAuth.instance.currentUser;

      // Проверка таблицы, из которой произошел вход
      if (user != null) {
        final connection = PostgreSQLConnection(
          '37.140.241.144',
          5432,
          'postgres',
          username: 'postgres',
          password: '1',
        );

        try {
          await connection.open();

          final query = 'SELECT * FROM users_sotrud WHERE user_id = @userId';
          final results = await connection.query(query, substitutionValues: {
            'userId': user.uid,
          });

          if (results.isNotEmpty) {
            final nameRest = results.first[6] as String?;

            if (nameRest != null && nameRest.isNotEmpty && nameRest != 'null') {
              // Поле name_rest имеет значение, отличное от пустой строки и 'null'
              navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
              return;
            } else {
              // Поле name_rest пустое, равно 'null' или равно null
              navigator.pushNamedAndRemoveUntil('/lk-user', (Route<dynamic> route) => false);
              return;
            }
          }

          final query2 = 'SELECT * FROM restaurant WHERE user_id = @userId';
          final results2 = await connection.query(query2, substitutionValues: {
            'userId': user.uid,
          });

          if (results2.isNotEmpty) {
            navigator.pushNamedAndRemoveUntil('/table', (Route<dynamic> route) => false);
            return;
          }

          final query3 = 'SELECT * FROM companies WHERE user_id = @userId';
          final results3 = await connection.query(query3, substitutionValues: {
            'userId': user.uid,
          });

          if (results3.isNotEmpty) {
            navigator.pushNamedAndRemoveUntil('/kabinet', (Route<dynamic> route) => false);
            return;
          }
        } catch (e) {
          print(e);
        } finally {
          await connection.close();
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e);

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
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
                validator: (value) => value != null && value.length < 6
                    ? 'Минимум 6 символов'
                    : null,
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
