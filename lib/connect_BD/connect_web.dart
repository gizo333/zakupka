// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// Future<List<dynamic>> getDataFromServer(String tableName, String fieldName) async {
//   final url = Uri.parse('http://37.140.241.144:8080/api/$tableName/$fieldName');
//
//   try {
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data as List<dynamic>;
//     } else {
//       throw Exception('Ошибка при получении данных: ${response.statusCode}');
//     }
//   } catch (e) {
//     throw Exception('Ошибка при выполнении запроса: $e');
//   }
// }
