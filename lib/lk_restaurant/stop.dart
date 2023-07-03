// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';
// import 'package:flutter/services.dart' show ByteData, rootBundle;
// import 'package:path/path.dart' as path;
//
// class StopPage extends StatefulWidget {
//   @override
//   _StopPageState createState() => _StopPageState();
// }
//
// class _StopPageState extends State<StopPage> {
//   List<List<dynamic>>? excelData = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('StopPage'),
//       ),
//       body: SingleChildScrollView(
//         child: excelData != null && excelData!.isNotEmpty
//             ? DataTable(
//           columns: List<DataColumn>.generate(
//             excelData![0].length,
//                 (columnIndex) => DataColumn(
//               label: Text('Column $columnIndex'),
//             ),
//           ),
//           rows: List<DataRow>.generate(
//             excelData!.length,
//                 (rowIndex) {
//               List<dynamic> rowData = excelData![rowIndex];
//               return DataRow(
//                 cells: List<DataCell>.generate(
//                   rowData.length,
//                       (columnIndex) => DataCell(
//                     Text('${rowData[columnIndex]} ($columnIndex)'),
//                   ),
//                 ),
//               );
//             },
//           ),
//         )
//             : Center(
//           child: Text('No data available'),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           pickExcelFile().then((filePath) {
//             if (filePath != null) {
//               readExcelData(filePath).then((data) {
//                 setState(() {
//                   excelData = data;
//                 });
//               });
//             }
//           });
//         },
//         child: Icon(Icons.file_upload),
//       ),
//     );
//   }
//
//   Future<String?> pickExcelFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx'],
//     );
//
//     if (result != null) {
//       return result.files.single.path;
//     } else {
//       return null;
//     }
//   }
//
//   Future<List<List<dynamic>>?> readExcelData(String filePath) async {
//     ByteData data = await rootBundle.load(filePath);
//     var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//     var excel = Excel.decodeBytes(bytes);
//     var sheet = excel.tables[excel.tables.keys.first];
//     return sheet?.rows as List<List<dynamic>>?;
//   }
// }
