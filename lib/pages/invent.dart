import 'package:flutter/material.dart';
import '/services/snack_bar.dart';

class Invent extends StatefulWidget {
   const Invent({super.key});

  @override
  _Invent createState() => _Invent();
}

class _Invent extends State<Invent> {
  final int _selectTab = 0;
  void onSelect (int index){

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 240, 0.9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color.fromRGBO(0, 11, 13, 1), Color.fromRGBO(0, 11, 13, 0.9)]),
          ),
        ),
        title: const Text('Инвентаризация'),
      ),


      bottomNavigationBar: BottomNavigationBar(backgroundColor: const Color.fromRGBO(242, 242, 240, 0.8),
          currentIndex: _selectTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: 'Search',
            )
          ]),
    );
  }
}







