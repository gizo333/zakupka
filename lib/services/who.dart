import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';



/// данная функция определяет к какой группе пользователей относиться авторизованный пользователь
/// вызов функции await whoami(user!.uid); или UserState result = await whoami(user!.uid);
///                     print(result.message);
///                     print(result.count);
///
/// restaurant = 1; sotrud = 2; companies = 3;
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
final user = FirebaseAuth.instance.currentUser;
/// данная функция определяет к какой группе пользователей относиться авторизованный пользователь
/// вызов функции await whoami(user!.uid); или UserState result = await whoami(user!.uid);
///                     print(result.message);
///                     print(result.count);
///
/// restaurant = 1; sotrud = 2; companies = 3;
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
///
/// restaurant = 1; sotrud = 2; companies = 3;
Future<UserState> Function(String) whoami = findFirebaseUser;


class Who {
  static final Who _singleton = Who._internal();

  bool _rest = false;
  bool _sotrud = false;
  bool _comp = false;

  bool get rest => _rest;
  bool get sotrud => _sotrud;
  bool get comp => _comp;
  /// Определяет из какой группы пользоаетель!
  ///
  /// обращаться if (Who().rest) = ресторан
  ///
  /// if (Who().comp) = поставщик
  ///
  /// if (Who().sotrud) = обычный пользователь
  ///
  /// На каждой старнице где хотим использовать нужно добавить в @override
  ///   void initState() {
  ///   Who().WhoYou();
  ///   }
  factory Who() {
    return _singleton;
  }

  Who._internal();

  void reset() {
    _rest = false;
    _sotrud = false;
    _comp = false;
  }
  /// Определяет из какой группы пользоаетель!
  ///
  /// обращаться if (Who().rest) = ресторан
  ///
  /// if (Who().comp) = поставщик
  ///
  /// if (Who().sotrud) = обычный пользователь
  ///
  /// На каждой старнице где хотим использовать нужно добавить в @override
  ///   void initState() {
  ///   Who().WhoYou();
  ///   }
  Future<void> WhoYou() async {
    // Сброс текущего состояния
    reset();

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserState result = await whoami(currentUser.uid);
      if (result.count == 1) {
        _rest = true;
      } else if (result.count == 2) {
        _sotrud = true;
      } else if (result.count == 3) {
        _comp = true;
      }
    }
  }
}

