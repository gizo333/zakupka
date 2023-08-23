import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/account_screen.dart';

class LkPostavPage extends StatefulWidget {
  @override
  _LkPostavPageState createState() => _LkPostavPageState();
}

class _LkPostavPageState extends State<LkPostavPage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LkPostav'),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.account_circle,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Добро пожаловать на страницу LkPostav!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Дополнительные виджеты и функциональность можно добавить здесь
          ],
        ),
      ),
    );
  }
}
