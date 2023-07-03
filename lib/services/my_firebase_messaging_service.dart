// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class MyFirebaseMessaging {
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   void initializeFirebaseMessaging() {
//     _firebaseMessaging.requestPermission(
//       sound: true,
//       badge: true,
//       alert: true,
//       provisional: false,
//     );
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Получено уведомление: ${message.notification?.body}');
//       // Обработка полученного уведомления
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Уведомление открыто: ${message.notification?.body}');
//       // Обработка открытия уведомления приложением в фоновом режиме
//     });
//
//     FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
//
//     _firebaseMessaging.getToken().then((String? token) {
//       print('Получен новый токен устройства: $token');
//       // Обработка получения нового токена устройства
//     });
//   }
//
//   Future<void> _backgroundMessageHandler(RemoteMessage message) async {
//     print('Получено уведомление в фоне: ${message.notification?.body}');
//     // Обработка полученного уведомления в фоне
//   }
// }
