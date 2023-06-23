import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/account_screen.dart';

class LkUser extends StatefulWidget {
  const LkUser({Key? key}) : super(key: key);

  @override
  _LkUserState createState() => _LkUserState();
}

class _LkUserState extends State<LkUser> {
  final user = FirebaseAuth.instance.currentUser;

  // void goInvent() {
  //   if (user != null) {
  //     Navigator.pushNamed(context, '/table');
  //   }
  // }

  void goList() {
    if (user != null) {
      Navigator.pushNamed(context, '/restaurantList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Инвентаризация"),
                ),
                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Стоп-Минимум"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: goList,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Список ресторанов"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
