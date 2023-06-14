import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account_screen.dart';

class kabinet extends StatelessWidget {
  const kabinet({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    void goInvent() {
      if (user != null) {
        Navigator.pushNamed(context, '/table');
      }
    }

    void goStop() {
      if (user != null) {
        Navigator.pushNamed(context, '/stop');
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Кабинет'),
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
      body: SafeArea(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: goInvent,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey),
                child: const Text("Инвентаризация"),
              ),
              ElevatedButton(
                onPressed: goStop,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey),
                child: const Text("Стоп-Минимум"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey),
                child: const Text("Заказ"),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
