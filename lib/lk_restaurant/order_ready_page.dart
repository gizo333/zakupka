import 'dart:convert';
import 'package:http/http.dart' as https;

import 'package:flutter/material.dart';
import 'package:new_flut_proj/services/who.dart';

class OrderSummaryPage extends StatefulWidget {
  final Map<String, List<String>> orderSummary;
  Map<String, String> supplierMap;

  OrderSummaryPage({required this.orderSummary, required this.supplierMap});

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  @override
  void initState() {
    super.initState();
    if (widget.supplierMap.isNotEmpty) {
      selectedSupplier = widget.supplierMap.entries.first.value;
    } else {
      selectedSupplier =
          ''; // Здесь вы можете установить значение по умолчанию, если supplierMap пуст
    }
    initializeCompanyData();
  }

  String selectedSupplier = '';
  Map<String, List<Map<String, String>>> companyData = {};

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

  Future<void> sendOrderData(String company) async {
    final orderData = <Map<String, String>>[];

    for (int i = 0; i < companyData[company]!.length; i++) {
      var data = companyData[company]![i];
      final notes = widget.orderSummary[company]!;
      final orderItem = {
        'assortiment': notes[i], // наименовение
        'quantity': data['quantity']!, // количество
        'unit': data['unit']!, // ед изм
      };
      orderData.add(orderItem);
    }

    final companyInfo = {
      'company_name': company,
      'restaurant_uid': user!.uid, // Assuming you have 'user' defined
      'orderData': List<Map<String, String>>.from(orderData),
      'postav_uid': selectedSupplier,
    };

    final url = Uri.parse(
        'https://zakup.bar:8085/api/insertOrderData'); // Replace with your API endpoint
    final headers = {
      'Content-Type': 'application/json',
    };

    final jsonInfo = json.encode(companyInfo);
    print(companyInfo);

    try {
      final response = await https.post(
        url,
        headers: headers,
        body: jsonInfo,
      );

      if (response.statusCode == 200) {
        // Request was successful
        print('Order data sent successfully');
      } else {
        // Handle the error
        print('Error sending order data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error sending order data: $error');
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
                            SizedBox(
                              width: 10,
                              height: 10,
                            ),
                            DropdownButtonFormField<String>(
                              value: selectedSupplier,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedSupplier = newValue!;
                                });
                              },
                              items: widget.supplierMap.entries.map((entry) {
                                final fullname  = entry.key;
                                final userCompanyId = entry.value;
                                return DropdownMenuItem<String>(
                                  value: userCompanyId,
                                  child: Text(fullname),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Имя поставщика',
                                border: OutlineInputBorder(),
                              ),
                            )
                          ],
                        ),
                        trailing:
                            SizedBox.shrink(), // Remove the button from here
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await sendOrderData(company);
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
