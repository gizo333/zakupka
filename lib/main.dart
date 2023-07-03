import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:new_flut_proj/pages/ResetPasswordScreen.dart';
import 'package:new_flut_proj/pages/push.dart';
import 'package:new_flut_proj/register/verify_email_screen.dart';
import 'package:new_flut_proj/services/firebase_messaging.dart';
import 'package:new_flut_proj/table/tableview.dart';
import 'package:new_flut_proj/theme/app_bar.dart';
import 'package:provider/provider.dart';
import '/pages/account_screen.dart';
import '/pages/home_screen.dart';
import 'list_to_rest/restaurant_list_bloc.dart';
import 'lk_restaurant/stop.dart';
import 'lk_restaurant/requests.dart';
import 'register/login_screen.dart';
import 'package:new_flut_proj/register/sign_up_screen.dart';
import '/services/firebase_streem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'list_to_rest/list_to_rest.dart';
import 'lk_restaurant/lk_rest.dart';
import 'lk_user/lk_user_sotrud.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Подписка на уведомления FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Получено новое уведомление: ${message.notification!.title}');
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => RestaurantListProvider(),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {

  final User? user = FirebaseAuth.instance.currentUser;
  get checkBoxValue1 => bool;
  get checkBoxValue2 => bool;
  get checkBoxValue3 => bool;
  // final MyFirebaseMessaging firebaseMessaging = MyFirebaseMessaging();
  // final MyFirebaseInstanceId firebaseInstanceId = MyFirebaseInstanceId();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // убирает надпись debug
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: ThemeBar.myThemeBar,
          foregroundColor: Colors.white,
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
        '/verify_email': (context) => VerifyEmailScreen(
          checkBoxValue1: checkBoxValue1,
          checkBoxValue2: checkBoxValue2,
          checkBoxValue3: checkBoxValue3,
        ),
        '/restaurantList': (context) => RestaurantListPage(),
        '/lk-user': (context) => LkUser(),
        '/requests': (context) => JoinRequestsPage(),
        // '/push': (context) => StopPage(
        // ),
      },
      initialRoute: '/',
    );
  }
}
