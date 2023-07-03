// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:vibration/vibration.dart';
//
//
// class MyFirebaseMessaging {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> initialize() async {
//     // Инициализация Firebase Messaging
//     FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
//     FirebaseMessaging.onMessage.listen(_handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
//
//     // Получение и сохранение токена FCM
//     String? token = await _firebaseMessaging.getToken();
//     print('FCM Token: $token');
//   }
//
//   Future<bool> checkNotificationPermissions() async {
//     final settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     return settings.authorizationStatus == AuthorizationStatus.authorized;
//   }
//   Future<void> _handleMessage(RemoteMessage message) async {
//     bool? hasVibrator = await Vibration.hasVibrator();
//     if (hasVibrator == true) {
//       Vibration.vibrate();
//     }
//   }
//
//   Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
//     bool? hasVibrator = await Vibration.hasVibrator();
//     if (hasVibrator == true) {
//       Vibration.vibrate();
//     }
//   }
//
//   Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//     bool? hasVibrator = await Vibration.hasVibrator();
//     if (hasVibrator == true) {
//       Vibration.vibrate();
//     }
//   }
//
//   void sendTestNotification() {
//     // Отправка тестового уведомления
//     RemoteNotification notification = RemoteNotification(
//       title: 'Тестовое уведомление',
//       body: 'Привет! Это тестовое уведомление.',
//     );
//     RemoteMessage message = RemoteMessage(
//       notification: notification,
//     );
//     _handleMessage(message);
//   }
// }
//
// Future<bool> checkNotificationPermissions() async {
//   final settings = await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   return settings.authorizationStatus == AuthorizationStatus.authorized;
// }
//
// class MyFirebaseInstanceId {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> getToken() async {
//     // Получение и сохранение токена FCM
//     String? token = await _firebaseMessaging.getToken();
//     print('FCM Token: $token');
//   }
// }