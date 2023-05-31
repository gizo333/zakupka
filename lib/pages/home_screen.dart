import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/account_screen.dart';
import '/pages/login_screen.dart';
import '/pages/invent.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),

      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: const Text('Личный кабинет'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color.fromRGBO(0, 11, 13, 1), Color.fromRGBO(0, 11, 13, 0.9)]),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
             icon: Icon(
              Icons.logout,
               color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),

        ],


      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20.5),
          child: (user == null)
              ? const Text("Контент для НЕ зарегистрированных в системе")
              : TextButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Invent()),
            );
          },
              child: const Text('Инвентаризация')),
        ),
      ),
    );
  }
}