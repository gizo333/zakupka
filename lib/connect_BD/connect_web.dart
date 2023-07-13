import 'dart:convert';
import 'package:http/http.dart' as http;



Future<Map<String, dynamic>> getUserData(String tableName, String userId) async {
  final url = Uri.parse('http://37.140.241.144:8080/api/$tableName/user_id/$userId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data.first.cast<String, dynamic>();
      } else if (data is Map) {
        return data.cast<String, dynamic>();
      } else {
        return {};  // Возвращаем пустую карту, если данные отсутствуют или не в ожидаемом формате
      }
    } else if (response.statusCode == 404) {
      print('Пользователь не найден');
      return {}; // Возвращаем пустую карту вместо null
    } else {
      throw Exception('Ошибка при получении данных: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Ошибка при выполнении запроса: $e');
  }
}






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
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found: $tableName/$fieldName');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Ошибка при выполнении запроса: $e');
  }
}