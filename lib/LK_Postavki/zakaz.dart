import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;

import 'package:new_flut_proj/LK_Postavki/bottom_bar.dart';
import 'dart:convert';
import '../services/who.dart';
import 'package:provider/provider.dart';

class ZakazCompPage extends StatefulWidget {
  const ZakazCompPage({Key? key}) : super(key: key);

  @override
  _ZakazCompPageState createState() => _ZakazCompPageState();
}

class _ZakazCompPageState extends State<ZakazCompPage> {
  List<dynamic> data = [];
  Color newOrderButtonColor = Colors.blue;

// фетччит заказ который был отправлен определенному юзеру
  Future<void> fetchData() async {
    final String serverUrl = 'https://zakup.bar:9000/zakaz/${user!.uid}';
    try {
      final response = await https.get(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Полученные данные: $responseData');

        setState(() {
          data = responseData;
          newOrderButtonColor = Colors.green;
        });
      } else {
        print('Ошибка запроса: ${response.statusCode}');
      }
    } catch (error) {
      print('Ошибка при выполнении запроса: $error');
    }
  }

// отрисовывает все заказы на экране
  Widget buildOrderList() {
    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final orderData = item['order_data'] as List<dynamic>;

          return Card(
            child: Column(
              children: orderData.map((orderItem) {
                final assortiment = orderItem['assortiment'];
                final unit = orderItem['unit'];
                final quantity = orderItem['quantity'];
                return ListTile(
                  title: Text('Наименование: $assortiment'),
                  subtitle: Text('Бут.: $unit, Количество: $quantity'),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

// копирует заказ в буфер
  Future<void> copyData() async {
    if (data.isNotEmpty) {
      final clipboardData = data.map((item) {
        final orderData = item['order_data'] as List<dynamic>;
        final orderText = orderData.map((orderItem) {
          final assortiment = orderItem['assortiment'];
          final unit = orderItem['unit'];
          final quantity = orderItem['quantity'];
          return 'Наименование: $assortiment, Бут.: $unit, Количество: $quantity';
        }).join('\n');

        return orderText;
      }).join('\n\n');

      Clipboard.setData(ClipboardData(text: clipboardData)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные скопированы в буфер обмена'),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет данных для копирования'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomState = Provider.of<BottomNavState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Страница Zakaz'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                fetchData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: newOrderButtonColor,
              ),
              child: const Text('Новый заказ'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                copyData();
              },
              child: const Text('Скопировать данные'),
            ),
            // выводит заказ на экран в виде списка
            buildOrderList(),
          ],
        ),
      ),
      bottomNavigationBar: buildMyBottomNavigationBar(
          context, bottomState.currentIndex, (index) {
        bottomState.setCurrentIndex(index);
      }),
    );
  }
}
