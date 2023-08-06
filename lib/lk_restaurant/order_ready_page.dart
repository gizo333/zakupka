import 'package:flutter/material.dart';

class OrderSummaryPage extends StatefulWidget {
  final Map<String, List<String>> orderSummary;

  OrderSummaryPage({required this.orderSummary});

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  Map<String, List<Map<String, String>>> companyData = {};

  @override
  void initState() {
    super.initState();
    initializeCompanyData();
  }

  void initializeCompanyData() {
    // Initialize company data for each company's notes.
    for (var company in widget.orderSummary.keys) {
      companyData[company] = List.generate(
        widget.orderSummary[company]!.length,
        (index) => {
          'quantity': '1', // Default quantity
          'unit': 'Л', // Default unit of measurement
        },
      );
    }
  }

  void printOrderData() {
    for (var company in companyData.keys) {
      print('Company: $company');
      print('Имя поставщика: null');
      var notes = widget.orderSummary[company];
      var data = companyData[company]!;
      for (int i = 0; i < notes!.length; i++) {
        print('${i + 1}) ${notes[i]}');
        print('Количество: ${data[i]['quantity']} ${data[i]['unit']}');
      }
      print('-------------------');
    }
  }

  void sendOrderData(String company) {
    print('Отправить поставщику: $company');
    for (int i = 0; i < companyData[company]!.length; i++) {
      var data = companyData[company]![i];
      print(
          'Номер записки: ${i + 1}, Количество: ${data['quantity']}, Единица измерения: ${data['unit']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.orderSummary.length,
              itemBuilder: (context, index) {
                final company = widget.orderSummary.keys.elementAt(index);
                final notes = widget.orderSummary[company];
                final data = companyData[company]!;

                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(company),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < notes!.length; i++)
                              Row(
                                children: [
                                  Text("${i + 1}) ${notes[i]}"),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          data[i]['quantity'] =
                                              value.isNotEmpty ? value : '1';
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Количество',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          data[i]['unit'] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Единица измерения',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Text("Имя поставщика: null"),
                          ],
                        ),
                        trailing:
                            SizedBox.shrink(), // Remove the button from here
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sendOrderData(company);
                        },
                        child: Text('Отправить'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              printOrderData(); // Print all the entered information
            },
            child: Text('Отправить всем'),
          ),
        ],
      ),
    );
  }
}
