import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_flut_proj/pages/kabinet.dart';
import '../register/verify_email_screen.dart';
import 'package:new_flut_proj/register/verify_email_screen.dart';
import '/pages/home_screen.dart';

//Общий смысл этого кода заключается в том, что FirebaseStream - это виджет, который отслеживает изменения состояния аутентификации
// в Firebase и в зависимости от этого строит соответствующий виджет пользовательского интерфейса.

class FirebaseStream extends StatelessWidget {
  const FirebaseStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Что-то пошло не так!')));
        } else if (snapshot.hasData) {
          if (!snapshot.data!.emailVerified) {
            return const VerifyEmailScreen();
          }
          return const Kabinet(); //если пользователь авторизован переходим на эту страницу
        } else {
          return const HomeScreen(); //если не авторизован
        }
      },
    );
  }
}