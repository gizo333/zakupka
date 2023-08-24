// ignore_for_file: use_build_context_synchronously

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

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      isEmailVerified = currentUser.emailVerified;
    }

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
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      setState(() {
        isEmailVerified = currentUser.emailVerified;
      });
    }

    print(isEmailVerified);

    if (isEmailVerified) {
      timer?.cancel();
      if (widget.checkBoxValue1) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/kabinet', (route) => false);
      } else if (widget.checkBoxValue2) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/LKpostav', (route) => false);
      } else if (widget.checkBoxValue3) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/lk-user', (route) => false);
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
                      var currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        await currentUser.delete();
                      }
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
