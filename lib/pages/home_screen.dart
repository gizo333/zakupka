import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    void login() {
      if (user == null) {
        Navigator.pushNamed(context, '/login');
      }
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Zакупка'),
      ),

      body: SafeArea(
        child: Row(children: [
          OutlinedButton(
            onPressed: login,
            child: Text("Регистрация"),
          ),
          //OutlinedButton(onPressed: nu, child: Text(""))
        ]),
      ),
    );
  }
}
