// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../services/firebase_messaging.dart';
//
// class PushPage extends StatefulWidget {
//   final MyFirebaseMessaging firebaseMessaging;
//   final MyFirebaseInstanceId firebaseInstanceId;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//   PushPage({
//     required this.firebaseMessaging,
//     required this.firebaseInstanceId,
//     required this.flutterLocalNotificationsPlugin,
//   });
//
//   @override
//   _PushPageState createState() => _PushPageState();
// }
//
// class _PushPageState extends State<PushPage> {
//   bool? _isNotificationEnabled;
//
//   @override
//   void initState() {
//     super.initState();
//     checkNotificationPermission();
//   }
//
//   Future<void> checkNotificationPermission() async {
//     bool? isNotificationEnabled = await widget.flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.areNotificationsEnabled();
//     print('Уведомления ${isNotificationEnabled == true ? 'включены' : 'выключены'}');
//     setState(() {
//       _isNotificationEnabled = isNotificationEnabled;
//     });
//   }
//
//   void sendNotification() async {
//     if (_isNotificationEnabled == true) {
//       bool hasNotificationPermissions = await widget.firebaseMessaging.checkNotificationPermissions();
//       if (hasNotificationPermissions) {
//         widget.firebaseMessaging.sendTestNotification();
//       } else {
//         print('Не удалось отправить уведомление. Разрешения на уведомления отклонены.');
//       }
//     } else {
//       print('Не удалось отправить уведомление. Уведомления выключены.');
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PushPage'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _isNotificationEnabled == true
//                   ? 'Уведомления включены'
//                   : 'Уведомления выключены',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               child: Text('Отправить уведомление'),
//               onPressed: sendNotification,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               child: Text('Получить токен FCM'),
//               onPressed: () {
//                 widget.firebaseInstanceId.getToken();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
