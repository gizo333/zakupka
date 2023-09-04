import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController emailController =
      TextEditingController(); // Добавляем контроллер для email
  final TextEditingController passwordController =
      TextEditingController(); // Добавляем контроллер для пароля

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  Future<void> deleteUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final navigator = Navigator.of(context);
        final batch = FirebaseFirestore.instance.batch();

        // // Показать диалоговое окно с запросом повторной аутентификации
        // final TextEditingController emailController = TextEditingController();
        // final TextEditingController passwordController =
        //     TextEditingController();
        // final reauthenticateResult = await showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
        //       title: Text('Подтвердите повторно вход'),
        //       content: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: <Widget>[
        //           TextField(
        //             controller: emailController,
        //             decoration: InputDecoration(labelText: 'Email'),
        //           ),
        //           TextField(
        //             controller: passwordController,
        //             decoration: InputDecoration(labelText: 'Password'),
        //             obscureText: true,
        //           ),
        //         ],
        //       ),
        //       actions: <Widget>[
        //         TextButton(
        //           onPressed: () async {
        //             try {
        //               // Попытка повторной аутентификации с введенными данными
        //               final email = emailController.text;
        //               final password = passwordController.text;
        //               await FirebaseAuth.instance.signInWithEmailAndPassword(
        //                 email: email,
        //                 password: password,
        //               );
        //               // Подтвердили повторную аутентификацию, продолжайте удаление аккаунта
        //               Navigator.pop(context, true);
        //             } catch (e) {
        //               // Ошибка при аутентификации
        //               print('Ошибка при повторной аутентификации: $e');
        //               // Вывести сообщение об ошибке пользователю
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 SnackBar(
        //                   content: Text('Ошибка при аутентификации'),
        //                 ),
        //               );
        //             }
        //           },
        //           child: Text('ОК'),
        //         ),
        //         TextButton(
        //           onPressed: () {
        //             Navigator.pop(
        //                 context, false); // Отменить повторную аутентификацию
        //             return;
        //           },
        //           child: Text('Отмена'),
        //         ),
        //       ],
        //     );
        //   },
        // );

        // Удалите пользователя из PostgreSQL
        final response = await https.delete(Uri.parse(
            'https://zakup.bar:8080/api/deleteUserFromCompanies/${user.uid}'));

        if (response.statusCode == 200) {
          print('Удален из PostgreSQL');
        } else {
          print('Ошибка при удалении из PostgreSQL: ${response.statusCode}');
        }

        // Удалите пользователя из коллекции "companies"
        final userRef1 = firestore.collection('companies').doc(user.uid);
        print('Удаляем документ из коллекции "companies": ${userRef1.id}');
        batch.delete(userRef1);

// Удалите пользователя из коллекции "restaurant"
        final userRef2 = firestore.collection('restaurant').doc(user.uid);
        print('Удаляем документ из коллекции "restaurant": ${userRef2.id}');
        batch.delete(userRef2);

        // Удалите пользователя из коллекции "users_sotrud"
        final userRef = firestore.collection('users_sotrud').doc(user.uid);
        print('Удаляем документ из коллекции "users_sotrud": ${userRef.id}');
        batch.delete(userRef);

        // Удалите пользователя из Firebase Authentication
        await user.delete();
        print('Пользователь успешно удален');

        // Выполните транзакцию, чтобы обеспечить атомарность операций
        await batch.commit();

        // После успешного удаления перенаправьте пользователя на экран авторизации или другой экран.
        Navigator.pushReplacementNamed(
            context, '/home'); // Пример перенаправления на экран авторизации
      } else {
        print('Пользователь не найден');
      }
    } catch (e) {
      print('Ошибка при удалении пользователя: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons
                .arrow_back_ios, // добавьте пользовательские значки по вашему желанию
          ),
        ),
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выход',
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ваш ID ${user?.uid}'),
            ElevatedButton(
              onPressed: () async {
                final reauthenticateResult = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Подтвердите повторно вход'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            try {
                              // Попытка повторной аутентификации с введенными данными
                              final email = emailController.text;
                              final password = passwordController.text;
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              // Подтвердили повторную аутентификацию
                              Navigator.pop(context, true);
                            } catch (e) {
                              // Ошибка при аутентификации
                              print('Ошибка при повторной аутентификации: $e');
                              // Вывести сообщение об ошибке пользователю
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка при аутентификации'),
                                ),
                              );
                            }
                          },
                          child: Text('ОК'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context,
                                false); // Отменить повторную аутентификацию
                          },
                          child: Text('Отмена'),
                        ),
                      ],
                    );
                  },
                );

                if (reauthenticateResult == true) {
                  // Выполните удаление пользователя только после успешной повторной аутентификации
                  deleteUser();
                }
              },
              child: const Text('Удалить аккаунт'),
            ),
          ],
        ),
      ),
    );
  }
}
