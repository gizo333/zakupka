

import 'package:flutter/material.dart';
import 'package:new_flut_proj/pages/scrollable_widget.dart';
import '/services/snack_bar.dart';

class PositionClass {
  late String name;
  late int hzvalue;
  late int ml;
  late int col;

  PositionClass(this.name, this.hzvalue, this.ml, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionClass &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}


class Invent extends StatefulWidget {
  const Invent({super.key});

  @override
  State<Invent> createState() => _Invent();
}

class _Invent extends State<Invent> {
  var defaultState = PositionClass('', 0, 0, 0);
  List<PositionClass> _lists = [];
  late final TextEditingController _valuename;

  @override
  void initState() {
    super.initState();
    _valuename = TextEditingController();
    _lists = [];
    _lists.add(defaultState);
  }

  @override
  void dispose() {
    _valuename.dispose();
    super.dispose();
  }

  bool _sortAsc = true;
  int? _sortColumnIndex;

  int compareString(bool ascending,  String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  @override
  Widget build(BuildContext context) {
    final columns = ['Name', 'hui', 'ml', 'col'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
                defaultState = PositionClass('', 0, 0, 0),
                setState(() {
                  _lists.add(defaultState);
                }),
                print(_lists.length)
              }),
      appBar: AppBar(
        title: const Text('Table'),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Container(
            color: const Color.fromARGB(255, 253, 223, 223),
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAsc,
              columns: getColumns(columns),
              rows: createRows(_lists),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(column),
            onSort: onSort,
          ))
      .toList();

  void onSort(columnIndex, ascending) {
    if (columnIndex == 0) {
      _lists.sort(
          (user1, user2) => compareString(ascending, user1.name, user2.name));
    } else if (columnIndex == 1) {
      _lists.sort((user1, user2) =>
          compareString(ascending, '${user1.hzvalue}', '${user2.hzvalue}'));
    } else if (columnIndex == 2) {
      _lists.sort((user1, user2) =>
          compareString(ascending, '${user1.ml}', '${user2.ml}'));
    } else if (columnIndex == 3) {
      _lists.sort((user1, user2) =>
          compareString(ascending, '${user1.col}', '${user2.col}'));
    }
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAsc = ascending;
    });
  }

  List<DataRow> createRows(lists) {
    lists.forEach(
      (element) {
        print(element.name);
      },
    );
    print('first element: ' + lists[0].name);
    // print(_lists.length);

    return _lists
        .asMap()
        .entries
        .map((entry) => DataRow(cells: [
              DataCell(
                  TextFormField(
                    key: UniqueKey(),
                    initialValue: entry.value.name,
                    keyboardType: TextInputType.name,
                    onFieldSubmitted: (val) {
                      setState(() {
                        _lists[entry.key].name = val;
                      });
                    },
                  ),
                  showEditIcon: true),
              DataCell(
                  TextFormField(
                    key: UniqueKey(),
                    initialValue: entry.value.hzvalue.toString(),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (val) {
                      setState(() {
                        _lists[entry.key].hzvalue = int.parse(val);
                      });
                      print('onSubmited $val');
                    },
                  ),
                  showEditIcon: true),
              DataCell(
                  TextFormField(
                    key: UniqueKey(),
                    initialValue: entry.value.ml.toString(),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (val) {
                      setState(() {
                        _lists[entry.key].ml = int.parse(val);
                      });
                      print('onSubmited $val');
                    },
                  ),
                  showEditIcon: true),
              DataCell(
                     TextFormField(
                      key: UniqueKey(),
                      initialValue: entry.value.col.toString(),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (val) {
                        setState(() {
                          _lists[entry.key].col = int.parse(val);
                        });
                        print('onSubmited $val');
                      },
                    ),

                  showEditIcon: true),
            ]))
        .toList();
  }
}
