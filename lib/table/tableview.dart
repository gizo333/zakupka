import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:postgres/postgres.dart';
import 'classes.dart';
import './sort_help.dart';
import './json_help.dart';
import 'save_to_bd.dart';

class TableView extends StatefulWidget {
  final String tableName;

  const TableView({required this.tableName, Key? key}) : super(key: key);
  // const TableView({Key? key}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  // List<Map<String, dynamic>> _tableData = [];
  List<PositionClass> _originalList = []; // Copy of the original list
  List<PositionClass> _lists = [];

  Future<void> fetchTableDataFromPostgreSQL() async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    final user = FirebaseAuth.instance.currentUser;

    try {
      await connection.open();

      final result = await connection.query(
        'SELECT code, name, ml, itog FROM ${widget.tableName}',
      );

      _lists = result.map((row) {
        int code = int.tryParse(row[0].toString()) ?? 0;
        String name = row[1].toString();
        int ml = int.tryParse(row[2].toString()) ?? 0;
        int itog = int.tryParse(row[3].toString()) ?? 0;

        return PositionClass(code, name, ml, itog);
      }).toList();
      setState(() {});

      await connection.close();
    } catch (e) {
      print('Error fetching table data from PostgreSQL: $e');
    }
  }

  bool _sortAsc = true;
  // ignore: unused_field
  int? _sortColumnIndex;
  Color? errorColor;
  String _searchQuery = '';

  late String userId; // Идентификатор пользователя

  Future<void> initializeFirebase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = currentUser!.uid; // Идентификатор пользователя
    });
  }

  void _filterList() {
    setState(() {
      // меняет массив _lists
      _lists = _originalList.where((position) {
        final name = position.name.toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _resetSearch() {
    setState(() {
      _searchQuery = '';
      _lists = List.from(_originalList);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    fetchTableDataFromPostgreSQL();
    _originalList = [];
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
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterList();
                });
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.close),
            //   onPressed: _resetSearch,
            // ),
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
                        padding: const EdgeInsets.symmetric(vertical: 1),
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Выравнивание по правому краю
                        children: [
                          SizedBox(
                            width: 60, // Размер фоновой области
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLines: 4,
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
                                      errorColor = null; // Сброс цвета ошибки
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
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(),
                                hintText: 'Код',
                              ),
                            ),
                          ),
                          SizedBox(width: 15), // Промежуток шириной 10
                          Expanded(
                            flex: 2,
                            // fit: FlexFit.tight,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
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
                          SizedBox(width: 15), // Промежуток шириной 10
                          Expanded(
                            child: TextFormField(
                              maxLines: 4,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(),
                              ),
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
                          SizedBox(width: 15), // Промежуток шириной 10
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
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
                        ],
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
                // Сохраняет значение _листс в базу данных
                onPressed: () {
                  // saveItog(_lists);
                  // saveDataToPostgreSQL(context, _lists);
                  saveDataToPostgreSQL(_lists, widget.tableName);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveDataToPostgreSQL(
      List<PositionClass> list, String tableName) async {
    final connection = PostgreSQLConnection(
      '37.140.241.144',
      5432,
      'postgres',
      username: 'postgres',
      password: '1',
    );

    try {
      await connection.open();

      // Очищаем таблицу перед сохранением новых данных
      await connection.execute('DELETE FROM $tableName');

      for (final position in list) {
        final code = position.code ?? 0;
        final name = position.name ?? '';
        final itog = position.itog ?? 0;
        final ml = position.ml ?? 0;

        await connection.execute(
            'INSERT INTO $tableName (code, name, itog, ml) VALUES (@code, @name, @itog, @ml)',
            substitutionValues: {
              'code': code,
              'name': name,
              'itog': itog,
              'ml': ml,
            });
      }

      await connection.close();
    } catch (e) {
      print('Error saving data to PostgreSQL: $e');
    }
  }

  void saveItog(List<PositionClass> list) {
    int itog = 0;
    for (int i = 0; i < list.length; i++) {
      itog += list[i].ml ?? 0;
      list[i].itog = (list[i].itog ?? 0) + (list[i].ml ?? 0);
      print(list[i].itog);
      Future.microtask(() {
        setState(() {
          _lists[i].itog = list[i].itog;
          _lists[i].itogController.text = list[i].itog?.toString() ?? '';
        });
      });
    }
    setState(() {
      _lists = list;
    });
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
          _originalList = List.from(_lists);
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
      // _originalList.add(PositionClass(null, '', null, null));
      _originalList = List.from(_lists);
    });
  }
}
