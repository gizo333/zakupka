import 'package:flutter/material.dart';

class PositionClass {
  late String name;
  int? hzvalue;
  int? ml;
  int? col;

  late TextEditingController nameController;
  late TextEditingController hzvalueController;
  late TextEditingController mlController;
  late TextEditingController colController;

  PositionClass(String name, int hzvalue, int ml, int col) {
    this.name = name;
    this.hzvalue = hzvalue;
    this.ml = ml;
    this.col = col;

    nameController = TextEditingController(text: name);
    hzvalueController = TextEditingController(text: hzvalue.toString());
    mlController = TextEditingController(text: ml.toString());
    colController = TextEditingController(text: col.toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionClass &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}


class StopMinimumPage extends StatefulWidget {
  const StopMinimumPage({Key? key}) : super(key: key);

  @override
  State<StopMinimumPage> createState() => _StopMinimumPage();
}

class _StopMinimumPage extends State<StopMinimumPage> {
  List<PositionClass> _lists = [];
  bool _sortAsc = true;
  int? _sortColumnIndex;

  int compareNumeric(bool ascending, int value1, int value2) {
    if (ascending) {
      return value1.compareTo(value2);
    } else {
      return value2.compareTo(value1);
    }
  }

  List<FocusNode> focusNodes = [];

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  @override
  void initState() {
    super.initState();
    _lists = [PositionClass('', 0, 0, 0)];
    focusNodes = List.generate(_lists.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    for (var position in _lists) {
      position.nameController.dispose();
      position.hzvalueController.dispose();
      position.mlController.dispose();
      position.colController.dispose();
    }
    super.dispose();
  }

  final defaultState = PositionClass('name', 0, 0, 0);

  @override
  Widget build(BuildContext context) {
    final columns = ['Код', 'Name', 'ml', 'col'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewField();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text(
          'Table',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(186, 0, 0, 0),
      ),
      body: SizedBox.expand(
        child: Container(
          color: Color.fromARGB(255, 246, 246, 246),
          child: SingleChildScrollView(
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAsc,
              columns: getColumns(columns),
              rows: createRows(),
            ),
          ),
        ),
      ),
    );
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
      _lists.sort(
          (user1, user2) => compareString(ascending, user1.name, user2.name));
    } else if (columnIndex == 1) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.hzvalue ?? 0, user2.hzvalue ?? 0));
    } else if (columnIndex == 2) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.ml ?? 0, user2.ml ?? 0));
    } else if (columnIndex == 3) {
      _lists.sort((user1, user2) =>
          compareNumeric(ascending, user1.col ?? 0, user2.col ?? 0));
    }
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAsc = ascending;
    });
  }

  void addNewField() {
    setState(() {
      _lists.add(PositionClass('', 0, 0, 0));
      focusNodes.add(FocusNode());
    });
  }

  List<DataRow> createRows() {
    return _lists.asMap().entries.map((entry) {
      final position = entry.value;
      final index = entry.key;
      final focusNode = focusNodes[index];

      return DataRow(
        cells: [
          DataCell(
            TextFormField(
              controller: position.nameController,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                setState(() {
                  position.name = val;
                });
              },
            ),
            showEditIcon: true,
          ),
          DataCell(
            TextFormField(
              controller: position.hzvalueController,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                setState(() {
                  position.hzvalue = int.parse(val);
                });
              },
            ),
            showEditIcon: true,
          ),
          DataCell(
            TextFormField(
              controller: position.mlController,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                setState(() {
                  position.ml = int.parse(val);
                });
              },
            ),
            showEditIcon: true,
          ),
          DataCell(
            TextFormField(
              // key: UniqueKey(),
              controller: position.colController,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                setState(() {
                  position.col =int.parse(val);
                });
              },
            ),
            showEditIcon: true,
          ),
        ],
      );
    }).toList();
  }
}
