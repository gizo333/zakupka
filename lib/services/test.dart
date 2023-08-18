// import 'dart:typed_data';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:encrypt/encrypt.dart';

// Future<void> visionRest() async {
//   final user = FirebaseAuth.instance.currentUser;

//   final url =
//       Uri.parse('http://37.140.241.144:8085/api/tables/encrypted-alltables');

//   try {
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final encryptedTables =
//           json.decode(response.body)['encryptedTables'] as String;

//       // Расшифровываем данные на клиенте
//       Uint8List secretKey;
//       final decipher = AES(Key(secretKey), mode: AESMode.cbc);
//       final decryptedTables =
//           decipher.decrypt(Encrypted.fromBase16(encryptedTables));

//       final tables = json.decode(utf8.decode(decryptedTables)) as List<dynamic>;

//       final filteredTables = tables
//           .cast<String>()
//           .where((tableName) =>
//               tableName.startsWith('r_${user?.uid?.toLowerCase()}_'))
//           .toList();

//       setState(() {
//         _tableList = filteredTables;
//       });
//     } else {
//       print(
//           'Error fetching encrypted table list from API: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error fetching encrypted table list from API: $e');
//   }
// }
