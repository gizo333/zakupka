// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:postgres/postgres.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
//
// import '../connect_BD/connect.dart';
//
// class ExcelTable extends StatefulWidget {
//   @override
//   _ExcelTableState createState() => _ExcelTableState();
// }
//
// class _ExcelTableState extends State<ExcelTable> {
//   final postgresConnection = createDatabaseConnection();
//
//   Future<String> _getFilePath() async {
//     Directory? directory;
//     if (Platform.isAndroid) {
//       directory = await getExternalStorageDirectory();
//     } else if (Platform.isIOS) {
//       directory = await getApplicationDocumentsDirectory();
//     }
//
//     if (directory != null) {
//       return '${directory.path}/excel_table.xlsx';
//     } else {
//       throw Exception('Не удалось получить путь к директории приложения.');
//     }
//   }
//
//   Future<void> _generateExcelFile() async {
//     final postgresConnection = createDatabaseConnection();
//
//     await postgresConnection.open();
//
//     final results = await postgresConnection.query('SELECT * FROM position');
//
//     final excel = Excel.createExcel();
//     final sheet = excel['Sheet1'];
//
//     // Запись заголовков столбцов
//     for (var columnIndex = 0; columnIndex < results.length; columnIndex++) {
//       final row = results[columnIndex].asMap();
//       final columnName = row.keys.toList()[0];
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0)).value = columnName;
//     }
//
//     // Запись данных
//     for (var rowIndex = 0; rowIndex < results.length; rowIndex++) {
//       final row = results[rowIndex].asMap();
//       for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
//         final columnName = row.keys.toList()[columnIndex];
//         sheet.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: rowIndex + 1)).value = row[columnName].toString();
//       }
//     }
//
//     // Получение пути к файлу
//     final filePath = await _getFilePath();
//     final file = File(filePath);
//
//     // Сохранение файла Excel
//     final fileBytes = excel.save();
//     await file.writeAsBytes(fileBytes!);
//
//     await postgresConnection.close();
//
//     // Проверка успешного сохранения файла
//     if (await file.exists()) {
//       print('Файл Excel успешно сохранен: $filePath');
//       // Открытие файла
//       OpenFile.open(filePath);
//     } else {
//       print('Не удалось сохранить файл Excel.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Excel Table'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _generateExcelFile();
//           },
//           child: Text('Сгенерировать Excel'),
//         ),
//       ),
//     );
//   }
// }
