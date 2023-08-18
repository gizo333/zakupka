import 'package:http/http.dart' as https;
import 'dart:convert';

Future<Map<String, dynamic>> checkRestaurantBinding(String uid) async {
  final response = await https
      .get(Uri.parse('https://zakup.bar:8080/checkRestaurantBinding/$uid'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  } else {
    throw Exception('Failed to load data');
  }
}
