// import 'package:flutter/material.dart';
// import 'package:postgres/postgres.dart';
//
// class RestaurantListPage extends StatefulWidget {
//   @override
//   _RestaurantListPageState createState() => _RestaurantListPageState();
// }
//
// class _RestaurantListPageState extends State<RestaurantListPage> {
//   Future<List<String>> fetchRestaurants() async {
//     final postgresConnection = PostgreSQLConnection(
//       '37.140.241.144',
//       5432,
//       'postgres',
//       username: 'postgres',
//       password: '1',
//     );
//
//     try {
//       await postgresConnection.open();
//       final results = await postgresConnection.query('SELECT restaurant FROM restaurant');
//       postgresConnection.close();
//
//       final list = results
//           .map((row) => row[0] as String)
//           .toList();
//       return list;
//     } catch (e) {
//       print('Error fetching restaurants: $e');
//       throw e;
//     } finally {
//       await postgresConnection.close();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Restaurant List',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Restaurant List'),
//         ),
//         body: FutureBuilder<List<String>>(
//           future: fetchRestaurants(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasData) {
//               final restaurants = snapshot.data!;
//               return ListView.builder(
//                 itemCount: restaurants.length,
//                 itemBuilder: (context, index) {
//                   final name = restaurants[index];
//
//                   return ListTile(
//                     title: Text(name),
//                   );
//                 },
//               );
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             }
//
//             return Center(
//               child: Text('No data available'),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
