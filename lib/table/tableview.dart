import 'dart:async';

import 'package:flutter_excel/excel.dart';
import 'dart:convert';
// import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:postgres/postgres.dart';
import 'classes.dart';
import 'package:http/http.dart' as https;
import './sort_help.dart';
import './json_help.dart';
import 'save_to_bd.dart';
import '../services/who.dart';

class TableView extends StatefulWidget {
  final String tableName;

  const TableView({required this.tableName, Key? key}) : super(key: key);
  // const TableView({Key? key}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  List<PositionClass> _lists = [];
  List<PositionClass> _searchResults = [];

  Future<void> fetchTableDataFromPostgreSQLWeb(String searchQuery) async {
    final url = Uri.parse(
        'https://zakup.bar:8085/api/tables/fetchtable?tableName=${widget.tableName}&searchQuery=$searchQuery');

    try {
      final response = await https.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _lists = (result as List<dynamic>).map((row) {
          int code = int.tryParse(row['code'].toString()) ?? 0;
          String name = row['name'].toString();
          int ml = int.tryParse(row['ml'].toString()) ?? 0;
          int itog = int.tryParse(row['itog'].toString()) ?? 0;

          return PositionClass(code, name, ml, itog);
        }).toList();
        _searchResults = _lists; // обновить результаты поиска
        setState(() {});
      }
    } catch (e) {
      print('Вы пидор потому что $e');
    }
  }

  bool _sortAsc = true;
  bool _isButtonDisabled = false;
  // ignore: unused_field
  int? _sortColumnIndex;
  Color? errorColor;
  String _searchQuery = '';
  bool isReadOnly = false;

  late String userId; // Идентификатор пользователя

  Future<void> initializeFirebase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = currentUser!.uid; // Идентификатор пользователя
    });
    isReadOnly = await isReadonlyFunc();
  }

  void _resetSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    fetchTableDataFromPostgreSQLWeb(_searchQuery);

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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.tableName.split('_').last),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    // color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: TextField(
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // focusColor: Colors.white,
                  // labelText: 'Поиск',
                  alignLabelWithHint: true,
                  hintText: 'Поиск',
                  floatingLabelStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  prefixIcon: Icon(Icons.search),
                ),
                // onSubmitted: (value) {
                //   FocusScope.of(context).unfocus();
                // },
                onChanged: (value) {
                  _searchQuery = value;
                  _searchResults = _lists
                      .where((item) => item.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 246, 246, 246),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
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
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final position = _searchResults[index];
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
                                position.name = val;

                                // обновление записи в базе данных
                                // _updateDBWeb(position);

                                // обновление _searchResults и _lists
                                _lists[_lists.indexOf(position)] = position;
                                _searchResults = _lists
                                    .where((item) => item.name
                                        .toLowerCase()
                                        .contains(_searchQuery.toLowerCase()))
                                    .toList();

                                setState(() {});
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
                              readOnly: isReadOnly,
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
                          const SizedBox(width: 15), // Промежуток шириной 10
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              readOnly: true,
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
              color: const Color.fromARGB(106, 158, 158, 158),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ограничение по вертикали
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 170,
                          child: Container(
                            padding: const EdgeInsets.only(
                                bottom: 10, top: 10, left: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.black, // Цвет фона первой кнопки
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: () {
                                if (kIsWeb) {
                                  _uploadExcelFileWeb();
                                } else {
                                  _uploadExcelFile();
                                }
                              },
                              child: const Text(
                                'xls Файл',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: Container(
                            padding: const EdgeInsets.only(
                                bottom: 10, top: 10, right: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.black, // Цвет фона второй кнопки
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: addNewField,
                              child: const Text(
                                'Добавить поле',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black, // Цвет фона третьей кнопки
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () async {
                          if (!_isButtonDisabled) {
                            _isButtonDisabled = true;
                            _searchQuery = '';
                            setState(() {});
                            FocusScope.of(context).unfocus();
                            await saveItog(_lists);
                            setState(() {});
                            Timer(Duration(seconds: 1), () {
                              setState(() {
                                _isButtonDisabled = false;
                              });
                            });
                          }
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchItogsFromServer() async {
    final url = Uri.parse(
        'https://zakup.bar:8085/apip/tables/getitogs/${widget.tableName}');

    try {
      final response = await https.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> itogsData = jsonDecode(response.body);

        for (var itogData in itogsData) {
          final int code = itogData['code'];
          final int itog = itogData['itog'];

          // Найдите соответствующий объект PositionClass и обновите его itog
          final PositionClass position =
              _lists.firstWhere((position) => position.code == code);
          position.itog = itog;
        }

        setState(() {});
      } else {
        print('Error fetching itogs: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching itogs: $error');
    }
  }

  Future<void> updateItogFromAPI() async {
    final url = Uri.parse(
        'https://zakup.bar:8085/api/tables/fetchtable?tableName=${widget.tableName}&searchQuery=');

    try {
      final response = await https.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final newItogValues = Map<int, int>.fromIterable(
          result as List<dynamic>,
          key: (row) => int.tryParse(row['code'].toString()) ?? 0,
          value: (row) => int.tryParse(row['itog'].toString()) ?? 0,
        );

        // Обновление значений itog в списке _lists
        for (var position in _lists) {
          final updatedItog = newItogValues[position.code] ?? 0;
          position.itog = updatedItog;
          position.itogController.text = updatedItog.toString();
        }

        setState(() {});
      }
    } catch (e) {
      print('Ошибка при обновлении itog: $e');
    }
  }

  Future<void> saveItog(List<PositionClass> list) async {
    await updateItogFromAPI();
    // fetchItogsFromServer();
    for (final position in list) {
      final itog = (position.itog ?? 0) + (position.ml ?? 0);

      position.itog = itog;
      position.ml = 0;
      position.itogController.text = itog.toString();
      position.mlController.text = '';
    }

    saveDataToPostgreSQLBWeb(list, widget.tableName);
    setState(() {});
  }

  late String _filePath;
  // ignore: unused_field
  bool _conversionSuccessful = false;

// загрузка xlxs для телефона
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
      dynamic data = jsonDecode(excelData);

      data.forEach((pageName, pageData) {
        if (pageData is List) {
          var resultArray = pageData
              .where((row) =>
                  row is List && int.tryParse(row[0].toString()) != null)
              .toList();

          for (var i = 0; i < resultArray.length; i++) {
            setState(() {
              _lists.add(PositionClass(
                  int.tryParse(resultArray[i][0]), resultArray[i][1], 0, 0));
            });
          }
        }
      });

      if (excelData.isNotEmpty) {
        setState(() {
          _conversionSuccessful = true;
        });
      }
    }
    saveDataToPostgreSQLBWeb(_lists, widget.tableName);
  }

// загрузка .xlxs для веба
  Future<void> _uploadExcelFileWeb() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile != null) {
      try {
        var bytes = pickedFile.files.single.bytes;
        if (bytes != null) {
          print("Bytes are not null");

          String excelData = await convertByteToJson(bytes);
          dynamic data = jsonDecode(excelData);

          for (var table in data.keys) {
            var resultArray = data[table]
                ?.where((row) => int.tryParse(row[0].toString()) != null)
                ?.toList();

            if (resultArray != null) {
              for (var i = 0; i < resultArray.length; i++) {
                setState(() {
                  _lists.add(PositionClass(int.tryParse(resultArray[i][0]),
                      resultArray[i][1], 0, 0));
                });
              }
            }
          }

          if (_lists.isNotEmpty) {
            setState(() {
              _conversionSuccessful = true;
            });
          }

          saveDataToPostgreSQLBWeb(_lists, widget.tableName);
        } else {
          print("Bytes is null");
        }
      } catch (error) {
        print("Error during file processing: $error");
      }
    } else {
      print("No file picked");
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
      _searchResults.sort((user1, user2) =>
          compareNumeric(ascending, user1.code ?? 0, user2.code ?? 0));
    } else if (columnIndex == 1) {
      _searchResults.sort(
          (user1, user2) => compareString(ascending, user1.name, user2.name));
    } else if (columnIndex == 2) {
      _searchResults.sort((user1, user2) =>
          compareNumeric(ascending, user1.ml ?? 0, user2.ml ?? 0));
    } else if (columnIndex == 3) {
      _searchResults.sort((user1, user2) =>
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
    saveDataToPostgreSQLBWeb(_lists, widget.tableName);
    // fetchTableDataFromPostgreSQLWeb(_searchQuery);
  }
}

Future<bool> isReadonlyFunc() async {
  UserState hui = await whoami(user!.uid);
  print(hui.count);
  // ignore: unrelated_type_equality_checks
  if (hui.count == 1) {
    return false;
  } else {
    return true;
  }
}
