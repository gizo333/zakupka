// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lk_restaurant/lk_rest.dart';
import '../pages/account_screen.dart';
import '../services/check_sotrud_in_rest.dart';
import '../services/who.dart';

class LkUser extends StatefulWidget {
  const LkUser({Key? key}) : super(key: key);

  @override
  _LkUserState createState() => _LkUserState();
}

class _LkUserState extends State<LkUser> {
  final user = FirebaseAuth.instance.currentUser;
  bool isBound =
      false; // Добавляем состояние для хранения информации о привязке

  @override
  void initState() {
    super.initState();
    Who().WhoYou();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkBinding(); // Выполняем проверку при обновлении виджета
  }

// проверяет привзян ли к ресторану если да то переходит на страницу
  Future<void> checkBinding() async {
    // try {
    if (user != null) {
      final userUid = user!.uid;
      final result = await checkRestaurantBinding(userUid);
      final isBound = result['isBound'] as bool;

      if (isBound) {
        Navigator.pushAndRemoveUntil<void>(
          context,
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => Kabinet(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
            transitionDuration: Duration(
                milliseconds:
                    0), // Устанавливаем нулевую продолжительность анимации
          ),
          (route) => false, // Удаляем все предыдущие маршруты
        );
      }
    }
    // } catch (error) {
    //   print('Error: $error');
    // }
  }

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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Вакансии"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (mounted && isBound) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Kabinet()));
                    } else {
                      print('User is not bound to any restaurant.');
                    }
                  },
                  child: const Text("Check Restaurant Binding"),
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
