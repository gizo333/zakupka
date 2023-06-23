import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/home_screen.dart';
import '/services/snack_bar.dart';

class VerifyEmailScreen extends StatefulWidget {
  final bool checkBoxValue1;
  final bool checkBoxValue2;
  final bool checkBoxValue3;

  const VerifyEmailScreen({
    Key? key,
    required this.checkBoxValue1,
    required this.checkBoxValue2,
    required this.checkBoxValue3,
  }) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? timer;

  bool get canResendEmail => _canResendEmail;

  set canResendEmail(bool value) {
    setState(() {
      _canResendEmail = value;
    });
  }

  late bool checkBoxValue1;
  late bool checkBoxValue2;
  late bool checkBoxValue3;


  @override
  void initState() {
    super.initState();

    checkBoxValue1 = widget.checkBoxValue1;
    checkBoxValue2 = widget.checkBoxValue2;
    checkBoxValue3 = widget.checkBoxValue3;

    print('checkBoxValue1: $checkBoxValue1');
    print('checkBoxValue2: $checkBoxValue2');
    print('checkBoxValue3: $checkBoxValue3');

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    print(isEmailVerified);


    if (isEmailVerified) {
      timer?.cancel();
      if (checkBoxValue1) {
        Navigator.pushReplacementNamed(context, '/kabinet');
      } else if (checkBoxValue2) {
        Navigator.pushReplacementNamed(context, '/stop');
      } else if (checkBoxValue3) {
        Navigator.pushReplacementNamed(context, '/lk-user');
      }
    }

  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          '$e',
          //'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: const Text('Верификация Email адреса'),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Письмо с подтверждением было отправлено на вашу электронную почту.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              icon: const Icon(Icons.email),
              label: const Text('Повторно отправить'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                timer?.cancel();
                await FirebaseAuth.instance.currentUser!.delete();
              },
              child: const Text(
                'Отменить',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}