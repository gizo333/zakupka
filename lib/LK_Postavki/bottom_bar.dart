import 'package:flutter/material.dart';
import 'package:new_flut_proj/LK_Postavki/lk_post.dart';
import 'package:new_flut_proj/LK_Postavki/my_rest.dart';
import 'package:new_flut_proj/LK_Postavki/zakaz.dart';
import 'package:provider/provider.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  MyBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Мои рестораны',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Заказы',
        ),
      ],
    );
  }
}

Widget buildMyBottomNavigationBar(
    BuildContext context, int currentIndex, Function(int) onTap) {
  final List<String> routes = ['/LKpostav', '/myRest', '/zakaz'];

  return MyBottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      onTap(index);
      final targetRoute = routes[index];

      if (ModalRoute.of(context)?.settings.name != targetRoute) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              // Возвращайте виджет той страницы, на которую переходите
              switch (targetRoute) {
                case '/LKpostav':
                  return LkPostavPage();
                case '/myRest':
                  return MyRestPage();
                case '/zakaz':
                  return ZakazCompPage();
                default:
                  return Container(); // Возвращайте что-то по умолчанию, если не найден маршрут
              }
            },
            transitionDuration:
                Duration.zero, // Устанавливаем длительность анимации в ноль
          ),
          (route) => false,
        );
      }
    },
  );
}

class BottomNavState extends ChangeNotifier {
  // Глобальное состояние приложения
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
