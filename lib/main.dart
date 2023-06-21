import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_flut_proj/pages/ResetPasswordScreen.dart';
import 'package:new_flut_proj/pages/kabinet.dart';
import 'package:new_flut_proj/pages/stop_minimum.dart';
import 'package:new_flut_proj/register/verify_email_screen.dart';
import 'package:new_flut_proj/table/tableview.dart';
import 'package:new_flut_proj/theme/app_bar.dart';
import '/pages/account_screen.dart';
import '/pages/home_screen.dart';
import '/pages/login_screen.dart';
import 'package:new_flut_proj/register/sign_up_screen.dart';
import '/services/firebase_streem.dart';


import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // убирает надпись debug
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme:  const AppBarTheme(
            backgroundColor: ThemeBar.myThemeBar,
            foregroundColor: Colors.white
        ),
      ),

      routes: {
        '/': (context) => FirebaseStream(),
        '/kabinet': (context) => const Kabinet(),
        '/home': (context) => const HomeScreen(),
        '/table': (context) => const TableView(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/stop': (context) => UserListPage(),

      },
      initialRoute: '/',
    );
  }
}