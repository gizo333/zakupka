import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/account_screen.dart';
import '../services/who.dart';

class LkUser extends StatefulWidget {
  const LkUser({Key? key}) : super(key: key);

  @override
  _LkUserState createState() => _LkUserState();
}

class _LkUserState extends State<LkUser> {
  final user = FirebaseAuth.instance.currentUser;


  void goList() {
    if (user != null) {
      Navigator.pushNamed(context, '/restaurantList');
    }
  }

//------------
  // проверяет принадлежит ли сотрудник к какому либо ресторану, чекает поле rest_name если не null то принадлежит
  Future<bool> checkUser() async {
    if (user?.uid == null) return false;
    try {
      var response = await http.get(Uri.parse('http://37.140.241.144:5000/checkUser/${user?.uid}'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Server error: ${response.body}');
        return false;
      }
    } catch(e) {
      print('Error occurred: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkUser(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, '/kabinet');
              });
            }
          }
          // найти способ проще, написать одну функцию которая будет определять?
//------------


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
                        child: const Text("Вакансии"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (user != null) {
                            final message = await findFirebaseUser(user!.uid);
                            //print(message);
                          } else {
                            print("User is not logged in.");
                          }
                        },
                        child: const Text("Кнопка"),
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
    );
  }
}
