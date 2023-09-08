import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:new_flut_proj/LK_Postavki/bottom_bar.dart';

import 'package:provider/provider.dart';
import '../pages/account_screen.dart';

class LkPostavPage extends StatefulWidget {
  const LkPostavPage({Key? key}) : super(key: key);

  @override
  _LkPostavPageState createState() => _LkPostavPageState();
}

class _LkPostavPageState extends State<LkPostavPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final bottomState = Provider.of<BottomNavState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LkPostav'),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
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
      bottomNavigationBar: buildMyBottomNavigationBar(
          context, bottomState.currentIndex, (index) {
        bottomState.setCurrentIndex(index);
      }),
    );
  }
}
