import 'package:flutter/material.dart';
import 'stocklist.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<String> companies = [
    "Beluga",
    "Беломор канал",
    "портвейн 777",
    "Бояршник",
    "Самогон",
    "Арарат",
    "Спирт",
  ];

  List<String> filteredCompanies = [];
  List<String> companiesToBuyList = [];

  @override
  void initState() {
    super.initState();
    filteredCompanies.addAll(companies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          buildCompanySearch(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Доступные компании',
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(child: buildCompanyList()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Корзина',
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(child: buildCompaniesToBuyList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              goToChecklistPage(context);
            },
            child: Text('Go to checklist'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildCompanySearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          filterCompanies(value);
        },
        decoration: InputDecoration(
          labelText: 'Search Company',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildCompanyList() {
    return ListView.builder(
      itemCount: filteredCompanies.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredCompanies[index]),
          onTap: () {
            setState(() {
              companiesToBuyList.add(filteredCompanies[index]);
              companies.remove(filteredCompanies[index]);
              filteredCompanies.removeAt(index);
            });
          },
        );
      },
    );
  }

  Widget buildCompaniesToBuyList() {
    return ListView.builder(
      itemCount: companiesToBuyList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(companiesToBuyList[index]),
          onTap: () {
            setState(() {
              filteredCompanies.add(companiesToBuyList[index]);
              companies.add(companiesToBuyList[index]);
              companiesToBuyList.removeAt(index);
            });
          },
        );
      },
    );
  }

  void filterCompanies(String query) {
    setState(() {
      filteredCompanies = companies
          .where(
              (company) => company.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void goToChecklistPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockPage(companiesToBuyList: companiesToBuyList),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CheckoutPage(),
  ));
}
