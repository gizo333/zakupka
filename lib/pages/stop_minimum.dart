import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  List<Map<String, dynamic>> restaurantList = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      final query = 'SELECT * FROM restaurant';
      final results = await connection.query(query);

      setState(() {
        restaurantList = results.map((row) => row.toColumnMap()).toList();
      });
    } catch (e) {
      print(e);
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список ресторанов'),
      ),
      body: ListView.builder(
        itemCount: restaurantList.length,
        itemBuilder: (context, index) {
          final restaurant = restaurantList[index];
          return ListTile(
            title: Text(restaurant['name']),
            subtitle: Text(restaurant['address']),
          );
        },
      ),
    );
  }
}
