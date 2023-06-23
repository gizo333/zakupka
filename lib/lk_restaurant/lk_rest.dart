import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgres/postgres.dart';
import '../pages/account_screen.dart';

class Kabinet extends StatefulWidget {
  const Kabinet({Key? key}) : super(key: key);

  @override
  _KabinetState createState() => _KabinetState();
}

class _KabinetState extends State<Kabinet> {
  final user = FirebaseAuth.instance.currentUser;
  String restaurantName = '';
  List<List<dynamic>> restaurantResults = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurantName();
    fetchRestaurantData();
  }

  void fetchRestaurantData() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    await connection.open();

    restaurantResults = await connection.query(
      'SELECT restaurant FROM restaurant WHERE user_id = @userId;',
      substitutionValues: {'userId': user?.uid},
    );

    await connection.close();
  } // проверка что из бд restaurant

  void fetchRestaurantName() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    await connection.open();

    final userSotrudResults = await connection.query(
      'SELECT name_rest FROM users_sotrud WHERE user_id = @userId;',
      substitutionValues: {'userId': user?.uid},
    );

    if (userSotrudResults.isNotEmpty) {
      setState(() {
        restaurantName = userSotrudResults[0][0].toString();
      });
    } else if (restaurantResults.isNotEmpty) {
      setState(() {
        restaurantName = restaurantResults[0][0].toString();
      });
    }

    await connection.close();
  } // в зависимости из какой бд, и что указано в поле название ресторана, выводим имя ресторана


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(restaurantName),
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
                  onPressed: goInvent,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Инвентаризация"),
                ),
                ElevatedButton(
                  onPressed: goStop,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white70,
                    shadowColor: Colors.blueGrey,
                  ),
                  child: const Text("Стоп-Минимум"),
                ),
              ],
            ),
            if (restaurantResults.isNotEmpty)
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
                    child: const Text("Запросы"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
