import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:new_flut_proj/table/tableview.dart';
import '../table/classes.dart';

List<Map<String, dynamic>> jsonData = [];

listToJson(List<PositionClass> list) async {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  for (var position in list) {
    Map<String, dynamic> data = {
      'code': position.codeController.text,
      'name': position.nameController.text,
      'ml': position.mlController.text,
      'itog': position.itogController.text,
    };
    jsonData.add(data);
  }
  String jsonString = json.encode(jsonData);
  print(jsonString);
}

Future<String> convertExcelToJson(String filePath) async {
  var excel = Excel.decodeBytes(File(filePath).readAsBytesSync());
  var jsonData = {};
  for (var table in excel.tables.keys) {
    var tableData = [];
    for (var row in excel.tables[table]!.rows) {
      var rowData = [];
      for (var cell in row) {
        // Если ячейка является объектом SharedString, конвертируем его в строку
        if (cell?.value is SharedString) {
          rowData.add(cell?.value.toString());
        } else {
          rowData.add(cell?.value);
        }
      }

      tableData.add(rowData);
    }
    jsonData[table] = tableData;
  }

  return json.encode(jsonData);
}

Future<String> convertByteToJson(bytes) async {
  print("Bytes length: ${bytes.length}");
  Excel excel = Excel.decodeBytes(bytes!);
  print("Number of tables: ${excel.tables.keys.length}");
  var jsonData = {};
  for (var table in excel.tables.keys) {
    var tableData = [];
    for (var row in excel.tables[table]!.rows) {
      var rowData = [];
      for (var cell in row) {
        // Если ячейка является объектом SharedString, конвертируем его в строку
        if (cell?.value is SharedString) {
          rowData.add(cell?.value.toString());
        } else {
          rowData.add(cell?.value);
        }
      }

      tableData.add(rowData);
    }
    jsonData[table] = tableData;
  }

  return json.encode(jsonData);
}
