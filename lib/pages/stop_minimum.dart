import 'package:flutter/material.dart';

class SearchFunction extends StatefulWidget {
  @override
  _SearchFunctionState createState() => _SearchFunctionState();
}

class _SearchFunctionState extends State<SearchFunction> {
  TextEditingController _searchController = TextEditingController();
  List<String> _dataList = ['Apple', 'Banana', 'Cherry', 'Durian', 'Elderberry'];
  List<String> _filteredDataList = [];

  @override
  void initState() {
    super.initState();
    _filteredDataList.addAll(_dataList);
  }

  void _filterList(String searchQuery) {
    _filteredDataList.clear();
    if (searchQuery.isNotEmpty) {
      _dataList.forEach((item) {
        if (item.toLowerCase().contains(searchQuery.toLowerCase())) {
          _filteredDataList.add(item);
        }
      });
    } else {
      _filteredDataList.addAll(_dataList);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterList(value);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredDataList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
