import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/who.dart';
import 'order_ready_page.dart';
import 'package:http/http.dart' as https;

class StockPage extends StatefulWidget {
  final List<String> companiesToBuyList;

  StockPage({required this.companiesToBuyList});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Map<String, List<String>> orderSummaryMap = {};

  Map<String, List<TextEditingController>> textControllersMap = {};

  String selectedSupplier = ''; // Initialize with a default value
  List<String> supplierNames = [];
  Map<String, String> supplierMap = {};

  Future<void> fetchSupplierNames() async {
    final url = Uri.parse(
        'https://zakup.bar:8085/api/getPostNameUid?user_id_in_restaurant=${user!.uid}');

    try {
      final response = await https.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          for (var i = 0; i < responseData.length; i++) {
            final userCompanyId = responseData[i]['user_id_in_companies'];
            final fullname = responseData[i]['fullname_user_comp'];
            supplierMap[fullname] = userCompanyId;
            setState(() {});
          }
        }
        print(supplierMap);
      } else {
        // Handle the error if the response status code is not 200
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching supplier names: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSupplierNames();
    initializeOrderSummaryMap();
  }

  void initializeOrderSummaryMap() {
    for (var company in widget.companiesToBuyList) {
      orderSummaryMap[company] = ['']; // Add an empty string entry
      textControllersMap[company] = [TextEditingController()];
    }
  }

  void navigateToOrderSummaryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
            orderSummary: orderSummaryMap, supplierMap: supplierMap),
      ),
    );
  }

  void addNoteField(String company) {
    setState(() {
      textControllersMap[company]?.add(TextEditingController());
      orderSummaryMap[company]?.add(""); // Add an empty string entry
    });
  }

  void updateNoteValue(String company, int index, String value) {
    setState(() {
      orderSummaryMap[company]?[index] = value;
    });
  }

  @override
  void dispose() {
    // Dispose of text controllers to avoid memory leaks
    for (var controllersList in textControllersMap.values) {
      for (var controller in controllersList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сформировать ассортимент ресторана')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.companiesToBuyList.length,
              itemBuilder: (context, index) {
                final company = widget.companiesToBuyList[index];
                final controllersList = textControllersMap[company];
                return ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(company),
                  children: [
                    Column(
                      children: [
                        if (controllersList != null)
                          for (int i = 0; i < controllersList.length; i++)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (value) =>
                                    updateNoteValue(company, i, value),
                                controller: controllersList[i],
                                minLines: 1,
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter notes',
                                ),
                              ),
                            ),
                        ElevatedButton(
                          onPressed: () => addNoteField(company),
                          child: Text('Add Note'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              navigateToOrderSummaryPage();
            },
            child: Text('Сформировать заказ'),
          ),
        ],
      ),
    );
  }
}
