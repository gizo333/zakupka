import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_flut_proj/LK_Postavki/post_styles.dart';
import '../pages/account_screen.dart';

class LkPostavPage extends StatefulWidget {
  const LkPostavPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LkPostavPageState createState() => _LkPostavPageState();
}

class _LkPostavPageState extends State<LkPostavPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> buttonLabels = [
    'Сотрудники',
    'Рестораны',
    'Кнопка 3',
    'Кнопка 4'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LkPostav'),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.account_circle,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: AppStyles.buttonHeight,
            color: AppStyles.buttonBackgroundColor,
            padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.buttonPaddingHorizontal),
            child: _buildButtons(),
          ),
          const SizedBox(height: AppStyles.defaultSpacing),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: screenWidth,
        color: AppStyles.buttonBackgroundColor,
        padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.buttonPaddingHorizontal),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<Widget>.generate(buttonLabels.length, (index) {
            return TextButton(
              onPressed: () {
                _handleButtonPress(buttonLabels[index]);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppStyles.buttonTextHighlightColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppStyles.buttonBorderRadius),
                ),
              ),
              child: Text(
                buttonLabels[index],
                style: const TextStyle(
                  color: AppStyles.buttonTextColor,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _handleButtonPress(String label) {
    // Ваша логика для обработки нажатия кнопки с данным label
    print('Нажата кнопка: $label');

    if (label == 'Сотрудники') {
      Navigator.pushNamed(context, '/lk-user');
    }
    if (label == 'Рестораны') {
      Navigator.pushNamed(context, '/restaurantList');
    }
  }
}
