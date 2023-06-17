import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'classes.dart';
import './sort_help.dart';
import './json_help.dart';
import 'package:postgres/postgres.dart';

class TableView extends StatefulWidget {
  const TableView({Key? key}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  late String userId; // Идентификатор пользователя

  Future<void> initializeFirebase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = currentUser!.uid; // Идентификатор пользователя
    });
  }


  List<PositionClass> _lists = [];
  bool _sortAsc = true;
  // ignore: unused_field
  int? _sortColumnIndex;
  Color? errorColor;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    _lists = [];
  }

  @override
  void dispose() {
    for (var position in _lists) {
      position.nameController.dispose();
      position.codeController.dispose();
      position.mlController.dispose();
      position.itogController.dispose();
    }
    super.dispose();
  }

  final defaultState = PositionClass(null, '', null, null);
  @override
  Widget build(BuildContext context) {
    final columns = ['Код', 'Наим.', 'Ед. Изм.', 'Итог'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewField();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text(
          'Table',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(186, 0, 0, 0),
      ),
      body: Container(
        color: const Color.fromARGB(255, 246, 246, 246),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                for (int columnIndex = 0;
                columnIndex < columns.length;
                columnIndex++)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        onSort(columnIndex, !_sortAsc);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.grey[200],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              columns[columnIndex],
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  final position = _lists[index];
                  return Dismissible(
                    // key: UniqueKey(),
                    key: Key(position.hashCode.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('Item dismissed: ${_lists[index].name}'),
                        ),
                      );
                      setState(() {
                        _lists.removeAt(index);
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Container(
                        color: const Color.fromARGB(255, 133, 133, 133),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  maxLines: null,
                                  controller: position.codeController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val.isEmpty) {
                                        position.code = null; // Сброс значения
                                        errorColor = null; // Сброс цвета ошибки
                                      } else {
                                        // Проверка и конвертация введенного значения
                                        final parsedValue = int.tryParse(val);
                                        if (parsedValue != null) {
                                          position.code = parsedValue;
                                          errorColor =
                                          null; // Сброс цвета ошибки
                                        } else {
                                          position.code = null;
                                          errorColor = Colors.red;
                                        }
                                      }
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    if (index == _lists.length - 1) {
                                      addNewField();
                                    }
                                  },
                                  style: TextStyle(color: errorColor),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 230, 230, 230),
                                    border: const OutlineInputBorder(),
                                    errorStyle: TextStyle(color: errorColor),
                                    hintText: 'Код',
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      filled: true,
                                      fillColor:
                                      Color.fromARGB(255, 230, 230, 230),
                                      border: OutlineInputBorder(),
                                      hintText: 'Наименование'),
                                  maxLines: null,
                                  controller: position.nameController,
                                  keyboardType: TextInputType.name,
                                  onChanged: (val) {
                                    setState(() {
                                      position.name = val;
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    if (index == _lists.length - 1) {
                                      addNewField();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      filled: true,
                                      fillColor:
                                      Color.fromARGB(255, 230, 230, 230),
                                      border: OutlineInputBorder(),
                                      hintText: 'ед изм'),
                                  controller: position.mlController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      position.ml = int.tryParse(val);
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    if (index == _lists.length - 1) {
                                      addNewField();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      filled: true,
                                      fillColor:
                                      Color.fromARGB(255, 230, 230, 230),
                                      border: OutlineInputBorder(),
                                      hintText: 'Итог'),
                                  maxLines: null,
                                  controller: position.itogController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      position.itog = int.tryParse(val);
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    if (index == _lists.length - 1) {
                                      addNewField();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10),
              child: ElevatedButton(
                onPressed: _uploadExcelFile,
                child: const Text('Upload Excel File'),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10),
              child: ElevatedButton(
                onPressed: () async {
                  saveDataToPostgreSQL();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  late String _filePath;
  // ignore: unused_field
  bool _conversionSuccessful = false;

  Future<void> _uploadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });

      String excelData = await convertExcelToJson(_filePath);
      // перенести в отдельную функцию, работа с excelData
      dynamic data = jsonDecode(excelData);
      var resultArray = data["Page1"]
          .where((row) => int.tryParse(row[0].toString()) != null)
          .toList();
      for (var i = 0; i < resultArray.length; i++) {
        resultArray[i].removeAt(7); // remove 8th index
        resultArray[i].removeAt(6); // remove 7th index
        resultArray[i].removeAt(3); // remove 4th index
        resultArray[i].removeAt(2); // remove 3rd index
        setState(() {
          _lists.add(PositionClass(
              int.tryParse(resultArray[i][0]), resultArray[i][1], null, null));
        });
      }

      if (excelData.isNotEmpty) {
        setState(() {
          _conversionSuccessful = true;
        });
      }
    }
  }

  List<DataColumn> getColumns(List<String> columns) =>
      columns.map((String column) {
        return DataColumn(
          label: Text(column),
          onSort: onSort,
        );
      }).toList();

  void onSort(int? columnIndex, bool ascending) {
    if (columnIndex == 0) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.code ?? 0, user2.code ?? 0));
    } else if (columnIndex == 1) {
      _lists.sort(
              (user1, user2) => compareString(ascending, user1.name, user2.name));
    } else if (columnIndex == 2) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.ml ?? 0, user2.ml ?? 0));
    } else if (columnIndex == 3) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.itog ?? 0, user2.itog ?? 0));
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAsc = ascending;
    });
  }

  void addNewField() {
    setState(() {
      _lists.add(PositionClass(null, '', null, null));
    });
  }






  Future<void> saveDataToPostgreSQL() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      // Очистить таблицу перед импортом (если нужно)
      await connection.execute('DELETE FROM position');

      // Создать список значений для вставки
      final values = _lists
          .map((position) => '(${position.code}, \'${_escapeString(position.name)}\', ${position.ml}, ${position.itog})')
          .join(', ');

      // Замерить время сохранения данных
      final stopwatch = Stopwatch()..start();

      // Вставить данные в таблицу
      await connection.execute('INSERT INTO position (code, name, ml, itog) VALUES $values');

      // Остановить и вывести время сохранения в консоль
      stopwatch.stop();
      print('Время сохранения в PostgreSQL: ${stopwatch.elapsed.inMilliseconds} мс');

      // Закрыть соединение
      await connection.close();

      // Очистить списки после сохранения данных в БД
      setState(() {
        _lists.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Данные сохранены в PostgreSQL'),
        ),
      );
    } catch (e) {
      print('Ошибка при сохранении данных в PostgreSQL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении данных в PostgreSQL'),
        ),
      );
    }
  }

// Функция для экранирования специальных символов в строке
  String _escapeString(String value) {
    return value.replaceAll("'", "''");
  }







}