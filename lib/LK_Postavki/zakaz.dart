import 'package:flutter/material.dart';

class ZakazCompPage extends StatefulWidget {
  const ZakazCompPage({super.key});

  @override
  _ZakazCompPageState createState() => _ZakazCompPageState();
}

class _ZakazCompPageState extends State<ZakazCompPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Страница Zakaz'),
      ),
      body: Center(
        child: Text('Здесь будет ваш контент для страницы Zakaz'),
      ),
    );
  }
}
