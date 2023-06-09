import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel to JSON',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExcelToJsonPage(),
    );
  }
}

class ExcelToJsonPage extends StatefulWidget {
  @override
  _ExcelToJsonPageState createState() => _ExcelToJsonPageState();
}

class _ExcelToJsonPageState extends State<ExcelToJsonPage> {
  late String _filePath;
  bool _conversionSuccessful = false;

  Future<void> _uploadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });

      String excelData = await convertExcelToJson(_filePath);

      if (excelData.isNotEmpty) {
        await saveJsonToFirestore(excelData);
        setState(() {
          _conversionSuccessful = true;
        });
      }
    }
  }

  Future<String> convertExcelToJson(String filePath) async {
    var excel = Excel.decodeBytes(File(filePath).readAsBytesSync());

    var tableNames = excel.tables.keys.toList();
    var jsonData = {};

    for (var tableName in tableNames) {
      var table = excel.tables[tableName]!;
      var rows = table.rows.map((row) {
        return row.map((cell) => cell.toString()).toList();
      }).toList();
      jsonData[tableName] = rows;
    }

    return json.encode(jsonData);
  }

  Future<void> saveJsonToFirestore(String jsonData) async {
    CollectionReference collection =
    FirebaseFirestore.instance.collection('data');
    var data = json.decode(jsonData);

    // Convert nested arrays to JSON strings
    var flattenedData = flattenData(data);

    await collection.add(flattenedData);
  }

  dynamic flattenData(dynamic data) {
    if (data is List) {
      return data.map((item) => flattenData(item)).toList();
    } else if (data is Map) {
      Map<String, dynamic> flattenedMap = {};
      data.forEach((key, value) {
        if (value is List) {
          flattenedMap[key] = json.encode(value);
        } else {
          flattenedMap[key] = flattenData(value);
        }
      });
      return flattenedMap;
    } else {
      return data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel to JSON'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploadExcelFile,
              child: Text('Upload Excel File'),
            ),
            SizedBox(height: 20.0),
            if (_conversionSuccessful)
              Text(
                'Conversion and saving to Firestore successful!',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
