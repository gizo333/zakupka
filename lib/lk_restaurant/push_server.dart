// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// Future<void> sendNotification(String title, String body, String token) async {
//   String url = 'https://fcm.googleapis.com/fcm/send';
//   String serverKey = 'AAAAoWo6VDs:APA91bHWlE1hemM1vSK0UVyDg0StNJcnWLnufCA6axc6nouwame-CmTr1SMhEzRJabsG6tdPwkJEE3_eNcgpXaVA6mEO-zPR3Ta87Bni3sxx_21AJKgiPynZ_01I-41KGB5yeDg-A3Vs'; // Замените YOUR_SERVER_KEY на ваш ключ сервера FCM
//
//   Map<String, String> headers = {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $serverKey',
//   };
//
//   Map<String, dynamic> data = {
//     'notification': {
//       'title': title,
//       'body': body,
//     },
//     'to': token,
//   };
//
//   var response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
//   print(response.body);
// }
//
// // Пример вызова функции
// //await sendNotification('Заголовок уведомления', 'Текст уведомления', 'DEVICE_TOKEN');
