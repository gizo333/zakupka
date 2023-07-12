import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getDataFromServer(String tableName, String fieldName) async {
  final url = Uri.parse('http://37.140.241.144:8080/api/$tableName/$fieldName');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Ошибка при получении данных: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Ошибка при выполнении запроса: $e');
  }
}


Future<dynamic> executeServerRequest(String tableName, String fieldName, {dynamic body}) async {
  final url = Uri.parse('http://37.140.241.144:8080/api/$tableName/$fieldName');
  final headers = {"Content-Type": "application/json"};

  try {
    final response = await http.post(url, body: jsonEncode(body), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Ошибка при получении данных: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Ошибка при выполнении запроса: $e');
  }
}