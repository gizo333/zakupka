// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class MyFirebaseMessagingService {
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> setupFirebaseMessaging() async {
//     // Запрос разрешения на получение уведомлений
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('Разрешение получено');
//     } else {
//       print('Разрешение отклонено');
//     }
//
//     // Получение исходного токена (если доступен)
//     String? initialToken = await _firebaseMessaging.getToken();
//     if (initialToken != null) {
//       print('Исходный токен устройства: $initialToken');
//     }
//
//     // Подписка на тему(ы), если необходимо
//     // _firebaseMessaging.subscribeToTopic('название_темы');
//     // _firebaseMessaging.subscribeToTopic('другое_название_темы');
//
//     // Настройка обратного вызова обновления токена
//     _firebaseMessaging.onTokenRefresh.listen((newToken) {
//       print('Получен новый токен устройства: $newToken');
//       // Обработка нового токена здесь
//     });
//
//     // Настройка обратных вызовов обработки сообщений
//     FirebaseMessaging.onMessage.listen((message) {
//       print('Получено новое сообщение');
//       // Обработка входящего сообщения здесь
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print('Пользователь нажал на уведомление');
//       // Обработка нажатия на уведомление здесь
//     });
//   }
// }
