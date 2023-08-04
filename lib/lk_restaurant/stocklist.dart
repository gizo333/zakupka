import 'package:flutter/material.dart';
import 'order_ready_page.dart';

class StockPage extends StatefulWidget {
  final List<String> companiesToBuyList;

  StockPage({required this.companiesToBuyList});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Map<String, List<String>> orderSummaryMap = {};

  Map<String, List<TextEditingController>> textControllersMap = {};

  @override
  void initState() {
    super.initState();
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
        builder: (context) => OrderSummaryPage(orderSummary: orderSummaryMap),
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
      appBar: AppBar(title: Text('Checklist')),
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
