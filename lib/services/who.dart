import 'dart:convert';
import 'package:http/http.dart' as http;
/// данная функция определяет к какой группе пользователей относиться авторизованный пользователь
/// вызов функции await whoami(user!.uid); или UserState result = await whoami(user!.uid);
///                     print(result.message);
///                     print(result.count);
class UserState {
  final bool sotrud;
  final bool restaurant;
  final bool companies;
  final String message;
  final int count;

  UserState({
    required this.sotrud,
    required this.restaurant,
    required this.companies,
    required this.message,
    required this.count,
  });
}

/// данная функция определяет к какой группе пользователей относиться авторизованный пользователь
/// вызов функции await whoami(user!.uid); или UserState result = await whoami(user!.uid);
///                     print(result.message);
///                     print(result.count);
Future<UserState> findFirebaseUser(String firebaseUid) async {
  final response = await http.get(
    Uri.parse('http://37.140.241.144:5000/find-user/$firebaseUid'),
  );

  if (response.statusCode == 200) {
    String message = jsonDecode(response.body)['message'];
    String result = "";
    int count = 0;
    bool sotrud = false;
    bool restaurant = false;
    bool companies = false;

    if (message.contains("users_sotrud")) {
      sotrud = true;
      result += "User is in sotrud. ";
      count = 2;
    }
    if (message.contains("restaurant")) {
      restaurant = true;
      result += "User is in restaurant. ";
      count = 1;
    }
    if (message.contains("companies")) {
      companies = true;
      result += "User is in companies. ";
      count = 3;
    }

    return UserState(
      sotrud: sotrud,
      restaurant: restaurant,
      companies: companies,
      message: result.isEmpty ? "User is not found in any table." : result,
      count: count,
    );
  } else {
    throw Exception('Failed to load user data');
  }
}


/// данная функция определяет к какой группе пользователей относиться авторизованный пользователь
/// вызов функции await whoami(user!.uid); или UserState result = await whoami(user!.uid);
///                     print(result.message);
///                     print(result.count);
Future<UserState> Function(String) whoami = findFirebaseUser;
