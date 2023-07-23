import 'dart:convert';
import 'package:http/http.dart' as http;

bool? sotrud;
bool? restaurant;
bool? companies;

Future<String> findFirebaseUser(String firebaseUid) async {
  final response = await http.get(
    Uri.parse('http://37.140.241.144:5000/find-user/$firebaseUid'),
  );

  if (response.statusCode == 200) {
    String message = jsonDecode(response.body)['message'];
    String result = "";
    if (message.contains("users_sotrud")) {
      sotrud = true;
      result += "User is in users_sotrud. ";
    } else {
      sotrud = false;
    }
    if (message.contains("restaurant")) {
      restaurant = true;
      result += "User is in restaurant. ";
    } else {
      restaurant = false;
    }
    if (message.contains("companies")) {
      companies = true;
      result += "User is in companies. ";
    } else {
      companies = false;
    }
    return result.isEmpty ? "User is not found in any table." : result;
  } else {
    throw Exception('Failed to load user data');
  }
}
