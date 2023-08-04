import 'package:flutter/material.dart';

class OrderSummaryPage extends StatelessWidget {
  final Map<String, List<String>> orderSummary;

  OrderSummaryPage({required this.orderSummary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Summary')),
      body: ListView.builder(
        itemCount: orderSummary.length,
        itemBuilder: (context, index) {
          final company = orderSummary.keys.elementAt(index);
          final note = orderSummary[company];

          return ListTile(
            title: Text(company),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Записка: ${note ?? ""}"),
                Text("Имя поставщика: null"),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Implement the logic to send the order to the supplier.
              },
              child: Text('Отправить поставщику'),
            ),
          );
        },
      ),
    );
  }
}
